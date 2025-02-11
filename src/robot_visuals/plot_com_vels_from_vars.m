function plot_com_vels_from_vars(vars, varargin)

[n, N] = size(vars.variables.q);
t = linspace(0, (N-1) * vars.parameters.dt, N);

for ii = 1 : n
    vars.functions.Vcomnum = diff(vars.functions.Pcom{ii}, 1, 2) ./ vars.parameters.dt;
    NnumV = size(vars.functions.Vcomnum, 2);

    subplot(3, n, ii)
    hold on;
    plot(t, vars.functions.Vcom{ii}(1, :), varargin{:});
    plot(t(1:NnumV), vars.functions.Vcomnum(1, :), '--', varargin{:});
    ylabel(sprintf("$V^{%d}_{{\\rm COM}, x}$", ii), 'Interpreter', 'latex');
    grid;

    subplot(3, n, n + ii)
    hold on;
    plot(t, vars.functions.Vcom{ii}(2, :), varargin{:});
    plot(t(1:NnumV), vars.functions.Vcomnum(2, :), '--', varargin{:});
    ylabel(sprintf("$V^{%d}_{{\\rm COM}, y}$", ii), 'Interpreter', 'latex');
    grid;

    subplot(3, n, 2*n + ii)
    hold on;
    plot(t, vars.functions.Vcom{ii}(3, :), varargin{:});
    plot(t(1:NnumV), vars.functions.Vcomnum(3, :), '--', varargin{:});
    ylabel(sprintf("$V^{%d}_{{\\rm COM}, \\theta}$", ii), 'Interpreter', 'latex');
    grid;
        
    xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex')
end

end