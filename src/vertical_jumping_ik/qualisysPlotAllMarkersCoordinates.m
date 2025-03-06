function qualisysPlotAllMarkersCoordinates(timeVector, Markers, markerNames, varargin)
    n = length(markerNames);
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
        if tiledLayout.GridSize(1) ~= n || tiledLayout.GridSize(2) ~= 3
            error('Existing tiled layout does not match the required size [%d, 3].', n);
        end
    else
        % Create a new tiled layout
        tiledLayout = tiledlayout(n, 3, "TileSpacing", "tight");
    end
    %%%%%

    for nMarker = 1 : n
        
        % subplot(n, 3, (nMarker - 1)*3 + 1)
        axx = nexttile(tiledLayout, (nMarker - 1)*3 + 1); hold on;
        plot(timeVector, reshape(Markers(:, 1, nMarker), size(timeVector)), varargin{:});
        xlim(xaxlim);
        ylabel(strrep(markerNames(nMarker), "_", "\_"), "Rotation", 0, "Interpreter", "latex");
        
        if nMarker == 1
            title("$X$", "Interpreter", "latex");
        end
        if nMarker == n
            xlabel("$t$ [s]", "Interpreter", "latex");
        else
            set(gca, "XTick", []);
        end

        % subplot(n, 3, (nplot - 1)*3 + 2)
        axy = nexttile(tiledLayout, (nMarker - 1)*3 + 2); hold on;
        plot(timeVector, reshape(Markers(:, 2, nMarker), size(timeVector)), varargin{:});
        xlim(xaxlim);

        if nMarker == 1
            title("$Y$", "Interpreter", "latex");
        end
        if  nMarker == n
            xlabel("$t$ [s]", "Interpreter", "latex");
        else
            set(gca, "XTick", []);
        end
        
        % subplot(n, 3, (nplot - 1)*3 + 3)
        axz = nexttile(tiledLayout, (nMarker - 1)*3 + 3); hold on;
        plot(timeVector, reshape(Markers(:, 1, nMarker), size(timeVector)), varargin{:});
        xlim(xaxlim);

        if nMarker == 1
            title("$Z$", "Interpreter", "latex");
        end
        if  nMarker == n
            xlabel("$t$ [s]", "Interpreter", "latex");
        else
            set(gca, "XTick", []);
        end
        
    end
end