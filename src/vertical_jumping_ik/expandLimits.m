function nlm = expandLimits(lm, factor)
m = mean(lm);
d = diff(lm);
d = d * factor;
nlm = cat(1, m - d/2, m + d/2);
end