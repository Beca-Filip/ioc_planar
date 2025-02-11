function plotHandleCellArray = animateAggregation(ii, animationFunctionCellArray)
    
    plotHandleCellArray = cell(size(animationFunctionCellArray));
    for n = 1 : length(animationFunctionCellArray)
        plotHandleCellArray{n} = animationFunctionCellArray{n}(ii);
    end
end