n = 6;
N = 200;
T = 2.5;

[opti, vars] = make_ndof_model(n, N);

% Parameters
% dt = 0.01;
dt = T / (N-1);
q0 = zeros(n, 1); q0(1) = pi/2;
dq0 = zeros(n, 1);

L = ones(n, 1);
COM = vertcat(.5 * ones(1, n), zeros(1, n));
M = ones(n, 1);
I = 1/12 * ones(n, 1);

gravity = [0; -9.81];
Fext = cell(n, 1);
for ii = 1 : n
    Fext{ii} = zeros(3, N-2);
end

goal = [2; 4];

% Variables
ddq = zeros(n, N-2);
dq = repmat(dq0, [1, N-1]);
q = [ ...
        linspace(pi/2, pi/2, N); ...
        linspace(0, 0, N);
        linspace(0, 0, N);
        linspace(0, 0, N);
        linspace(0, -pi/2, N);
        linspace(0, 0, N);
   ];

% Instantiate
instantiate_ndof_model(vars, opti, dt, q0, dq0, L, COM, M, I, gravity, Fext, goal, ddq, dq, q);

% Optimize options
opti.solver('ipopt');

% Optimize joint velocity
theta_1 = [200, 1, 5000];
theta_1 = theta_1 ./ sum(theta_1);
opti.minimize(theta_1(1) * vars.costs.joint_vel_cost + theta_1(2) * vars.costs.joint_torque_cost + theta_1(3) * vars.costs.ee_vel_cost);
sol_1 = opti.solve();


lambda_1 = sol_1.value(opti.lam_g); % Extract dual variables
% Extract primal variables
q_1 = sol_1.value(vars.variables.q);
dq_1 = sol_1.value(vars.variables.dq);
ddq_1 = sol_1.value(vars.variables.ddq);

% Numerize
num_vars_1 = numerize_vars(vars, sol_1);

%%
close all

figure('WindowState', 'maximized');
hold all;
plot_traj_from_vars(num_vars_1, 10);
plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
axis('equal');


figure('WindowState','maximized');
hold on;
plot_joint_traj_from_vars(num_vars_1);

figure('WindowState','maximized');
hold on;
plot_segment_vels_from_vars(num_vars_1);

TileFigures([], 2, 2)