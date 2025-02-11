function data = qualisysReadTSV(fpath)
    % Inital table read has an erroneously detected 1st column:
    % The last column is full of nans.
    data = readtable(fpath, "FileType", "text", 'Delimiter', '\t');

    % Convert to array and remove last column full of nans
    array = table2array(data);
    array = array(:, 1:end-1);
    % Convert back to table with the original column names (except the first one)
    data = array2table(array, 'VariableNames', data.Properties.VariableNames(2:end));
end