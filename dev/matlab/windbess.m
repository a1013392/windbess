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
n = 6;         % Number of time intervals in prediciton and control horizons
 
epsilon = 1e-12;    % Round-off tolerance to account for errors arising
                    % from floating point operations

delta = 1/12;   % Conversion factor from MW to MWh for given dispatch interval
                % (i.e., 5 minutes = 1/12 of an hour)
eta = sqrt(0.80);   % One-way battery charge/discharge efficiency (measured
                    % efficiency of the Telsa/Neoen Hornsdale Power Reserve
                    % over the full month of December 2017)

% Base (MW and MWh) for per-unit (dimensionless) quantities
if ( ~exist('pubase', 'var') ) pubase = 99.0; end
% Define power and energy in terms of per unit base quantity
% Wind farm registered capacity (MW)
if ( ~exist('windcap', 'var') ) windcap = 1.00*pubase; end
% Battery storage capacity (MWh)  
if ( ~exist('battcap', 'var') ) battcap = 0.30*pubase; end
% Battery rated power (MW)
battrt = 0.80*battcap;
% Maximum "delta control" command -- amount that wind power set point is limited
% below predicted available capacity
deltacntl = 0.00*battcap;

% Write simulation parameters/ arguments to terminal
fprintf( 'Wind farm capacity: %.2f MW\n', windcap );
fprintf( 'Battery energy capacity: %.2f MWh\n', battcap );
fprintf( 'Battery rated power: %.2f MW\n', battrt );

% Define matrices describing incremental state-space model
A = [ 1 delta*eta -delta/eta 0; 0 1 0 0; 0 0 1 0; 0 0 0 1 ];
B = [ delta*eta -delta/eta 0; 1 0 0; 0 1 0; 0 0 1 ];
C = [ 1 0 0 0; 0 -1 1 1 ];
[ K, L ] = mpckl( m, s, q, d, n, A, B, C );

% Read UIGF forecasts and SCADA (measured) data from input file 
if ( ~exist('uigffile', 'var') ) 
	uigffile = '/Users/starca/uofa/projects/windbess/dev/data/in/uigf_meas.dat';
end
[ N, duid, uigfutc, uigf, measutc, measaet, pwmeas, sdcmeas ] = ...
    uigfread( uigffile );
fprintf( 'Number of time steps in simulation horizon, N = %d\n', N );

% Open simulation output file and write header
if ( ~exist('simfile', 'var') ) 
	simfile = '/Users/starca/uofa/projects/windbess/dev/data/out/windbess_sim_snowtwn1.dat';
end
simfid = fopen( simfile, 'w' );
fprintf( simfid, ['#DUID\tDptchUTC\tDptchAET\tUIGFUTC\tPwrDptch\t', ...
    'SetPtPwrDsptch\tBESSChrg\tPwrChrg\tPwrDchrg\tBESSSOC\tPwrWind\t', ...
    'UIGF5min\tPwrDptchSurplus\tPwrDptchDeficit\tSDCMeas\n'] );

% Open simulation results file for writing or appending, and in the former
% case write header record if header flag is TRUE
if ( ~exist('rslthdr', 'var') ) rslthdr = true; end 
if ( ~exist('rsltfile', 'var') ) 
	rsltfile = '/Users/starca/uofa/projects/windbess/dev/data/out/windbess_rslt_snowtwn1_xxxx.dat';
end
if ( exist(rsltfile, 'file') )
    rsltfid = fopen( rsltfile, 'a' );
else
    rsltfid = fopen( rsltfile, 'w' );
	if ( rslthdr )
    	fprintf( rsltfid, ['#DUID\tSimHrzn\tCtrlHrzn\tWindCap\tBattCap\tBattRt\t', ...
        	'CtrlWgt\tDptchInt\tMeanAbsErr\tNormMeanAbsErr\tMeanSqrErr\t', ...
        	'SurplusDptchInt\tMeanDptchSurplus\tNormMeanDptchSurplus\t', ...
        	'DeficitDptchInt\tMeanDptchDeficit\tNormMeanDptchDeficit\n'] );
	end
