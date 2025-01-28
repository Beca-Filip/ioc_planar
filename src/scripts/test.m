n = 2;
N = 20;
T = 1.5;

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

goal = [0.5; 0.5];

% % Variables
% ddq = zeros(n, N-2);
% dq = repmat(dq0, [1, N-1]);
% q = repmat(q0, [1, N]);

q = [ ...
    linspace(1.5708, 2.0399, N);
    linspace(0, -2.2524, N); 
];

dq = diff(q, 1, 2) ./ dt;
ddq = diff(dq, 1, 2) ./ dt;


% Instantiate
instantiate_ndof_model(vars, opti, dt, q0, dq0, L, COM, M, I, gravity, Fext, goal, ddq, dq, q);

% Optimize options
opti.solver('ipopt');

% Optimize joint velocity
opti.minimize(vars.costs.joint_vel_cost);
sol_1 = opti.solve();

% Optimize torque
opti.minimize(vars.costs.joint_torque_cost);
sol_2 = opti.solve();

% Optimize ee velocity
opti.minimize(vars.costs.ee_vel_cost);
sol_3 = opti.solve();

% Optimize torque change
opti.minimize(vars.costs.joint_torque_change_cost);
sol_4 = opti.solve();

% Optimize joint jerk
opti.minimize(vars.costs.joint_jerk_cost);
sol_5 = opti.solve();

% Numerize
num_vars_1 = numerize_vars(vars, sol_1);
num_vars_2 = numerize_vars(vars, sol_2);
num_vars_3 = numerize_vars(vars, sol_3);
num_vars_4 = numerize_vars(vars, sol_4);
num_vars_5 = numerize_vars(vars, sol_5);

%%
close all

figure('WindowState', 'maximized');
hold all;
plot_snapshots_from_vars(num_vars_1, 10);
plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
axis('equal');

figure('WindowState', 'maximized');
hold all;
plot_snapshots_from_vars(num_vars_2, 10);
plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
axis('equal');

figure('WindowState', 'maximized');
hold all;
plot_snapshots_from_vars(num_vars_3, 10);
plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
axis('equal');

figure('WindowState', 'maximized');
hold all;
plot_snapshots_from_vars(num_vars_4, 10);
plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
axis('equal');

figure('WindowState', 'maximized');
hold all;
plot_snapshots_from_vars(num_vars_5, 10);
plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
axis('equal');

figure('WindowState','maximized');
hold on;
plot_joint_traj_from_vars(num_vars_1);
plot_joint_traj_from_vars(num_vars_2);
plot_joint_traj_from_vars(num_vars_3);
plot_joint_traj_from_vars(num_vars_4);
plot_joint_traj_from_vars(num_vars_5);

figure('WindowState','maximized');
hold on;
plot_compared_costs(num_vars_1, num_vars_2, num_vars_3, num_vars_4, num_vars_5);


figure('WindowState','maximized');
hold on;
plot_segment_vels_from_vars(num_vars_1);
plot_segment_vels_from_vars(num_vars_2);
plot_segment_vels_from_vars(num_vars_3);
plot_segment_vels_from_vars(num_vars_4);
plot_segment_vels_from_vars(num_vars_5);



TileFigures