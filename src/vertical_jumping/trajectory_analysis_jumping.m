n = 3;
N = 18;
T = 1.2;

warmStartName = sprintf("warmStart-n%02d-N%04d.mat", n, N);

[opti, vars] = make_ndof_jumping_model(n, N);

%% Parameters
% dt = 0.01;
dt = T / (N-1);

Mtot = 77.3;
Htot = 1.77;
L = [0.433; 0.432; (93+151+334)/1000; 0.277; (283 + 80) / 1000];
L = L(1:n);
COM = vertcat(.5 * ones(1, n), zeros(1, n)) .* L.';
M = [2 * 0.048; 2 * 0.123; (14.2 + 2.9 + 30.4 + 6.7) / 100; 2 * 0.024; 2 * 0.017] .* Mtot;
M = [M(1:n-1); sum(M(n:end))];
I = 1/12 * M .* L;

mu = 0.6;

[qmin, qmax] = humanJointLimits(n);
[dqmin, dqmax] = humanVelocityLimits(n);
[taumin, taumax] = humanTorqueLimits(n);

gravity = [0; -9.81];
Fext = cell(n, 1);
for ii = 1 : n
    Fext{ii} = zeros(3, N-1);
end

% % Variables
% ddq = zeros(n, N-2);
% dq = repmat(dq0, [1, N-1]);
% q = repmat(q0, [1, N]);
   
% q = [ ...
%     [linspace(pi/2, pi/4, div(N+1, 2)), linspace(pi/4, pi/2, div(N, 2))];
%     [linspace(0, pi/2, div(N+1, 2)), linspace(pi/2, 0, div(N, 2))];
%     [linspace(0, -pi/4, div(N+1, 2)), linspace(-pi/4, 0, div(N, 2))];
%     linspace(0, 0, N);
%     linspace(0, 0, N);
% ];
% q = [ ...
%     pi/4 * ones(1, N);
%     pi/2 * ones(1, N);
%     -pi/4 * ones(1, N);
%     zeros(n-3, N);
% ];
q = [pi/2 * ones(1, N); zeros(n-1, N)];
q = q(1:n, :);
noise = deg2rad(3 / (N)) * randn(size(q));
q = q + noise;


% goal = [2; 0];
% q = [ ...
%     linspace(q0(1, 1), q0(1, end), N);
%     linspace(q0(2, 1), q0(2, end), N); 
% ];

dq = [diff(q, 1, 2) ./ dt, noise(:, randi(N)) ./ dt];
ddq = diff(dq, 1, 2) ./ dt;

if exist(warmStartName, "file") && ~isempty(input(sprintf("Any key then enter if you want to load the solution from %s:\n", warmStartName)))
    warmStart_vars = importdata(warmStartName);
    q = warmStart_vars.variables.q;
    dq = warmStart_vars.variables.dq;
    ddq = warmStart_vars.variables.ddq;
end

q0 = q(:, 1);
% q0(1) = -pi/2 + 0.1; q0(2) = 0.1;
dq0 = dq(:, 1);

% Instantiate
instantiate_ndof_jumping_model(vars, opti, dt, q0, dq0, mu, L, COM, M, I, qmin, qmax, dqmin, dqmax, taumin, taumax, gravity, Fext, ddq, dq, q);
ivars = numerize_vars(vars, opti, true);

% Optimize options
opti.solver('ipopt', struct(), struct("max_iter", 10000));
opti.minimize(vars.costs.max_com_height_cost + 0.05 * vars.costs.avg_joint_vel_cost);
sol_1 = opti.solve();

% Numerize
nvars = numerize_vars(vars, sol_1);

%%
close all

figure('WindowState', 'maximized');
hold all;
plot_traj_from_vars(nvars, 3);
axis('equal');
expandAxes(1.2);
grid;
xlabel('Sagittal axis: $x$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
ylabel('Vertical axis: $z$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
ax = gca; ax.FontSize = 25; ax.TickLabelInterpreter = 'latex';

figure('WindowState','maximized');
hold on;
plot_joint_traj_from_vars(nvars, 'LineWidth', 2);

figure('WindowState','maximized');
hold on;
plot_segment_pos_from_vars(nvars, 'LineWidth', 2);

figure('WindowState','maximized');
hold on;
plot_segment_vels_from_vars(nvars, 'LineWidth', 2);


figure('WindowState','maximized');
hold on;
plot_com_pos_from_vars(nvars, 'LineWidth', 2);

figure('WindowState','maximized');
hold on;
plot_com_vels_from_vars(nvars, 'LineWidth', 2);


figure('WindowState','maximized');
hold on;
plot_total_com_kinematics_from_vars(nvars, 'LineWidth', 2);


figure('WindowState','maximized');
hold on;
plot_grfs_from_vars(nvars, 'LineWidth', 2);

%% Saving for warmStart
if ~isempty(input(sprintf("Any key then enter if the solution should be saved in %s:\n", warmStartName)))
    save(warmStartName, "nvars");
end

% TileFigures