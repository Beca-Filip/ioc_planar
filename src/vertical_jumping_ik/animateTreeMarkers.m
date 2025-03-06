function plotHandles = animateTreeMarkers(ii, plotHandles, Markers, parentMap, varargin)
    if isempty(plotHandles)
        plotHandles = gobjects(length(parentMap), 1);
        for n = 1 : length(parentMap)
            plotHandles(n) = ...
            plot3( ...
                squeeze(Markers(ii, 1, [n, parentMap(n)])), ...
                squeeze(Markers(ii, 2, [n, parentMap(n)])), ...
                squeeze(Markers(ii, 3, [n, parentMap(n)])), ...
                varargin{:} ...
            );
        end
    else
        for n = 1 : length(parentMap)
            plotHandles(n).XData = Markers(ii, 1, [n, parentMap(n)]);
            plotHandles(n).YData = Markers(ii, 2, [n, parentMap(n)]);
            plotHandles(n).ZData = Markers(ii, 3, [n, parentMap(n)]);
        end
    end
end