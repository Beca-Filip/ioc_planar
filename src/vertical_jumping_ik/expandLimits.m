function nlm = expandLimits(lm, factor)
m = mean(lm);
d = diff(lm);
d = d * factor;
nlm = [m - d/2, m + d/2];
end