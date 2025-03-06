function Forces = amtiTable2Forces(forceplateData, forceplateIdcs)
    % Check if forceplateIdcs is numeric
    if ~isnumeric(forceplateIdcs)
        error('forceplateIdcs must be an array of indices.');
    end

    Forces = zeros(0, 0, 1); % Initialize output array
    for forceplateIdx = forceplateIdcs
        columnNames = strcat(["forceX_", "forceY_", "forceZ_", "momentX_", "momentY_", "momentZ_"], string(forceplateIdx)); % Construct column names
        forceData = forceplateData(:, columnNames); % Extract data for the current forceplate
        forceArray = table2array(forceData); % Convert table to array
        Forces = cat(3, Forces, forceArray); % Concatenate along the 3rd dimension
    end
end