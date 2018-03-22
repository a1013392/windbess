function [ N, duid, uigfutc, uigf, measutc, measaet, pwmeas, sdcmeas ] = ...
    uigfread( uigffile )
% Reads input file containing 5-minute pre-dispatch unconstrained 
% intermittent generation forecasts (UIGF) and measured (SCADA) data.  For
% each 5-minute dispatch interval in the simulation horizon, the file
% reports power in kW.  Power is converted to MW and returned in numeric
% arrays.
  
    uigffid = fopen( uigffile, 'r' );
    format = ['%s', repmat('%{yyyy-MM-dd HH:mm:ss}D',1,2), repmat('%f',1,24), ...
        repmat('%{yyyy-MM-dd HH:mm:ss}D',1,2), '%f%f%d'];
    U = textscan( uigffid, format, 'Delimiter', '\t' );
    fclose( uigffid );
    
    % Determine number of dispatch interval in simulation horizon
    N = size( U{1,1},1 );
    % Identify DUID (Dispatchable Unit IDentifier) for simulation
    duid = char( U{1,1}(1) );
    % Convert prediction time (UTC) to datetime array
    uigfutc = datetime( U{1,2} );
    % Convert UIGF forecasts to float array
    uigf = cell2mat( U(1,4:27) ) / 1000.0;
    % Convert dispatch interval end time (UTC) to datetime array
    measutc = datetime( U{1,28} );
    % Convert dispatch interval end time (AEST/AEDT) to datetime array
    measaet = datetime( U{1,29} );
    % Convert measured (SCADA) wind power to float array
    pwmeas = cell2mat( U(1,30) ) / 1000.0;
    % Convert semi-dispatch cap to integer array
    sdcmeas = cell2mat( U(1,32) );

return

