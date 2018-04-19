function [ wpp, sppd ] = wppsppd( ...
    n, uigf, pw, sdc, sppd, soc, socmin, socmax, deltacntl, epsilon )
% Determines wind power predictions and set points, measured in MW, from  
% unconstrained intermittent generation forecasts (UIGF). 

    nowind = false;
    wpp = zeros(n,1);   % Initialise predicted wind power vector
    
    % Advance set points one 5-minute dispatch interval
    sppd(1:n-1) = sppd(2:n);
    % Fix (predicted) wind power for current dispatch interval to actual 
    % (SCADA measured) wind power (converted to MW)
    wpp(1) = max( [0.0, pw] );
    
    for j = 2:n
        % Set predicted wind power to UIGF forecasts (converted to MW)
        wpp(j) = max( [0.0, uigf(j)] );
        % Check that wind power is forecast over prediction/control horizon.
        % UIGF forecasts are produced every 5 minutes (frequency) and valid 
        % for the 5-minute interval (resolution) ending at the n*5-minute
        % horizon
%       if ( wpp(j) < epsilon ) nowind = true; end   
    end
    
    % Non-zero set point is assigned to power dispatched to the grid if
    % wind forecast greater than zero at the prediction/control horizon
    if ( wpp(n) < epsilon )
        sppd(n) = 0.0;
    else
        socmid = ( socmin + socmax ) / 2.0;
        % Fix power dispatched set point to predicted wind power at end of
        % prediction/control horizon if battery SOC equals or exceeds
        % threshold.  Otherwise, fix power dispatched set point to some 
        % fraction of the predicted wind power.  Note that if
        % soc = socmax = socmid = socmin = 0, then sppd(n) is set to wpp(n)
        if ( soc > socmid - epsilon )
            sppd(n) = wpp(n);
        else
            wppdelta = deltacntl * (socmid - soc) / (socmid - socmin);
            sppd(n) = max( [0.0, wpp(n) - wppdelta ] ); 
        end
    end
    
    % If set point for power dispatched to the grid for current dispatch
    % interval has been set to zero, then reset wind power for current 
    % dispatch interval to zero.  Accordingly battery SOC will not change 
    % during current dispatch interval
    if ( sppd(1) < epsilon ) wpp(1) = 0.0; end
    % If semi dispatch cap (0 or 1) for current dispatch interval is on,
    % then set wind power and power dispatched set point for current
    % dispatch interval to zero
    if ( sdc > epsilon )
       wpp(1) = 0.0;
       sppd(1) = 0.0; 
    end
    
return

