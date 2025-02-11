function [xlm, ylm, zlm] = markerLimits(Markers)
xlm = [min(Markers(:, 1, :), [], "all"), max(Markers(:, 1, :), [], "all")];
ylm = [min(Markers(:, 2, :), [], "all"), max(Markers(:, 2, :), [], "all")];
zlm = [min(Markers(:, 3, :), [], "all"), max(Markers(:, 3, :), [], "all")];
end