end

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
ctrlwgt = '1^n';    % Description of weighting scheme over control horizon

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
    x0, zlb(1), zub(1), deltacntl, epsilon );

% Construct vector of set points (battery SOC and power dispatched to the 
% grid) for process outputs over the prediction horizon
spsoc = ones( n, 1 ) * x0;
sp = spsocpd( m, n, spsoc, sppd );

% Declare output matrix used to verify simulation results.  Columns: 
% e, p_{d}, sp[e], ref[p_{d}], p_{b+}, p_{b-}, p_{w}, w
Y = zeros( N, m+m+q+d );
% Initialise measures quantifying the deviation in power dispatched to the
% grid relative to scheduled power (set point)
dpcnt = 0;      % Dispatch interval count
surpcnt = 0;    % Dispatch interval surplus count (power dispatched > set point)
dfctcnt = 0;    % Dispatch interval deficit count (power dispatched < set point)
sumabserr = 0.0;    % Sum of absolute errors (MW)
sumsqrerr = 0.0;    % Sum of squared errors (MW)
sumsurp = 0.0;      % Sum of surplus power dispatched (MW)
sumdfct = 0.0;      % Sum of deficit power dispatched (MW)

% Define quadratic term of performance index (objective function of MIQP)
H = transpose(L)*Omega*L + lambda*Psi;
% Set type for each variable in the argument argument vector of MIQP
ctype = miqptype( q, d, n );
% Set multi-period optimisation indicator
if ( n > 1 ) multiprd = true; else multiprd = false; end
% Count of optimisation attempts where optimal solution not found
noptmcnt = 0;
for k = 1:N     % For each time step in simulation
    
    if ( mod( k, 10000) == 0 ) fprintf( 'Iteration #: %d\n', k ); end 

    % Define constraints on optimisation of the performance index
    [ G, h ] = miqpcstr( m, q, d, n, delta, eta, z0, pw, zlb, zub );
    % Define linear term of the performance index (obj func of MIQP)
    f = transpose(K*z0 - sp)*Omega*L;
    
    % Optimise performance index using quadratic programming
    [v, fval, exitflag, output] = cplexmiqp( ...
        H, f, G, h, [], [], [], [], [], [], [], ctype );
    % Check for optimization errors/ warnings in multi-period setting  
    if ( exitflag < 1 && n > 1 )
        % Optimal solution not found for n-period control horizon, so
        % attempt optimisation for single-period horizon
        multiprd = false;           % Single-period optimisation
        noptmcnt = noptmcnt + 1;    % Optimal solution not found count
        [ K1, L1 ] = mpckl( m, s, q, d, 1, A, B, C );
        [ lambda, Omega1, Psi1 ] = mpcwgt( m, q, d, 1, lambda, omega, psi );
        H1 = transpose(L1)*Omega1*L1 + lambda*Psi1;
        ctype1 = miqptype( q, d, 1 );
        [ G, h ] = miqpcstr( m, q, d, 1, delta, eta, z0, pw(1), zlb, zub );
        f = transpose(K1*z0 - sp(1:m)) * Omega1 * L1;
        [v, fval, exitflag, output] = cplexmiqp( ...
            H1, f, G, h, [], [], [], [], [], [], [], ctype1 );
    end
    % Check for optimization errors/ warnings
    if ( exitflag < 1 )
        fprintf( 'Error: Solver terminated with exitflag = %d ', exitflag );
        fprintf( 'at time step %d of simulation.\n', k);
        return; % Exit script
    end
    
    % Evaluate process outputs and control signals
    if ( multiprd )
        [ du, u, y, w ] = evalout( q, d, n, K, L, ulast, z0, v );
    else
        [ du, u, y, w ] = evalout( q, d, 1, K1, L1, ulast, z0, v );
        if ( n > 1 ) multiprd = true; end   % Optimisation for next iteration
    end
            
    % Accumulate statistics when set point for power dispatched to the grid
    % during the next dispatch interval exceeds zero
    if ( sp(2) > epsilon )
        dpcnt = dpcnt + 1;
        sumabserr = sumabserr + abs( y(2) - sp(2) );
        sumsqrerr = sumsqrerr + (y(2) - sp(2))^2;
    end
    % Accumulate statistics when power dispatched to the grid exceeds set point
    if ( y(2) > sp(2) + epsilon )
        surpcnt = surpcnt + 1;
        sumsurp = sumsurp + ( y(2) - sp(2) );
    end
    % Accumulate statistics when power dispatched to the grid falls below set point
    if ( y(2) + epsilon < sp(2) )
        dfctcnt = dfctcnt + 1;
        sumdfct = sumdfct + ( sp(2) - y(2) );
    end
    
    % Write output from simulation iteration to file
    measutck = datestr( measutc(k), 'yyyy-mm-dd HH:MM:SS' );
    measaetk = datestr( measaet(k), 'yyyy-mm-dd HH:MM:SS' );
    uigfutck = datestr( uigfutc(k), 'yyyy-mm-dd HH:MM:SS' );
    uigf5m = max( [0.0, uigf(k,1)] );
    pdsurp = max( [0.0, y(2)-sp(2)] );
    pddfct = max( [0.0, sp(2)-y(2)] );
    fprintf( simfid, ...
'%s\t%s\t%s\t%s\t%.6f\t%.6f\t%d\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%.6f\t%d\n', ...
        duid, measutck, measaetk, uigfutck, y(2), sp(2), w(1), u(1), u(2), ...
        y(1), u(3), uigf5m, pdsurp, pddfct, sdcmeas(k) );

    % Reset variables for next simulation iteration
    x0 = y(1);
    ulast = u(1:q);
    z0 = [ x0; ulast ];
    if ( k < N )
        [ pw, sppd ] = wppsppd( n, uigf(k+1,:), pwmeas(k+1), sdcmeas(k+1), ...
            sppd, x0, zlb(1), zub(1), deltacntl, epsilon );
        spsoc = ones( n, 1 ) * x0;
        sp = spsocpd( m, n, spsoc, sppd );
    end

