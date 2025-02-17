function [taulo, tauhi] = humanTorqueLimits(n, footFlag)
    if nargin < 2
        footFlag = false;
    end
    if ~footFlag
        taulo = 2*[-126, -168, -185, -67, -46];
        tauhi = 2*[126,  100,  190,  92,  77];
    
        taulo = taulo(1:n);
        tauhi = tauhi(1:n);
        return
    end
    % Assumption: Foot torque ~= ankle torque
    taulo = 2*[-126, -126, -168, -185, -67, -46];
    tauhi = 2*[126, 126,  100,  190,  92,  77];
end