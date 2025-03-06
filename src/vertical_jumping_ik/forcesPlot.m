function plotHandles = forcesPlot(Forces, timeArray, varargin)
    if size(Forces, 2) ~= 6 || ndims(Forces) > 3
        error("forcesPlot: Forces must be Tx6xN.");
    end
    % If only one time sample, duplicate
    if size(Forces, 1) == 1
        Forces = repmat(Forces, [2, ones(1, ndims(Forces)-1)]);
    end
    if nargin < 2
        timeArray = linspace(0, 1, size(Forces, 1));
    end
    % preliminaries
    colors = linspecer(size(Forces, 3));
    dimNames = horzcat(strcat("$f_", ["x", "y", "z"], "$"), strcat("$m_", ["x", "y", "z"], "$"));

    % plot
    tl = tiledlayout(6, 1, "TileSpacing", "tight");
    plotHandles = gobjects(size(Forces, [2, 3]));
    for ii = 1:6
        nexttile(tl, ii);
        hold on;
        for jj = 1:size(Forces,3)
            plotHandles(ii, jj) = plot(timeArray, reshape(Forces(:, ii, jj), [], 1), 'Color', colors(jj, :), 'DisplayName', sprintf("$%d$", jj), varargin{:});
        end
        ylabel(dimNames(ii), "Interpreter", "latex", "FontSize", 15, "Rotation", 0);
        if ii == 6
            leg = legend("Location", "northeast", "Interpreter", "latex");
            leg.Position(1) = leg.Position(1) + 0.05; 
        end
    end
end