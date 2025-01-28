function plot_total_com_kinematics_from_vars(num_vars, varargin)

[n, N] = size(num_vars.variables.q);
t = linspace(0, (N-1) * num_vars.parameters.dt, N);

% Position
subplot(2, 2, 1)
hold on;
plot(t, num_vars.functions.Pcomtotal(1, :), varargin{:});
ylabel("$P_{{\rm COM Total}, x}$", 'Interpreter', 'latex');
grid;

subplot(2, 2, 3)
hold on;
plot(t, num_vars.functions.Pcomtotal(2, :), varargin{:});
ylabel("$P_{{\rm COM Total}, y}$", 'Interpreter', 'latex');
grid;

xlabel("$t$ [s]", 'Interpreter', 'latex')

% Velocity
subplot(2, 2, 2)
hold on;
plot(t, num_vars.functions.Vcomtotal(1, :), varargin{:});
ylabel("$V_{{\rm COM Total}, x}$", 'Interpreter', 'latex');
grid;

subplot(2, 2, 4)
hold on;
plot(t, num_vars.functions.Vcomtotal(2, :), varargin{:});
ylabel("$V_{{\rm COM Total}, y}$", 'Interpreter', 'latex');
grid;
    
xlabel("$t$ [s]", 'Interpreter', 'latex')

end