end

% Calculate summary statistics for simulation run
mae = sumabserr / dpcnt;        % Mean absolute error
nmae = mae / windcap * 100;     % Normalised mean absolute error
mse = sumsqrerr / dpcnt;        % Mean squared error       	
msurp = sumsurp / surpcnt;      % Mean surplus power dispatched
nmsurp = msurp / windcap * 100; % Normalised mean surplus power dispatched
mdfct = sumdfct / dfctcnt;      % Mean deficit power dispatched
nmdfct = mdfct / windcap * 100; % Normalised mean deficit power dispatched

% Write simulation results to file
fprintf( rsltfid, ...
    '%s\t%d\t%d\t%f\t%f\t%f\t%s\t%d\t%f\t%f\t%f\t%d\t%f\t%f\t%d\t%f\t%f\n', ...
    duid, N, n, windcap, battcap, battrt, ctrlwgt, dpcnt, mae, nmae, mse, ...
    surpcnt, msurp, nmsurp, dfctcnt, mdfct, nmdfct );

% Close simulation output and results files
fclose( simfid );
fclose( rsltfid );

% Write to terminal the number of iterations for which the multi-period
% optimal solution was not found by the MIQP solver
fprintf( 'Multi-period optimal solution not found count: %d\n', noptmcnt );
% Measure elapsed time for execution of program
timeelap = toc( timesta );  
fprintf( 'Elapsed time: %.1f seconds\n', timeelap );
% Clear workspace for next simulation run
clear;