clear all
close all
clc

mocapFilePath = sprintf("mocap\\01_1_2_pos.tsv");
forceplateFilePath = sprintf("forceplate\\01_1_2.txt");
mocapData = qualisysReadTSV(mocapFilePath);
mocapData = qualisysConvertToMeters(mocapData);

jumpMarkerNames = ["metatarsal", "ankle", "knee", "hip", "shoulder", "elbow", "wrist"];

l_metatarsal = mocapData(:, ["l_metatarsal_pos_X", "l_metatarsal_pos_Y", "l_metatarsal_pos_Z"]);
l_ankle = mocapData(:, ["l_ankle_pos_X", "l_ankle_pos_Y", "l_ankle_pos_Z"]);
l_knee = mocapData(:, ["l_knee_pos_X", "l_knee_pos_Y", "l_knee_pos_Z"]);
l_hip = mocapData(:, ["l_hip_pos_X", "l_hip_pos_Y", "l_hip_pos_Z"]);
l_shoulder = mocapData(:, ["l_shoulder_pos_X", "l_shoulder_pos_Y", "l_shoulder_pos_Z"]);
l_elbow = mocapData(:, ["l_elbow_pos_X", "l_elbow_pos_Y", "l_elbow_pos_Z"]);
l_wrist = mocapData(:, ["l_wrist_pos_X", "l_wrist_pos_Y", "l_wrist_pos_Z"]);

l_metatarsal = table2array(l_metatarsal);
l_ankle = table2array(l_ankle);
l_knee = table2array(l_knee);
l_hip = table2array(l_hip);
l_shoulder = table2array(l_shoulder);
l_elbow = table2array(l_elbow);
l_wrist = table2array(l_wrist);

%%
Markers = qualisysPlanarJumpingMarkersL(mocapData);

dMarkers = diff(Markers, 1, 1);
mMarkers = mean(Markers, 1);
rMarkers = Markers - mMarkers;

colorMap = linspecer(size(Markers, 3));
figure("WindowState", "maximized");
hold on;
subplot(1, 2, 1);
hold on;
for nmarker = 1 : size(Markers, 3)
    scatter3( ...
        squeeze(rMarkers(:, 1, nmarker)), ...
        squeeze(rMarkers(:, 2, nmarker)), ...
        squeeze(rMarkers(:, 3, nmarker)), ...
        'DisplayName', sprintf("%d", nmarker), ...
        'Color', colorMap(nmarker) ...
    );
end
rMarkersMatrix = reshape(permute(rMarkers, [1, 3, 2]), [], size(rMarkers, 2));
[rU, rS, rV] = svd(rMarkersMatrix, "econ", "vector");
myConstantPlane(rV(:, 3), zeros(3, 1), [-.5, .5], 'FaceAlpha', .3, 'LineStyle', 'None');
disp(rV)
axis("equal");
title("Deviations from mean");
xlabel("$X$-axis", "Interpreter", "latex", "FontSize", 12);
ylabel("$Y$-axis", "Interpreter", "latex", "FontSize", 12);
zlabel("$Z$-axis", "Interpreter", "latex", "FontSize", 12);
view(3);

subplot(1, 2, 2);
hold on;
for nmarker = 1 : size(Markers, 3)
    scatter3( ...
        squeeze(dMarkers(:, 1, nmarker)), ...
        squeeze(dMarkers(:, 2, nmarker)), ...
        squeeze(dMarkers(:, 3, nmarker)), ...
        'DisplayName', sprintf("%d", nmarker), ...
        'Color', colorMap(nmarker) ...
    );
end
dMarkersMatrix = reshape(permute(dMarkers, [1, 3, 2]), [], size(dMarkers, 2));
[dU, dS, dV] = svd(dMarkersMatrix, "econ", "vector");
disp(dV)
myConstantPlane(dV(:, 3), zeros(3, 1), [-.01, .01], 'FaceAlpha', .3, 'LineStyle', 'None');
axis("equal");
title("Velocities");
xlabel("$X$-axis", "Interpreter", "latex", "FontSize", 12);
ylabel("$Y$-axis", "Interpreter", "latex", "FontSize", 12);
zlabel("$Z$-axis", "Interpreter", "latex", "FontSize", 12);
view(3);

