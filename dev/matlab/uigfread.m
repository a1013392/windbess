function F = uigfread( uigffile )
% Reads input file containing 5-minute pre-dispatch unconstrained 
% intermittent generation forecasts (UIGF) and dispatch data.  The function
% returns UIGF forecasts and dispatch data, measured in kW, for each 
% 5-minute dispatch interval in the simulation horizon.  

    fid = fopen( uigffile, 'r' );
    format = ...
        ['%s', repmat('%{yyyy-MM-dd HH:mm:ss}D',1,2), repmat('%f',1,26), '%d'];
    F = textscan( fid, format, 'Delimiter', '\t' );
    fclose( fid );

end

