close all

fs = 300;
Ts = 1 ./ fs;
mocapFilePath = sprintf("mocap\\01_1_2_pos.tsv");
forceplateFilePath = sprintf("forceplate\\01_1_2.txt");
mocapData = qualisysReadTSV(mocapFilePath);
mocapData = qualisysConvertToMeters(mocapData);
markerNames = qualisysMarkerNamesFromTable(mocapData);
Markers = qualisysTable2Markers(mocapData, markerNames);

forceplateData = amtiReadTXT(forceplateFilePath);
forceplateData = amtiFilterData(forceplateData);

MarkersNan = Markers;
MarkersNan(MarkersNan == 0) = nan;
MarkersNoGaps = qualisysFilterGaps(Markers, 150, 2, 1);
MarkersFilt = filterLowpass(MarkersNoGaps, 300, 10, 5, 1);
dMarkers = diff(Markers, 1, 1) * fs;
ddMarkers = diff(Markers, 2, 1) * fs^2;
dMarkersFilt = diff(MarkersFilt, 1, 1) * fs;
ddMarkersFilt = diff(MarkersFilt, 2, 1) * fs^2;

timeVector = linspace(0., (size(mocapData, 1) - 1) * Ts, size(mocapData, 1));

parentStructMap = struct( ...
    "l_metatarsal", "l_ankle", ...
    "l_ankle", "l_knee", ...
    "l_knee", "l_hip", ...
    "l_hip", "r_hip", ...
    "l_shoulder", "l_hip", ...
    "l_elbow", "l_shoulder", ...
    "l_wrist", "l_elbow", ...
    "r_metatarsal", "r_ankle", ...
    "r_ankle", "r_knee", ...
    "r_knee", "r_hip", ...
    "r_hip", "r_shoulder", ...
    "r_shoulder", "l_shoulder", ...
    "r_elbow", "r_shoulder", ...
    "r_wrist", "r_elbow" ...    
);

parentMap = qualisysParentMapFromNamesAndStructure(markerNames, parentStructMap);

%%
figure('WindowState', 'maximized');
hold on;
qualisysPlotAllMarkersCoordinates(timeVector, Markers, markerNames, "LineWidth", 1);
qualisysPlotAllMarkersCoordinates(timeVector, MarkersFilt, markerNames, "r:", "LineWidth", 1);

%%
figure('WindowState', 'maximized');
hold on;
qualisysPlotSelectMarkersCoordinates(timeVector, Markers, markerNames, ["r_elbow", "l_elbow"]);
qualisysPlotSelectMarkersCoordinates(timeVector, MarkersFilt, markerNames, ["r_elbow", "l_elbow"], "r:", "LineWidth", 1);

%% 
figure('WindowState', 'maximized');
hold on;
qualisysPlotSelectMarkersCoordinates(timeVector(1:end-1), dMarkers, markerNames, ["r_elbow", "l_elbow"]);
qualisysPlotSelectMarkersCoordinates(timeVector(1:end-1), dMarkersFilt, markerNames, ["r_elbow", "l_elbow"], "r:", "LineWidth", 1);

figure('WindowState', 'maximized')
hold on;
qualisysPlotSelectMarkersCoordinates(timeVector(1:end-2), ddMarkers, markerNames, ["r_elbow", "l_elbow"]);
qualisysPlotSelectMarkersCoordinates(timeVector(1:end-2), ddMarkersFilt, markerNames, ["r_elbow", "l_elbow"], "r:", "LineWidth", 1);

%%

[segmentLenghts, segmentNames] = qualisysGetSegmentLengths(Markers, markerNames, parentMap);
[segmentLenghtsFilt, segmentNamesFilt] = qualisysGetSegmentLengths(MarkersFilt, markerNames, parentMap);

figure('WindowState', 'maximized');
hold on;
qualisysPlotSegmentLengths(timeVector, segmentLenghts, segmentNames, "LineWidth", 1);
qualisysPlotSegmentLengths(timeVector, segmentLenghtsFilt, segmentNamesFilt, "LineWidth", 1, "LineStyle", "--");
% qualisysPlotSegmentLengths(timeVector([1, end]), ones(2, 1) * median(segmentLenghts, 1), segmentNames, "LineWidth", 2, "LineStyle", ":");
% qualisysPlotSegmentLengths(timeVector([1, end]), ones(2, 1) * mean(segmentLenghts, 1), segmentNames, "LineWidth", 2, "LineStyle", "--");


%% Match forces and markers
Forces = amtiTable2Forces(forceplateData, 1:2);
[Forces, MarkersFilt] = matchQualisysAndAmti(Forces, MarkersFilt, round(size(Forces, 1) / 5), 1000, 300);

centersOfPressure = forces2Cop(Forces);
transformations2Qualisys = amtiFixedQualisysTransforms();
ForcesQualisys = forcesTransform(transformations2Qualisys, Forces);
centersOfPressureQualisys = vectorsTransform(transformations2Qualisys, centersOfPressure);

normalizedForcesQualisys = ForcesQualisys ./ mean(ForcesQualisys(1:round(size(ForcesQualisys, 1) / 10), 3, :), 1);
normalizedForcesQualisys(repmat(normalizedForcesQualisys(:, 3, :), [1, size(normalizedForcesQualisys, 2), 1]) < 1e-3) = nan;

%%
figure('WindowState', 'maximized');
hold on;
amtiPlotForceplates("LineStyle", "None", "FaceAlpha", .7);
plotHandlesHuman = animateTreeMarkers(1, [], MarkersFilt, parentMap, 'k', 'LineWidth', 2, 'Marker', 'o');
plotHandleCop = animatePoint(1, [], centersOfPressureQualisys, 100, [.3, .9, .3], 'filled');
plotHandleForce = animateForces(1, [], centersOfPressureQualisys, normalizedForcesQualisys, "LineWidth", 2, "Color", [.3, .9, .3]);

axlms = expandLimits([min(MarkersFilt, [], [1, 3]); max(MarkersFilt, [], [1, 3])], 1.2);
xlim(axlms(:, 1)); ylim(axlms(:, 2)); zlim(axlms(:, 3));
axis("equal");
view(33.5703, 22.6771);
axis("manual");
% hold on;

vidMkr = myVideoMaker(strcat(strrep(strrep(mocapFilePath, "mocap\", ""), ".tsv", "")), 30);
animationFunctionHuman = @(ii) animateTreeMarkers(ii, plotHandlesHuman, MarkersFilt, parentMap);
animationFunctionCop = @(ii) animatePoint(ii, plotHandleCop, centersOfPressureQualisys);
animationFunctionForce = @(ii) animateForces(ii, plotHandleForce, centersOfPressureQualisys, normalizedForcesQualisys);
animationFunctionJoined = @(ii) animateAggregation(ii, {animationFunctionHuman, animationFunctionCop, animationFunctionForce});

myAnimate(animationFunctionJoined, size(MarkersFilt, 1), round(1./300, 3), vidMkr, 30);