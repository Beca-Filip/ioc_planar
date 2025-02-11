function plot_grfs_from_vars(vars, varargin)

[~, Nzmp] = size(vars.functions.zmp);
tzmp = linspace(0, (Nzmp-1) * vars.parameters.dt, Nzmp);

hold on;
plot(tzmp, vars.functions.zmp, varargin{:});
plot(tzmp([1, end]), vars.parameters.zmpmin * ones(1, 2), 'Color', [0, 0.7, 0.7], varargin{:});
plot(tzmp([1, end]), vars.parameters.zmpmax * ones(1, 2), 'Color', [0.7, 0, 0.7], varargin{:});
ylabel("${{\rm ZMP}}$", 'Interpreter', 'latex');
grid;

end