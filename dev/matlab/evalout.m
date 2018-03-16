function [ du, u, y, w ] = evalout( q, d, n, K, L, ulast, z0, v )
% Evaluates process outputs and control signals from optimal argument 
% vector (i.e., control increments and dummy variables) returned by
% quadratic program for wind power dispatch with battery energy storage. 

    A = zeros( q*n, q );
    for i = 0:n-1
        A(i*q+1:i*q+q,1:q) = eye( q );
    end

    B = zeros( q*n, q*n ); 
    for i = 0:n-1
        j = 0;
        while ( j <= i )
            B(i*q+1:i*q+q,j*q+1:j*q+q) = eye( q );
            j = j + 1;
        end
    end

    % Format dummy variables and control increments, and evaluate control 
    % signals and process outputs
    du = v(1:q*n);              % Control increments
    u = A*ulast + B*v(1:q*n);   % Control signals
    y = K*z0 + L*v;             % Process outputs
    w = v(q*n+1:q*n+d*n);       % Dummy variables

end

