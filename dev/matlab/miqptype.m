function [ ctype ] = miqptype( q, d, n )
% Returns a string identifying the type for each variable in the argument
% vector of the mixed integer quadratic program.  Control increments are 
% continuous ('C') and dummy variables are binary ('B').

    ctype = blanks( (q+d)*n );
    for k = 1:q*n
        ctype(k) = 'C';
    end
    for k = 1:d*n
        ctype(q*n+k) = 'B';
    end

return

