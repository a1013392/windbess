function [ G, h ] = miqpcstr( m, q, d, n, delta, eta, z0, pw, zlb, zub )
% Defines constraints on the mixed integer quadratic program that optimises 
% the performance index of the state-space MPC controller governing wind
% power dispatch with battery energy storage.  Contraints take the form of
% G*x <= h, where G is a matrix of constraint coefficients, x is the 
% argument vector, and h is a vector of constraint thresholds.

    % delta = conversion factor from MW to MWh for given dispatch interval
    % eta = One-way battery charge/discharge efficiency
    % z0 = [ e(t); p_{b+}(t-1);  p_{b-}(t-1);  p_{w}(t-1) ]
    % zlb = lower bounds on [ e; p_{b+};  p_{b-};  p_{w} ]
    % zub = upper bounds on [ e; p_{b+};  p_{b-};  p_{w} ]
    % Note that there is a binary (dummy) variable, indicating whether the
    % battery is charging, for each time interval in the control horizon

    % State of charge of the battery
    g1 = [ delta*eta -delta/eta 0 ];
    G1 = zeros( 2*n, q*n+d*n );
    h1 = zeros( 2*n, 1 );
    for i = 0:n-1
        j = 0;
        while ( j <= i )
            G1(i+1,j*q+1:j*q+q) = (i-j+1) * g1;
            G1(n+i+1,j*q+1:j*q+q) = -(i-j+1) * g1;
            j = j + 1;
        end
        h1(i+1) = zub(1) - z0(1) + ...
            (i+1) * ( delta/eta*z0(3) - delta*eta*z0(2) );
        h1(n+i+1) = z0(1) - zlb(1) + ...
            (i+1) * ( delta*eta*z0(2) - delta/eta*z0(3) );
    end
    % Battery charge rates
    g2 = [ 1 0 0 ];
    G2 = zeros( 2*n, q*n+d*n );
    h2 = zeros( 2*n, 1 );
    for i = 0:n-1
        j = 0;
        while ( j <= i )
            G2(i+1,j*q+1:j*q+q) = g2;
            G2(n+i+1,j*q+1:j*q+q) = -g2;
            j = j + 1;
        end
        h2(i+1) = zub(2) - z0(2);
        h2(n+i+1) = z0(2) - zlb(2);
    end
    % Battery discharge rate
    g3 = [ 0 1 0 ];
    G3 = zeros( 2*n, q*n+d*n );
    h3 = zeros( 2*n, 1 );
    for i = 0:n-1
        j = 0;
        while ( j <= i )
            G3(i+1,j*q+1:j*q+q) = g3;
            G3(n+i+1,j*q+1:j*q+q) = -g3;
            j = j + 1;
        end
        h3(i+1) = zub(3) - z0(3);
        h3(n+i+1) = z0(3) - zlb(3);
    end
    % Wind power is set to unconstrained intermittent generation forecast
    % determined by the Australian Wind Energy Forecasting System
    g4 = [ 0 0 1 ];
    G4 = zeros( 2*n, q*n+d*n );
    h4 = zeros( 2*n, 1 );
    for i = 0:n-1
        j = 0;
        while ( j <= i )
            G4(i+1,j*q+1:j*q+q) = g4;
            G4(n+i+1,j*q+1:j*q+q) = -g4;
            j = j + 1;
        end
        h4(i+1) = pw(i+1) - z0(4);
        h4(n+i+1) = z0(4) - pw(i+1);
    end
    % Binary variable, two constraints: pbc(t+k-1) <= ub[pbc] * w(k)
    %                                   pbd(t+k-1) <= ub[pbd] * (1 - w(k))
    g5 = [ 1 0 0; 0 1 0 ];
    gw = [-zub(2); zub(3)];
    hw = [ -z0(2); zub(3)-z0(3) ];
    G5 = zeros( 2*n, q*n+d*n );
    h5 = zeros( 2*n, 1 );
    for i = 0:n-1
        j = 0;
        while ( j <= i )
            G5(2*i+1:2*i+2,j*q+1:j*q+q) = g5;
            j = j + 1;
        end
        G5(2*i+1:2*i+2,n*q+d*i+1:n*q+d*i+d) = gw;
        h5(2*i+1:2*i+2) = hw;
    end

    % Concatenate constraint coefficients and thresholds
    G = [ G1; G2; G3; G4; G5 ];
    h = [ h1; h2; h3; h4; h5 ];

end

