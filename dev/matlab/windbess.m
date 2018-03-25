%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wind power dispatch with battery energy storage employing state-space 
% model predictive control (MPC).  A battery energy storage system coupled
% to a wind farmn is used to firm-up power dispatched to grid, which is
% scheduled during pre-dispatch on the basis of unconstrained intermittent
% generation forecasts (UIGF) produced by the Australian Wind Energy 
% Forecasting System.
%
% Author:  Silvio Tarca
% Date:    March 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A single binary (dummy) variable for each time interval in the control
% horizon ensures linear complementarity -- battery charge and discharge
% control signals cannot both be different from zero at the same time.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

timesta = tic;  % Record start time for execution of program

m = 2;          % Length of single-period process output vector
s = 4;          % Length of single-period state vector
q = 3;          % Length of single-period control increment vector
d = 1;          % Number of binary (dummy) variables for each time interval
                % in the control horizon, w
n = 6;          % Number of time intervals in prediciton and control horizons
 
epsilon = 1e-04;    % Round-off tolerance to account for errors arising
                    % from floating point operations

delta = 1/12;   % Conversion factor from MW to MWh for given dispatch interval
                % (i.e., 5 minutes = 1/12 of an hour)
eta = 0.90;   % One-way battery charge/discharge efficiency (measured
                    % efficiency of the Telsa/Neoen Hornsdale Power Reserve
                    % over the full month of December 2017)
nmae = 0.05;    % Normalised mean absolute error of unconstrained intermittent
                % generation forecasts (UIGF)
base = 100;     % Base (MW and MWh) for per-unit (dimensionless) quantities

% Define power and energy in terms of per unit base quantity
windcap = 1.00*base;    % Wind farm registered capacity (MW)
battcap = 1.00*base;    % Battery storage capacity (MWh)
battrt = 1.00*base;     % Battery rated power (MW)

% Define matrices describing incremental state-space model
A = [ 1 delta*eta -delta/eta 0; 0 1 0 0; 0 0 1 0; 0 0 0 1 ];
B = [ delta*eta -delta/eta 0; 1 0 0; 0 1 0; 0 0 1 ];
C = [ 1 0 0 0; 0 -1 1 1 ];
[ K, L ] = mpckl( m, s, q, d, n, A, B, C );

% Read UIGF forecasts and SCADA (measured) data from input file 
uigffile = '/Users/starca/projects/windbess/dev/data/in/uigf_meas.dat';
[ N, duid, uigfutc, uigf, measutc, measaet, pwmeas, sdcmeas ] = ...
    uigfread( uigffile );
% Calculate the number of time steps in the simulation horizon
fprintf( 'UIGF file is: %s\n', uigffile );
fprintf( 'Number of time steps in simulation horizon, N = %d\n', N );

% Open simulation output file and write header
simfile = '/Users/starca/projects/windbess/dev/data/out/windbess_snowtwn1.dat';
simfid = fopen( simfile, 'w' );
fprintf( simfid, ['# DUID\tDptchUTC\tDptchAET\tUIGFUTC\tPwrDptch\t', ...
    'SetPtPwrDsptch\tBESSChrg\tPwrChrg\tPwrDchrg\tBESSSOC\tPwrWind\t', ...
    'UIGF5m\tPwrGTSetPt\tSDCMeas\n'] );

% Define upper and lower bounds on state variables: battery state of charge 
% (SOC) e; battery charge command p_{b+}; battery discharge command p_{b-};
% and wind power generation command p_{w}
zlb = [ 0.125*battcap; 0.00*battrt; 0.00*battrt; 0.00*windcap ];
zub = [ 0.875*battcap; 1.00*battrt; 1.00*battrt; 1.00*windcap ];

% Define scalar weighting coefficient, and weighting matrices and vector
lambda = 0.0;
omega = [ 0.0; 1.0 ];
psi = [ 1.0; 1.0; 0.0 ];
[ lambda, Omega, Psi ] = mpcwgt( m, q, d, n, lambda, omega, psi );

% Set options for MATLAB/CPLEX mixed integer quadratic program (MIQP)
%options = cplexoptimset( 'Display', 'off', 'TolFun', 1e-12, 'TolX', 1e-12 );

% Define initial value of observable state variable: battery SOC e
x0 = ( zlb(1) + zub(1) ) / 2.0;
% Define initial values of internal state variables: battery charge 
% command p_{b+}; battery discharge command p_{b-}; and wind power 
% generation command p_{w}
ulast = [ 0.00*battrt; 0.00*battrt; 0.0 ];
% Define initial state vector:
z0 = [ x0; ulast ];
% Initialise wind power predictions and set points for power dispatched to
% the grid
sppd = zeros(n,1);
[ pw, sppd ] = wppsppd( n, uigf(1,:), pwmeas(1), sdcmeas(1), sppd, ...
    x0, zlb(1), zub(1), windcap, nmae );

