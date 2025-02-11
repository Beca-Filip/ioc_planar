function jointAngles = groundAnglesToJointAngles(groundAngles)
    jointAngles = zeros(size(groundAngles));
    jointAngles(1, :) = groundAngles(1, :);
    jointAngles(2:end, :) = diff(groundAngles, 1, 1);
end