function qualisysPlotSelectMarkersCoordinates(timeVector, Markers, markerNames, toPlotMarkerNames, varargin)
    nTotal = length(markerNames);
    nPlot = length(toPlotMarkerNames);
    selectIdx = zeros(nPlot, 1, "int64");
    
    for nMarker = 1 : nPlot
        toPlotMarker = toPlotMarkerNames(nMarker);
        selectIdxRow = strcmp(markerNames, toPlotMarker);
        selectIdx(nMarker) = find(selectIdxRow);
    end
    
    % Reselect markers
    Markers = Markers(:, :, selectIdx);
    markerNames = markerNames(selectIdx);

    % Call function that plots all markers
    qualisysPlotAllMarkersCoordinates(timeVector, Markers, markerNames, varargin{:});

end