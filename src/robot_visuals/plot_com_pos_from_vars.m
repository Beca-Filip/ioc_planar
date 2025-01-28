function plot_com_pos_from_vars(num_vars, varargin)

[n, N] = size(num_vars.variables.q);
t = linspace(0, (N-1) * num_vars.parameters.dt, N);

for ii = 1 : n
    subplot(3, n, ii)
    hold on;
    plot(t, num_vars.functions.Pcom{ii}(1, :), varargin{:});
    ylabel(sprintf("$P^{%d}_{{\\rm COM}, x}$", ii), 'Interpreter', 'latex');
    grid;

    subplot(3, n, n + ii)
    hold on;
    plot(t, num_vars.functions.Pcom{ii}(2, :), varargin{:});
    ylabel(sprintf("$P^{%d}_{{\\rm COM}, y}$", ii), 'Interpreter', 'latex');
    grid;

    subplot(3, n, 2*n + ii)
    hold on;
    plot(t, num_vars.functions.Pcom{ii}(3, :), varargin{:});
    ylabel(sprintf("$P^{%d}_{{\\rm COM}, \\theta}$", ii), 'Interpreter', 'latex');
    grid;
        
    xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex')
end

end