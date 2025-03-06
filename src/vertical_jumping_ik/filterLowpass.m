function filteredData = filterLowpass(dataArray, samplingFreq, filterFreq, filterOrder, dim)
    % Make filter and filter function
    [bFilt, aFilt] = butter(filterOrder, 2 * filterFreq ./ samplingFreq, "low");
    filterFunction = @(data1dArray) filtfilt(bFilt, aFilt, data1dArray);
    % Filter
    filteredData = filterData(filterFunction, dataArray, dim);
end