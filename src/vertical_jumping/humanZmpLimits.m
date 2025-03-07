function [zmplo, zmphi] = humanZmpLimits(n)
    if n == 3
        zmplo = -0.08;
        zmphi = 0.16;
    else
        zmplo = -0.12;
        zmphi = 0.12;
    end
end