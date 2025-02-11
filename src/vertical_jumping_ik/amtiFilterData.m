function data = amtiFilterData(data, samplingFreq, filterFreq, filterOrder)
    if nargin < 2; samplingFreq = 1000; end
    if nargin < 3; filterFreq = samplingFreq / 10; end
    if nargin < 4; filterOrder = 5; end
    
    [bFilt, aFilt] = butter(filterOrder, 2 * filterFreq / samplingFreq, "low");
    for n = 1 : size(data, 2)
        data(:, n) = array2table(filtfilt(bFilt, aFilt, table2array(data(:, n))), "VariableNames", data.Properties.VariableNames(n));
    end
end