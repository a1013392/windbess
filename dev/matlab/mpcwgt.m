function [ lambda, Omega, Psi ] = mpcwgt( m, q, d, n, lambda, omega, psi  )
% Constructs weighting matrices Psi and Omega used to penalise tracking 
% error and control effort in optimisation of the performance index for
% state-space model predictive control (MPC).  The weighting coefficient 
% lambda, which is applied in the performance index, is simply returned to 
% the calling program.

    % Omega is a square matrix of dimension m process output variables 
    % times n intervals over the prediction horizon.
    Omega = zeros( m*n );
%     Omega(1:m,1:m) = diag( omega );
    for k = 0:n-1
%         Omega(k*m+1:k*m+m,k*m+1:k*m+m) = diag( omega ) / 2^k;
        Omega(k*m+1:k*m+m,k*m+1:k*m+m) = diag( omega );
    end

    % Psi is a square matrix of dimension q control increments times n 
    % intervals over the control horizon plus d dummy variables times n
    % intervals.
    Psi = zeros( q*n+d*n );
    for k = 0:n-1
        Psi(k*q+1:k*q+q,k*q+1:k*q+q) = diag( psi );
    end

return

