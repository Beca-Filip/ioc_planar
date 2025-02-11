function plotHandles = amtiPlotTrajectories(data, varargin)
    plotHandles = [];
    for ii = 1:6
        subplot(6, 1, ii)
        hold on;
        plotHandles(end+1) = plot( table2array(data(:, ii)), 'DisplayName', data.Properties.VariableNames{ii}, varargin{:});
        plotHandles(end+1) = plot(table2array(data(:, ii+6)).', 'DisplayName', data.Properties.VariableNames{ii+6}, varargin{:});
        % plotHandles(end+1) = plot(table2array(data(:, ii+3)).', 'DisplayName', data.Properties.VariableNames{ii+3}, varargin{:});
        legend('Location', 'northeast');
    end
end