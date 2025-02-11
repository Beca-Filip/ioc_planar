function plot_segment_accs_from_vars(vars, varargin)

[n, N] = size(vars.variables.q);
t = linspace(0, (N-1) * vars.parameters.dt, N);

for ii = 1 : n
    vars.functions.Anum1 = diff(vars.functions.P{ii+1}, 2, 2) ./ vars.parameters.dt^2;
    NnumA1 = size(vars.functions.Anum1, 2);
    vars.functions.Anum2 = diff(vars.functions.V{ii+1}, 1, 2) ./ vars.parameters.dt;
    NnumA2 = size(vars.functions.Anum2, 2);
    
    subplot(3, n, ii)
    hold on;
    plot(t, vars.functions.A{ii+1}(1, :), varargin{:});
    plot(t(1:NnumA1), vars.functions.Anum1(1, :), '--', varargin{:});
    plot(t(1:NnumA2), vars.functions.Anum2(1, :), ':', varargin{:});
    ylabel(sprintf("$A^{%d}_x$", ii), 'Interpreter', 'latex');
    grid;

    subplot(3, n, n + ii)
    hold on;
    plot(t, vars.functions.A{ii+1}(2, :), varargin{:});
    plot(t(1:NnumA1), vars.functions.Anum1(2, :), '--', varargin{:});
    plot(t(1:NnumA2), vars.functions.Anum2(2, :), ':', varargin{:});
    ylabel(sprintf("$A^{%d}_y$", ii), 'Interpreter', 'latex');
    grid;

    subplot(3, n, 2*n + ii)
    hold on;
    plot(t, vars.functions.A{ii+1}(3, :), varargin{:});
    plot(t(1:NnumA1), vars.functions.Anum1(3, :), '--', varargin{:});
    plot(t(1:NnumA2), vars.functions.Anum2(3, :), ':', varargin{:});
    ylabel(sprintf("$A^{%d}_{\\theta}$", ii), 'Interpreter', 'latex');
    grid;
        
    xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex')
end

end