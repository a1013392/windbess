function [ sp ] = spsocpd( m, n, spsoc, sppd )
% Constructs the reference signal, or set point, vector against which the
% process output is benchmarked.  The performance index penalises the
% tracking error of the process outputs relative to the set points.

    % sp is a column vector of length m process output variables times n 
    % time periods over the prediction horizon.
    sp = zeros( m*n, 1 );
    for k = 0:n-1
        sp(k*m+1) = spsoc(k+1);
        sp(k*m+m) = sppd(k+1);
    end

return

