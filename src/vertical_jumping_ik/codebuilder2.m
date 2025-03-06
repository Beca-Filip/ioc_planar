clear all
close all
clc

forceplateFilePath = sprintf("forceplate\\01_1_2.txt");
forceplateData = amtiReadTXT(forceplateFilePath);
forceplateData = amtiFilterData(forceplateData);
%%
figure('WindowState', 'maximized');
amtiPlotTrajectories(forceplateData);

%%

Forces = amtiTable2Forces(forceplateData, 1:2);
centersOfPressure = forces2Cop(Forces);
transformations2Qualisys = amtiFixedQualisysTransforms();
ForcesQualisys = forcesTransform(transformations2Qualisys, Forces);
centersOfPressureQualisys = vectorsTransform(transformations2Qualisys, centersOfPressure);

normalizedForcesQualisys = ForcesQualisys ./ mean(ForcesQualisys(1:1000, :, :), 1);
figure('WindowState', 'maximized');
hold on;
amtiPlotForceplates();
plotHandleCop = animatePoint(1, [], centersOfPressureQualisys, 100, [.3, .9, .3], 'filled');
plotHandleForce = animateForces(1, [], centersOfPressureQualisys, normalizedForcesQualisys, "LineWidth", 2, "Color", [.3, .9, .3]);

hold on;
xlim([-.4, .8]); ylim([-.5, 1.8]); zlim([-.1, 2.]);
axis("equal");
view(33.5703, 22.6771);

animationFunctionCop = @(ii) animatePoint(ii, plotHandleCop, centersOfPressureQualisys);
animationFunctionForce = @(ii) animateForces(ii, plotHandleForce, centersOfPressureQualisys, normalizedForcesQualisys);
animationJoined = @(ii) animateAggregation(ii, {animationFunctionCop, animationFunctionForce});
myAnimate(animationJoined, size(normalizedForcesQualisys, 1), 1./1000);