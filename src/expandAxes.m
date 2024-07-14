function expandAxes(factor)
    % Validate input
    if nargin < 1
        error('A factor must be provided.');
    elseif ~isnumeric(factor) || factor <= 0
        error('Factor must be a positive number.');
    end

    % Get current axis limits
    xLimits = xlim;
    yLimits = ylim;

    % Calculate the range
    xRange = xLimits(2) - xLimits(1);
    yRange = yLimits(2) - yLimits(1);

    % Calculate the expansion
    newXRange = xRange * factor;
    newYRange = yRange * factor;

    % Calculate the new limits
    newXLimits = [mean(xLimits) - newXRange / 2, mean(xLimits) + newXRange / 2];
    newYLimits = [mean(yLimits) - newYRange / 2, mean(yLimits) + newYRange / 2];

    % Set the new limits
    xlim(newXLimits);
    ylim(newYLimits);
end
