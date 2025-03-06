function plotHandle = amtiPlotForceplates(varargin)
    [X, Y, Z] = amtiFixedVertices();
    plotHandle = fill3(X, Y, Z, [.3, .3, .9], varargin{:});
end