% Construct vector of set points (battery SOC and power dispatched to the 
% grid) for process outputs over the prediction horizon
spsoc = ones( n, 1 ) * x0;
sp = spsocpd( m, n, spsoc, sppd );

% Declare output matrix used to verify simulation results.  Columns: 
% e, p_{d}, sp[e], ref[p_{d}], p_{b+}, p_{b-}, p_{w}, w
Y = zeros( N, m+m+q+d );
% Initialise measures quantifying the deviation in power dispatched to the
% grid relative to scheduled power (set point)
dpcnt = 0;      % Dispatch count
mae = 0.0;      % Mean absolute error (MW)
mse = 0.0;      % Mean square error (MW)
pdgtspcnt = 0;  % Dispatch count where power dispatched exceed set point
pdgtspmwh = 0.0;    % Energy dispatched when power exceeds set point (MWh)

% Define quadratic term of performance index (objective function of MIQP)
H = transpose(L)*Omega*L + lambda*Psi;
% Set type for each variable in the argument argument vector of MIQP
ctype = miqptype( q, d, n );
for k = 1:N     % For each time step in simulation

    % Define constraints on optimisation of the performance index
    [ G, h ] = miqpcstr( m, q, d, n, delta, eta, z0, pw, zlb, zub );
    % Define linear term of the performance index (obj func of MIQP)
    f = transpose(K*z0 - sp)*Omega*L;
    % Optimise performance index using quadratic programming
    [v, fval, exitflag, output] = cplexmiqp( ...
        H, f, G, h, [], [], [], [], [], [], [], ctype );
    % Check for optimization errors/ warnings
    if ( exitflag < 1 )
        fprintf( 'Error: Solver terminated with exitflag = %d ', exitflag );
        fprintf( 'at time step %d of simulation.\n', k);
        return; % Exit script
    end
    % Evaluate process outputs and control signals
    [ du, u, y, w ] = evalout( q, d, n, K, L, ulast, z0, v );

    % Accumulate statistics when set point for power dispatched to the grid
    % during the next dispatch interval exceeds zero
    if ( sp(m) > epsilon )
        dpcnt = dpcnt + 1;
        mae = mae + abs( y(m) - sp(m) );
        mse = mse + (y(m) - sp(m))^2;
    end
    % Accumulate statistics when power dispatched to the grid exceeds set point
    if ( y(m) > sp(m) + epsilon )
        pdgtspcnt = pdgtspcnt + 1;
        pdgtspmwh = pdgtspmwh + (y(m) - sp(m))*delta;
    end
    
    % Write output from simulation iteration to file
    measutck = datestr( measutc(k), 'yyyy-mm-dd HH:MM:SS' );
    measaetk = datestr( measaet(k), 'yyyy-mm-dd HH:MM:SS' );
    uigfutck = datestr( uigfutc(k), 'yyyy-mm-dd HH:MM:SS' );
    uigf5m = max( [0.0, uigf(k,1)] );
    pdgtsp = max( [0.0, y(2)-sp(2)] );
    fprintf( simfid, ...
'%s\t%s\t%s\t%s\t%.6f\t%.6f\t%d\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%d\n', ...
        duid, measutck, measaetk, uigfutck, y(2), sp(2),  w(1), u(1), u(2), ...
        y(1), u(3), uigf5m, pdgtsp, sdcmeas(k) );

    % Reset variables for next simulation iteration
    x0 = y(1);
    ulast = u(1:q);
    z0 = [ x0; ulast ];
    if ( k < N )
        [ pw, sppd ] = wppsppd( n, uigf(k+1,:), pwmeas(k+1), sdcmeas(k+1), ...
            sppd, x0, zlb(1), zub(1), windcap, nmae );
        spsoc = ones( n, 1 ) * x0;
        sp = spsocpd( m, n, spsoc, sppd );
    end

end

% Close simulation output file
fclose( simfid );

% Write simulation results to terminal
fprintf( 'Number of dispatch intervals: %d\n', dpcnt );
fprintf( 'Mean absolute error: %.3f MW\n', mae/dpcnt );
fprintf( 'Normalised mean absolute error: %.3f%%\n', (mae/dpcnt)/windcap*100 );
fprintf( 'Mean square error: %.3f MW^2\n', mse/dpcnt );
fprintf( ...
'Number of dispatch intervals when power dispatched exceeds set point: %d\n', ...
    pdgtspcnt );
fprintf( 'Energy dispatched when power exceeds set point: %.3f MWh\n\n', ...
    pdgtspmwh );

timeelap = toc( timesta );  % Measure elapsed time for execution of program
fprintf( 'Elapsed time: %.1f seconds\n', timeelap );
