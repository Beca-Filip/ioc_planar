function filteredData = qualisysFilterGaps(dataArray, maxLen, arFiltOrder, dim)
%QUALISYSFILTERGAPS Fills gaps in Qualisys motion capture data using a combination of NaN replacement and gap filling.
%
%   This function identifies gaps in the input data array by detecting zero values, which are typical indicators of missing data points in Qualisys systems.
%   It replaces these zero values with NaNs and then applies a gap filling algorithm to interpolate the missing data.
%
%   Syntax:
%       filteredData = qualisysFilterGaps(dataArray, maxLen, arFiltOrder, dim)
%
%   Inputs:
%       dataArray    - The input data array (e.g., trajectory data from Qualisys).
%       maxLen       - The maximum length in samples of the regions immediately before and after each gap to consider when performing autoregressive estimation.
%       arFiltOrder  - The order of the autoregressive filter used in the gap filling process.
%       dim          - The dimension along which to apply the gap filling.
%
%   Outputs:
%       filteredData - The data array with gaps filled.
%
%   Detailed Description:
%       1.  Identifies gaps: Replaces all zero values in the input 'dataArray' with NaN.
%       2.  Applies gap filling: Utilizes the 'fillgaps' function with specified 'maxLen' and 'arFiltOrder' to interpolate the NaN values.
%       3.  Dimension handling: Applies the gap filling along the specified dimension 'dim' using the 'filterData' function.
%
%   Example:
%       % Assume 'trajectoryData' is a 3D array of Qualisys trajectory data.
%       maxRegionLength = 10;
%       filterOrder = 2;
%       dimensionToFilter = 2; % Example: filter along the time dimension.
%       filteredTrajectory = qualisysFilterGaps(trajectoryData, maxRegionLength, filterOrder, dimensionToFilter);
%
%   See also: FILLGAPS, FILTERDATA
    dataArray(dataArray == 0) = nan;
    % Make filter and filter function
    filterFunction = @(x) fillgaps(x, maxLen, arFiltOrder);
    filteredData = filterData(filterFunction, dataArray, dim);
end