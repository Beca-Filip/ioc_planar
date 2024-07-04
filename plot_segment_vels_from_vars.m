function plot_segment_vels_from_vars(num_vars)

[n, N] = size(num_vars.variables.q);
t = linspace(0, (N-1) * num_vars.parameters.dt, N);

for ii = 1 : n
    subplot(3, n, ii)
    hold on;
    plot(t, num_vars.functions.V{ii+1}(1, :));
    ylabel(sprintf("$V^{%d}_x$", ii), 'Interpreter', 'latex');

    subplot(3, n, n + ii)
    hold on;
    plot(t, num_vars.functions.V{ii+1}(2, :));
    ylabel(sprintf("$V^{%d}_y$", ii), 'Interpreter', 'latex');

    subplot(3, n, 2*n + ii)
    hold on;
    plot(t, num_vars.functions.V{ii+1}(3, :));
    ylabel(sprintf("$V^{%d}_{\\theta}$", ii), 'Interpreter', 'latex');
        
    xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex')
end


end