function plotHandles = referenceFramePlot(R, p, varargin)
    if nargin < 2
        p = zeros(3, 1);
    end
    plotHandles = [];
    hold on;
    plotHandles(end+1) = quiver3(p(1), p(2), p(3), R(1, 1), R(1, 2), R(1, 3), "Color", "r", varargin{:});
    plotHandles(end+1) = quiver3(p(1), p(2), p(3), R(2, 1), R(2, 2), R(2, 3), "Color", "g", varargin{:});
    plotHandles(end+1) = quiver3(p(1), p(2), p(3), R(3, 1), R(3, 2), R(3, 3), "Color", "b", varargin{:});
end