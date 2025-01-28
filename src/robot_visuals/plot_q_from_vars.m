function plot_q_from_vars(num_vars, varargin)

[n, N] = size(num_vars.variables.q);
t = linspace(0, (N-1) * num_vars.parameters.dt, N);

for ii = 1 : n
    subplot(n, 1, ii)
    hold on;
    plot(t, rad2deg(num_vars.variables.q(ii, :)), varargin{:});
    ylabel(sprintf("$q_{%d}$ [$^\\circ$]", ii), 'Interpreter', 'latex');
    
    if ii == n
        xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex')
    end
end


end