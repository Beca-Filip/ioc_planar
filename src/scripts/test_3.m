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

% Parametrize cost
[opti, vars] = parametrize_ndof_cf(vars, opti);

% Optimize options
opti.solver('ipopt');

% Optimize joint velocity
% theta_1 = [1, 5000, 1, 1, 1];
theta_1 = [1, 5000, 1];
theta_1 = theta_1 ./ sum(theta_1);
instantiate_parametrized_ndof_cf(vars, opti, theta_1);
% Solve
sol_1 = opti.solve();
% Numerize
lambda_1 = sol_1.value(opti.lam_g); % Extract dual variables
num_vars_1 = numerize_vars(vars, sol_1);

% Optimize other stuff
% theta_2 = [200, 150, 30, 1, 1];
theta_2 = [200, 150, 30];
theta_2 = theta_2 ./ sum(theta_2);
instantiate_parametrized_ndof_cf(vars, opti, theta_2);
sol_2 = opti.solve();
% Numerize
lambda_2 = sol_2.value(opti.lam_g); % Extract dual variables
num_vars_2 = numerize_vars(vars, sol_2);

%% Make IOC
[opti_ioc, vars_ioc] = make_ndof_model(n, N);

% Extract dual variables size
ndual = size(lambda_1, 1);
% Extract parameters size
nparam = size(theta_1, 2);

% Create dual variable parameter
vars_ioc.variables.lambda = opti_ioc.variable(ndual);
% Create model parameter
vars_ioc.variables.theta = opti_ioc.variable(nparam);

% Prepare stationarity constraint
% vars_ioc.costs.compound_cost = vars_ioc.variables.theta(1) * vars_ioc.costs.joint_vel_cost + vars_ioc.variables.theta(2) * vars_ioc.costs.joint_torque_cost + vars_ioc.variables.theta(3) * vars_ioc.costs.ee_vel_cost;
vars_ioc.costs.compound_cost = vars_ioc.variables.theta(2) * vars_ioc.costs.joint_vel_cost + vars_ioc.variables.theta(1) * vars_ioc.costs.joint_torque_cost + vars_ioc.variables.theta(3) * vars_ioc.costs.ee_vel_cost;
vars_ioc.costs.grad_compound_cost = jacobian(vars_ioc.costs.compound_cost, [vec(vars_ioc.variables.q); vec(vars_ioc.variables.dq); vec(vars_ioc.variables.ddq)]).';

vars_ioc.constraints.compound_constraints = [vec(vars_ioc.constraints.initial_pos); vec(vars_ioc.constraints.initial_vel); vec(vars_ioc.constraints.dynamics_pos); vec(vars_ioc.constraints.dynamics_vel); vec(vars_ioc.constraints.goal_ee)];
vars_ioc.constraints.grad_compound_constraints = jacobian(vars_ioc.constraints.compound_constraints, [vec(vars_ioc.variables.q); vec(vars_ioc.variables.dq); vec(vars_ioc.variables.ddq)]).';

vars_ioc.constraints.stationarity = vars_ioc.costs.grad_compound_cost + vars_ioc.constraints.grad_compound_constraints * vars_ioc.variables.lambda;

% Subject to
opti_ioc.subject_to(vars_ioc.constraints.stationarity == 0);
opti_ioc.subject_to(sum(vars_ioc.variables.theta) == 1);
opti_ioc.subject_to(vars_ioc.variables.theta >= 0);

opti_ioc.subject_to(vec(vars_ioc.variables.q - num_vars_1.variables.q) <= pi/4)
opti_ioc.subject_to(vec(-vars_ioc.variables.q + num_vars_1.variables.q) <= pi/4)


% Create L2 loss
% vars_ioc.costs.L2_loss = sum(sum((vars_ioc.variables.q - num_vars_1.variables.q - (3/180*pi) * randn(size(num_vars_1.variables.q))).^2));
vars_ioc.costs.L2_loss = sum(sum((vars_ioc.variables.q - num_vars_1.variables.q).^2));

% Optimize
opti_ioc.minimize(vars_ioc.costs.L2_loss);

% Instantiate
instantiate_ndof_model(vars_ioc, opti_ioc, dt, q0, dq0, L, COM, M, I, gravity, Fext, goal, num_vars_2.variables.ddq, num_vars_2.variables.dq, num_vars_2.variables.q);
opti_ioc.set_initial(vars_ioc.variables.lambda, lambda_2);
opti_ioc.set_initial(vars_ioc.variables.theta, theta_2);

% Optimize options
opti_ioc.solver('ipopt');
sol_ioc = opti_ioc.solve();

% Numerize
num_vars_ioc = numerize_vars(vars_ioc, sol_ioc);

% Print identification
printFormat = sprintf("True theta = [%s]\nId.  theta = [%s].\n", repmat('%.4f, ', 1, length(theta_1)), repmat('%.4f, ', 1, length(theta_1)));
fprintf(printFormat, theta_1, num_vars_ioc.variables.theta);

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
plot_snapshots_from_vars(num_vars_ioc, 10);
plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
axis('equal');

figure('WindowState','maximized');
hold on;
plot_joint_traj_from_vars(num_vars_1);
plot_joint_traj_from_vars(num_vars_2);
plot_joint_traj_from_vars(num_vars_ioc);

% figure('WindowState','maximized');
% hold on;
% plot_compared_costs(num_vars_1);
% plot_compared_costs(num_vars_2);
% plot_compared_costs(num_vars_ioc);


figure('WindowState','maximized');
hold on;
plot_segment_vels_from_vars(num_vars_1);
plot_segment_vels_from_vars(num_vars_2);
plot_segment_vels_from_vars(num_vars_ioc);

TileFigures