%% 
figure('WindowState', 'maximized');
plotHandle = animateMarkers(1, [], Markers, 'k', 'LineWidth', 2, 'Marker', 'o');
axis("equal");
animationFunction = @(ii) animateMarkers(ii, plotHandle, Markers);
myAnimate(animationFunction, size(Markers, 1), round(1./300, 3));

%%

% b = mean(dV(:, 3).' * reshape(permute(rMarkers, [1, 3, 2]), [], size(rMarkers, 2)).');
muMarkers = squeeze(mean(mMarkers, 3));

figure("WindowState", "maximized");
hold on;
markersPlotTrace(Markers, jumpMarkerNames, "LineWidth", 2);
myConstantPlane(dV(:, 3), muMarkers, [-1.1, 1.1], 'FaceAlpha', .3, 'LineStyle', 'None', 'DisplayName', 'sagittal plane');
projMarkers = markersProjectToPlane(Markers, dV(:, 3), dV(:, 3).' * muMarkers.');
% projMarkers = markersProjectToPlane(Markers, [0, 0, 1].', 0);
markersPlotTrace(projMarkers, strcat("proj ", jumpMarkerNames), "LineWidth", 2, "LineStyle", ":");   
axis("equal");
xlabel("$X$-axis", "Interpreter", "latex", "FontSize", 15);
ylabel("$Y$-axis", "Interpreter", "latex", "FontSize", 15);
zlabel("$Z$-axis", "Interpreter", "latex", "FontSize", 15);
zlim(expandLimits([min(Markers(:, 3, :), [], [1, 3]), max(Markers(:, 3, :), [], [1, 3])], 1.2));
view(3);
legend("FontSize", 15, "Position", [.6, .6, .2, .2]);
%% Transversal plane trace

%% 2D plot

planarMarkersSVD = markersToPlanarCoordinates(Markers, Markers(:, :, 1), [dV(:, 2), -dV(:, 1)]);
planarMarkersXZ = markersToPlanarCoordinates(Markers, Markers(:, :, 1), [[1; 0; 0], [0; 0; 1]]);
figure('WindowState', 'maximized');
subplot(1, 2, 1)
hold on;
planarMarkersPlotTrace(planarMarkersSVD, jumpMarkerNames, "LineWidth", 2);
axis("equal");
xlabel("$X$-axis", "Interpreter", "latex", "FontSize", 15);
ylabel("$Y$-axis", "Interpreter", "latex", "FontSize", 15);
% legend("FontSize", 15, "Position", [.6, .6, .2, .2]);
subplot(1, 2, 2)
hold on;
planarMarkersPlotTrace(planarMarkersXZ, jumpMarkerNames, "LineWidth", 2);
axis("equal");
xlabel("$X$-axis", "Interpreter", "latex", "FontSize", 15);
ylabel("$Y$-axis", "Interpreter", "latex", "FontSize", 15);
legend("FontSize", 15, "Position", [.8, .7, .2, .2]);

%% Segment lengths
figure('WindowState', 'maximized');
referenceFramePlot(eye(3), zeros(3, 1), "LineWidth", 2);
referenceFramePlot(referenceFrameMatch(dV, eye(3)), zeros(3, 1), "LineWidth", 1, "LineStyle", ":");
view(3);

segmentLengths = squeeze(sqrt(sum(diff(Markers, 1, 3).^2, 2)));
segmentLengthsPlanar = squeeze(sqrt(sum(diff(planarMarkersXZ, 1, 3).^2, 2)));
figure('WindowState', 'maximized');
for n = 1 : size(segmentLengths, 2)
    subplot(size(segmentLengths, 2), 1, n);
    hold on;
    plot(segmentLengths(:, n), "LineWidth", 2, "Color", "b", "DisplayName", "3d");
    plot(segmentLengthsPlanar(:, n), "LineWidth", 1, "Color", "r", "LineStyle", ":", "DisplayName", "2d");
    plot([1, size(segmentLengths, 1)], median(segmentLengths(:, n), 1) * ones(1, 2), "LineStyle", "--", "LineWidth", 1, "Color", "b", "DisplayName", "3d-med");
    plot([1, size(segmentLengths, 1)], median(segmentLengthsPlanar(:, n), 1) * ones(1, 2), "LineStyle", "--", "LineWidth", 1, "Color", "r", "DisplayName", "2d-med");
    ylabel(sprintf("$L_{%d}$", n), "Interpreter", "latex", "FontSize", 15);
    if n == size(segmentLengths, 2)
        xlabel("Samples", "Interpreter", "latex", "FontSize", 15);
        legend("FontSize", 15, "Position", [.86, .8, .2, .2]);
    end
end

TileFigures;


%% Choose L and do IK

Lchoice = median(segmentLengthsPlanar, 1).';
% Lchoice = mean(segmentLengthsPlanar, 1).';
[qmin, qmax] = humanJointLimits(6, true);
dplanarMarkersXZ = squeeze(diff(planarMarkersXZ(1, :, :), 1, 3));
groundAngles = reshape(atan2(dplanarMarkersXZ(2, :), dplanarMarkersXZ(1, :)), [], 1);
q0 = groundAnglesToJointAngles(groundAngles);
[Q, MWE, E, ikMarkers] = run_ik(6, Lchoice, qmin, qmax, planarMarkersXZ(:, 1:2, 2:end), q0);

ikMarkers = cat(3, zeros([size(ikMarkers, [1, 2]), 1]), ikMarkers);

%%
figure('WindowState', 'maximized');
hold on;
plotHandleXZ = animatePlanarMarkers(1, [], planarMarkersXZ, 'k', 'LineWidth', 2, 'Marker', 'o');
plotHandleIK = animatePlanarMarkers(1, [], ikMarkers, 'r', 'LineWidth', 2, 'Marker', 'o', 'LineStyle', '--');
axis("equal");
animationFunction = @(ii) animateAggregation(ii, { 
    @(n) animatePlanarMarkers(n, plotHandleXZ, planarMarkersXZ);
    @(n) animatePlanarMarkers(n, plotHandleIK, ikMarkers);
});
myAnimate(animationFunction, size(planarMarkersXZ, 1), round(1./300, 3));

%% Check dynamics

q = Q(:, 1125:1350);
n = size(q, 1);
N = size(q, 2);

Mtot = 77.3;    
Htot = 1.77;
L = Lchoice;
COM = vertcat(.5 * ones(1, n), zeros(1, n)) .* L.';
M = [2 * 0.012; 2 * 0.048; 2 * 0.123; (14.2 + 2.9 + 30.4 + 6.7) / 100; 2 * 0.024; 2 * 0.017] .* Mtot;
I = 1/12 * M .* L;
mu = 0.6;

dt = 1./300;

[qmin, qmax] = humanJointLimits(n, true);
[dqmin, dqmax] = humanVelocityLimits(n);
[taumin, taumax] = humanTorqueLimits(n, true);
[zmpmin, zmpmax] = humanZmpLimits(n);

gravity = [0; -9.81];
Fext = cell(n, 1);
for ii = 1 : n
    Fext{ii} = zeros(3, N-1);
end

dq = diff(q, 1, 2) ./ dt;
dq = [dq, dq(:, end)];
ddq = diff(q, 2, 2) ./ dt^2;
ddq = [ddq, ddq(:, end)];

q0 = q(:, 1);
dq0 = dq(:, 1);

[opti, vars] = make_ndof_jumping_model(n, N);
instantiate_ndof_jumping_model(vars, opti, dt, q0, dq0, mu, L, COM, M, I, qmin, qmax, dqmin, dqmax, taumin, taumax, zmpmin, zmpmax, gravity, Fext, ddq, dq, q)
ivars = numerize_vars(vars, opti.debug, true);

plot_everything_from_vars(ivars)