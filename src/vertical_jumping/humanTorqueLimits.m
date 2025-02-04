function [taulo, tauhi] = humanTorqueLimits(n)
    taulo = 2*[-126, -168, -185, -67, -46];
    tauhi = 2*[126,  100,  190,  92,  77];

    taulo = taulo(1:n);
    tauhi = tauhi(1:n);
end