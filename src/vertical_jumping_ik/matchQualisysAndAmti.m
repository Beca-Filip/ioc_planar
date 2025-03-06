function [ForcesTruncated, MarkersTruncated] = matchQualisysAndAmti(Forces, Markers, numRestSamples, amtiFreq, qualisysFreq)

    % Estimate the mass and weight from vertical forces of the forceplates
    gravity = 9.81;
    totalVerticalForce = squeeze(sum(Forces(:, 3, :), 3));
    totalWeightForce = median(totalVerticalForce(1:numRestSamples), 1);

    massEstimate = totalWeightForce ./ gravity;
    fprintf("matchQualisysAndAmti: subject mass estimate is %.2f.\n", massEstimate);

    % Center forces
    centeredVerticalForce = totalVerticalForce - totalWeightForce;
    comVerticalAcceleration = centeredVerticalForce ./ gravity;

    % Find the index where the CoM position is the maximal given forceplate
    % measurements (integrate twice)
    [numSamplesForceplate, ~] = size(comVerticalAcceleration);
    comVerticalVelocity = cumsum(comVerticalAcceleration, 1)./amtiFreq;
    comVerticalPosition = cumsum(comVerticalVelocity, 1)./amtiFreq;
    [comMaxVerticalPosition, timeIdxComMaxVerticalPosition] = max(comVerticalPosition, [], 1);
    fprintf("matchQualisysAndAmti: maximum center of mass height from forceplate %.2f at time index %d.\n", comMaxVerticalPosition, timeIdxComMaxVerticalPosition);

    criticalTimeIdxForceplate = timeIdxComMaxVerticalPosition;

    % Find the index where the CoM position is the maximal given marker
    % measurements (assume CoM is moving as all the markers)
    [numSamplesMarkers, ~, numChannelsMarkers] = size(Markers); 
    markerVerticalPositions = squeeze(Markers(:, 3, :));
    markerMaxVerticalPositions = max(markerVerticalPositions, [], 1);

    medianTimeIdxMarkerMaxVerticalPositions = find(markerMaxVerticalPositions == markerVerticalPositions);
    [timeIdxMarkerMaxVerticalPositions, ~] = ind2sub(size(markerVerticalPositions), medianTimeIdxMarkerMaxVerticalPositions);

    medianTimeIdxMarkerMaxVerticalPositions = round(median(timeIdxMarkerMaxVerticalPositions));

    fprintf("matchQualisysAndAmti: maximum marker height from markers are at median time index %d.\n", medianTimeIdxMarkerMaxVerticalPositions);
    fprintf("matchQualisysAndAmti: maximum marker heights are %s.\n", sprintf("%.2f, ", markerMaxVerticalPositions));
    
    criticalTimeIdxMarkers = medianTimeIdxMarkerMaxVerticalPositions;

    % The index of both time sources corresponds to time 0
    criticalTimeForceplate = (criticalTimeIdxForceplate-1)./amtiFreq;
    criticalTimeMarkers = (criticalTimeIdxMarkers-1)./qualisysFreq;
    fprintf("matchQualisysAndAmti: perceived critical times are %.2f s (forceplate) and %.2f s (markers), difference: %.2f s.\n", criticalTimeForceplate, criticalTimeMarkers, abs(criticalTimeForceplate-criticalTimeMarkers));

    timeForceplate = linspace(0, (numSamplesForceplate-1)./amtiFreq, numSamplesForceplate) - criticalTimeForceplate;
    timeMarkers = linspace(0, (numSamplesMarkers-1)./qualisysFreq, numSamplesMarkers) - criticalTimeMarkers;

    overlapStart = max(timeForceplate(1), timeMarkers(1));
    overlapEnd = min(timeForceplate(end), timeMarkers(end));

    forceplateMask = (timeForceplate >= overlapStart) & (timeForceplate <= overlapEnd);
    markersMask = (timeMarkers >= overlapStart) & (timeMarkers <= overlapEnd);

    % Truncate
    timeForceplateTruncated = timeForceplate(forceplateMask);
    ForcesTruncated = Forces(forceplateMask, :, :);

    markerTimeTruncated = timeMarkers(markersMask);
    MarkersTruncated = Markers(markersMask, :, :);

    targetTime = markerTimeTruncated;

    ForcesTruncated = interp1(timeForceplateTruncated, ForcesTruncated, targetTime, 'spline', 'extrap');
    %% Quality Checks
    if isempty(ForcesTruncated) || isempty(MarkersTruncated)
        error('No overlapping time window found between datasets');
    end
end