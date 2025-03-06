function filteredData = filterData(filterFunction, dataArray, dim)
    %FILTERDATA Apply a filter function along a specified dimension of a multidimensional array.
    %
    %   FILTERDATA is a practical tool for applying filters to a multidimensional (or N-D) array along a specified dimension,
    %   often used for time-series data or similar applications where filtering should be performed along a particular axis.
    %
    %   filteredData = FILTERDATA(filterFunction, dataArray, dim) applies the
    %   function specified by the function handle `filterFunction` along the
    %   dimension `dim` of the input array `dataArray`. The result is returned
    %   as `filteredData`.
    %
    %   Inputs:
    %       filterFunction - A function handle that defines the filter to apply.
    %                        This function must accept a vector or array along
    %                        the specified dimension and return a filtered
    %                        vector or array of the same size.
    %       dataArray      - The input data array to be filtered. Can be an
    %                        array of any dimensionality (e.g., 1D, 2D, 3D, etc.).
    %       dim            - The dimension along which the filter is applied.
    %                        For example, if dim = 1, the filter is applied
    %                        along the rows.
    %
    %   Output:
    %       filteredData  - The filtered array, with the same size as `dataArray`.
    %
    %   Example:
    %       % Apply a moving average filter along the rows of a 2D matrix
    %       data = rand(10, 5); % 10x5 matrix
    %       movAvg = @(x) movmean(x, 3); % Moving average filter
    %       filteredData = filterData(movAvg, data, 1); % Apply along rows
    %
    %   See also: FUNCTION_HANDLE, IND2SUB, SIZE, PROD.

    % Determine the size of the input array
    dataSize = size(dataArray);
    
    % Remove the dimension along which the filter is applied
    dataNontimeSize = dataSize;
    dataNontimeSize(dim) = [];
    
    % Calculate the total number of elements in non-time dimensions
    dataNontimeElements = prod(dataNontimeSize);
    
    % Initialize the output array
    filteredData = dataArray;
    
    % Loop through all elements in non-time dimensions
    for elemIdx = 1 : dataNontimeElements
        % Get the subscripts for the current element
        elemSub = cell(1, numel(dataNontimeSize));
        [elemSub{:}] = ind2sub(dataNontimeSize, elemIdx);
        
        % Create a cell array to hold the indices for each dimension
        idx = cell(1, ndims(dataArray));
        
        % Fill the indices for non-time dimensions
        idx(1:dim-1) = elemSub(1:dim-1);
        idx(dim+1:end) = elemSub(dim:end);
        
        % Apply the filter along the time dimension
        idx{dim} = ':';
        filteredData(idx{:}) = filterFunction(dataArray(idx{:}));
    end
end