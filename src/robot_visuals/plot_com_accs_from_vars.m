function plot_com_accs_from_vars(vars, varargin)

[n, N] = size(vars.variables.q);
t = linspace(0, (N-1) * vars.parameters.dt, N);

for ii = 1 : n
    vars.functions.Acomnum1 = diff(vars.functions.Pcom{ii}, 2, 2) ./ vars.parameters.dt^2;
    NnumA1 = size(vars.functions.Acomnum1, 2);
    vars.functions.Acomnum2 = diff(vars.functions.Vcom{ii}, 1, 2) ./ vars.parameters.dt;
    NnumA2 = size(vars.functions.Acomnum2, 2);

    subplot(3, n, ii)
    hold on;
    plot(t, vars.functions.Acom{ii}(1, :), varargin{:});
    plot(t(1:NnumA1), vars.functions.Acomnum1(1, :), '--', varargin{:});
    plot(t(1:NnumA2), vars.functions.Acomnum2(1, :), ':', varargin{:});
    ylabel(sprintf("$A^{%d}_{{\\rm COM}, x}$", ii), 'Interpreter', 'latex');
    grid;

    subplot(3, n, n + ii)
    hold on;
    plot(t, vars.functions.Acom{ii}(2, :), varargin{:});
    plot(t(1:NnumA1), vars.functions.Acomnum1(2, :), '--', varargin{:});
    plot(t(1:NnumA2), vars.functions.Acomnum2(2, :), ':', varargin{:});
    ylabel(sprintf("$A^{%d}_{{\\rm COM}, y}$", ii), 'Interpreter', 'latex');
    grid;

    subplot(3, n, 2*n + ii)
    hold on;
    plot(t, vars.functions.Acom{ii}(3, :), varargin{:});
    plot(t(1:NnumA1), vars.functions.Acomnum1(3, :), '--', varargin{:});
    plot(t(1:NnumA2), vars.functions.Acomnum2(3, :), ':', varargin{:});
    ylabel(sprintf("$A^{%d}_{{\\rm COM}, \\theta}$", ii), 'Interpreter', 'latex');
    grid;
        
    xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex')
end

end