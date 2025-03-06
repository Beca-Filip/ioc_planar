function [dqlo, dqhi] = humanVelocityLimits(n)
    dqlo = 1.2*deg2rad(-360*ones(1, n));
    dqhi = 1.2*deg2rad(360*ones(1, n));
end
