clear all
close all
clc

forceplateFilePath = sprintf("forceplate\\01_1_2.txt");
forceplateData = amtiReadTXT(forceplateFilePath);
forceplateData = amtiFilterData(forceplateData);
%%
figure('WindowState', 'maximized');
amtiPlotTrajectories(forceplateData);