function [dqlo, dqhi] = humanVelocityLimits(n)
    dqlo = deg2rad(-360*ones(1, n));
    dqhi = deg2rad(360*ones(1, n));
end
