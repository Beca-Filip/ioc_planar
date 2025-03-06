function [segmentLenghts, segmentNames] = qualisysGetSegmentLengths(Markers, markerNames, parentMap)

    segmentLenghts = zeros(size(Markers, 1), length(parentMap));
    segmentNames = strings(1, length(parentMap));

    for n = 1 : length(parentMap)
        segmentLenghts(:, n) = sum((Markers(:, :, n) - Markers(:, :, parentMap(n))).^2, 2);
        segmentNames(n) = strcat(markerNames(n), " to ", markerNames(parentMap(n)));
    end
end