function [ wpp, sppd ] = wppsppd( ...
    k, n, F, sppd, soc, socmin, socmax, windcap, nmae )
% Determines wind power predictions and set points, measured in MW, from  
% unconstrained intermittent generation forecasts (UIGF).  UIGF forecasts 
% in cell array F are reported in kW.

    epsilon = 1e-12;
    nowind = false;
    uigfcol = 4;        % UIGF start column of cell array F
    wpp = zeros(n,1);   % Initialise predicted wind power vector
    
    % Advance set points one 5-minute dispatch interval
    sppd(1:n-1) = sppd(2:n);
    
    for j = 1:n
        % Set predicted wind power to UIGF forecasts (converted to MW)
        wpp(j) = max( [0.0, F{1,j+uigfcol-1}(k) / 1000.0 ] );
        % Check that wind power is forecast over prediction/control horizon.
        % UIGF forecasts are produced every 5 minutes (frequency) and valid 
        % for the 5-minute interval (resolution) ending at the n*5-minute
        % horizon
        if ( wpp(j) < epsilon ) nowind = true; end   
    end
    
    % Non-zero set point is assigned to power dispatched to the grid if
    % wind forecasts greater than zero over prediction/control horizon
    if ( nowind )
        sppd(n) = 0.0;
    else
        socmid = ( socmin + socmax ) / 2.0;
        % Fix power dispatched set point to predicted wind power at end of
        % prediction/control horizon if battery SOC exceeds threshold.
        % Otherwise, fix power dispatched set point to a fraction of the 
        % predicted wind power which depends on normalised mean absolute
        % error
        if ( soc - epsilon > socmid )
            sppd(n) = wpp(n);
        else
            wppdelta = windcap * nmae * (socmid-soc) / (socmid - socmin);
            sppd(n) = max( [0.0, wpp(n) - wppdelta ] );
        end
    end
    
return

