function [qlo, qhi] = humanJointLimits(n, footFlag)
    if nargin < 2
        footFlag = false;
    end
    if ~footFlag
        qlo = deg2rad([30,  -5,   -180, -225, 0  ]);
        qhi = deg2rad([150, 180, 30,   15, 180]);
        qlo = qlo(1:n);
        qhi = qhi(1:n);
        return
    end

    qlo = deg2rad([60, -180,  -5, -180, -225, 0  ]);
    qhi = deg2rad([180,   0, 180,   30, 15, 180]);
    qlo = qlo(1:n);
    qhi = qhi(1:n);
end