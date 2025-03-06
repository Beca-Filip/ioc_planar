function [centerOfPressure1, centerOfPressure2] = amtiCopQualisysFrame(forceplateData, forceplateIdcs)
    
    Forces = amtiTable2Forces(forceplateData, forceplateIdcs);
    centerOfPressure = forces2Cop(Forces);

    transforms2Qualisys = amtiFixedQualisysTransforms();

    centerOfPressure1 = squeeze(transforms2Qualisys(:, :, 1)) * vertcat(centerOfPressure1, ones(1, size(centerOfPressure1, 2)));
    centerOfPressure2 = squeeze(transforms2Qualisys(:, :, 2)) * vertcat(centerOfPressure2, ones(1, size(centerOfPressure2, 2)));

    centerOfPressure1 = centerOfPressure1(1:3, :).';
    centerOfPressure2 = centerOfPressure2(1:3, :).';
end