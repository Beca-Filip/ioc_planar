function Markers = qualisysTable2Markers(data, markerNames)
    % Check if markerNames is a string array or a cell array of chars/strings
    if ~isstring(markerNames) && ~iscellstr(markerNames)
        error('markerNames must be a string array or a cell array of chars/strings.');
    end
    % If markerNames is a cell array of chars or strings, convert it to a string array
    if iscellstr(markerNames)
        markerNames = string(markerNames);
    end

    Markers = zeros(0, 0, 1); % Initialize output array
    for markerName = markerNames
        columnNames = strcat(markerName, ["_pos_X", "_pos_Y", "_pos_Z"]); % Construct column names
        markerData = data(:, columnNames); % Extract data for the current marker
        markerArray = table2array(markerData); % Convert table to array
        Markers = cat(3, Markers, markerArray); % Concatenate along the 3rd dimension
    end
end