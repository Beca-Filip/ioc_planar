function plot_segment_vels_from_vars(vars, varargin)

[n, N] = size(vars.variables.q);
t = linspace(0, (N-1) * vars.parameters.dt, N);

for ii = 1 : n
    vars.functions.Vnum = diff(vars.functions.P{ii+1}, 1, 2) ./ vars.parameters.dt;
    NnumV = size(vars.functions.Vnum, 2);
    
    subplot(3, n, ii)
    hold on;
    plot(t, vars.functions.V{ii+1}(1, :), varargin{:});
    plot(t(1:NnumV), vars.functions.Vnum(1, :), '--', varargin{:});
    ylabel(sprintf("$V^{%d}_x$", ii), 'Interpreter', 'latex');
    grid;

    subplot(3, n, n + ii)
    hold on;
    plot(t, vars.functions.V{ii+1}(2, :), varargin{:});
    plot(t(1:NnumV), vars.functions.Vnum(2, :), '--', varargin{:});
    ylabel(sprintf("$V^{%d}_y$", ii), 'Interpreter', 'latex');
    grid;

    subplot(3, n, 2*n + ii)
    hold on;
    plot(t, vars.functions.V{ii+1}(3, :), varargin{:});
    plot(t(1:NnumV), vars.functions.Vnum(3, :), '--', varargin{:});
    ylabel(sprintf("$V^{%d}_{\\theta}$", ii), 'Interpreter', 'latex');
    grid;
        
    xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex')
end

end