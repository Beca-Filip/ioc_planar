function qualisysPlotSegmentLengths(timeVector, segmentLenghts, segmentNames, varargin)
    n = length(segmentNames);
    xaxlim = [min(timeVector), max(timeVector)];
    
    %%%%% Tiled layout checks
    % Check if a tiled layout already exists on the current figure
    fig = gcf;
    tiledLayoutExists = false;
    if ~isempty(fig.Children)
        for i = 1:length(fig.Children)
            if isa(fig.Children(i), 'matlab.graphics.layout.TiledChartLayout')
                tiledLayoutExists = true;
                tiledLayout = fig.Children(i);
                break;
            end
        end
    end

    if tiledLayoutExists
        % Check if the existing layout has the correct size [n, 3]
        if tiledLayout.GridSize(1) ~= n || tiledLayout.GridSize(2) ~= 1
            error('Existing tiled layout does not match the required size [%d, 1].', n);
        end
    else
        % Create a new tiled layout
        tiledLayout = tiledlayout(n, 1, "TileSpacing", "tight");
    end
    %%%%%

    for nSegment = 1 : n
        
        axx = nexttile(tiledLayout, nSegment); hold on;
        plot(timeVector, reshape(segmentLenghts(:, nSegment), size(timeVector)), varargin{:});
        xlim(xaxlim);
        ylabel(strrep(segmentNames(nSegment), "_", "\_"), "Rotation", 0, "Interpreter", "latex");
        
        if nSegment == 1
            title("$L$", "Interpreter", "latex");
        end
        if nSegment == n
            xlabel("$t$ [s]", "Interpreter", "latex");
        else
            set(gca, "XTick", []);
        end        
    end
end