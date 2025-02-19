function [taulo, tauhi] = humanTorqueLimits(n, footFlag)
    if nargin < 2
        if n == 3
            footFlag = false;
        else
            footFlag = true;
        end
    end
    if ~footFlag
        taulo = 2*[-126, -168, -185, -67, -46];
        tauhi = 2*[126,  100,  190,  92,  77];
    else
        % Assumption: Foot torque ~= ankle torque
        taulo = 2*[-126, -126, -168, -185, -67, -46];
        tauhi = 2*[126, 126,  100,  190,  92,  77];
    end
    taulo = taulo(1:n);
    tauhi = tauhi(1:n);
    return
end