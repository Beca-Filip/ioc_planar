n = 5;
N = 120;
T = 1.2;

[opti, vars] = make_ndof_lifting_model(n, N);

% Parameters
% dt = 0.01;
dt = T / (N-1);
q0 = zeros(n, 1);
q0(1) = -pi/2 + 0.1; q0(2) = 0.1;
dq0 = zeros(n, 1);

L = ones(n, 1);
COM = vertcat(.5 * ones(1, n), zeros(1, n));
M = ones(n, 1);
I = 1/12 * ones(n, 1);

qmin = [pi/3; 0; -pi; -5*pi/4; 0];
qmax = [pi; pi; 0; 0; 0];

taumin = [-126; -168; -190; -67; -46];
taumax = [126; 100; 185; 92; 77];

gravity = [0; -9.81];
Fext = cell(n, 1);
for ii = 1 : n
    Fext{ii} = zeros(3, N-2);
end

goal = [1.5; -0.6];

% % Variables
% ddq = zeros(n, N-2);
% dq = repmat(dq0, [1, N-1]);
% q = repmat(q0, [1, N]);
   
q = [ ...
    linspace(q0(1, 1), -1.0109, N);
    linspace(q0(2, 1), 1.2609, N); 
];


% goal = [2; 0];
% q = [ ...
%     linspace(q0(1, 1), q0(1, end), N);
%     linspace(q0(2, 1), q0(2, end), N); 
% ];

dq = diff(q, 1, 2) ./ dt;
ddq = diff(dq, 1, 2) ./ dt;


% Instantiate
instantiate_ndof_model(vars, opti, dt, q0, dq0, L, COM, M, I, gravity, Fext, goal, ddq, dq, q);

% Optimize options
opti.solver('ipopt');

% Optimize joint velocity
fprintf("----------------------------------------------------------\n\n\nSolving problem 1: joint velocity minimization.\n\n\n----------------------------------------------------------\n");
opti.minimize(vars.costs.joint_vel_cost);
sol_1 = opti.solve();

% Optimize torque
fprintf("----------------------------------------------------------\n\n\nSolving problem 2: joint torque minimization.\n\n\n----------------------------------------------------------\n");
opti.minimize(vars.costs.joint_torque_cost);
sol_2 = opti.solve();

% Optimize ee velocity
fprintf("----------------------------------------------------------\n\n\nSolving problem 3: cartesian velocity minimization.\n\n\n----------------------------------------------------------\n");
opti.minimize(vars.costs.ee_vel_cost);
sol_3 = opti.solve();

% Optimize torque change
fprintf("----------------------------------------------------------\n\n\nSolving problem 4: joint torque change minimization.\n\n\n----------------------------------------------------------\n");
opti.minimize(vars.costs.joint_torque_change_cost);
sol_4 = opti.solve();

% Optimize joint jerk
fprintf("----------------------------------------------------------\n\n\nSolving problem 5: joint jerk minimization.\n\n\n----------------------------------------------------------\n");
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
plot_traj_from_vars(num_vars_1, 8);
plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
axis('equal');
expandAxes(1.2);
grid;
xlabel('Sagittal axis: $x$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
ylabel('Vertical axis: $z$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
ax = gca; ax.FontSize = 25; ax.TickLabelInterpreter = 'latex';
% exportgraphics(gcf, "../../img/1-min-joint-velocity.pdf", 'ContentType', 'vector');
exportgraphics(gcf, "../../img/1-min-joint-velocity.png", 'ContentType', 'image', 'Resolution', 600);

figure('WindowState', 'maximized');
hold all;
plot_traj_from_vars(num_vars_2, 8);
plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
axis('equal');
expandAxes(1.2);
grid;
xlabel('Sagittal axis: $x$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
ylabel('Vertical axis: $z$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
ax = gca; ax.FontSize = 25; ax.TickLabelInterpreter = 'latex';
% exportgraphics(gcf, "../../img/2-min-joint-torque.pdf", 'ContentType', 'vector');
exportgraphics(gcf, "../../img/2-min-joint-torque.png", 'ContentType', 'image', 'Resolution', 600);

figure('WindowState', 'maximized');
hold all;
plot_traj_from_vars(num_vars_3, 8);
plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
axis('equal');
expandAxes(1.2);
grid;
xlabel('Sagittal axis: $x$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
ylabel('Vertical axis: $z$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
ax = gca; ax.FontSize = 25; ax.TickLabelInterpreter = 'latex';
% exportgraphics(gcf, "../../img/3-min-ee-velocity.pdf", 'ContentType', 'vector');
exportgraphics(gcf, "../../img/3-min-ee-velocity.png", 'ContentType', 'image', 'Resolution', 600);

figure('WindowState', 'maximized');
hold all;
plot_traj_from_vars(num_vars_4, 8);
plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
axis('equal');
expandAxes(1.2);
grid;
xlabel('Sagittal axis: $x$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
ylabel('Vertical axis: $z$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
ax = gca; ax.FontSize = 25; ax.TickLabelInterpreter = 'latex';
% exportgraphics(gcf, "../../img/4-min-joint-torque-change.pdf", 'ContentType', 'vector');
exportgraphics(gcf, "../../img/4-min-joint-torque-change.png", 'ContentType', 'image', 'Resolution', 600);

figure('WindowState', 'maximized');
hold all;
plot_traj_from_vars(num_vars_5, 8);
plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
axis('equal');
expandAxes(1.2);
grid;
xlabel('Sagittal axis: $x$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
ylabel('Vertical axis: $z$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
ax = gca; ax.FontSize = 25; ax.TickLabelInterpreter = 'latex';
% exportgraphics(gcf, "../../img/5-min-joint-jerk.pdf", 'ContentType', 'vector');
exportgraphics(gcf, "../../img/5-min-joint-jerk.png", 'ContentType', 'image', 'Resolution', 600);

figure('WindowState','maximized');
hold on;
plot_joint_traj_from_vars(num_vars_1);
plot_joint_traj_from_vars(num_vars_2);
plot_joint_traj_from_vars(num_vars_3);
plot_joint_traj_from_vars(num_vars_4);
plot_joint_traj_from_vars(num_vars_5);
legend({"Joint Velocity", "Joint torque", "Cartesian Velocity", "Joint torque change", "Joint jerk"}, 'location', 'eastoutside', 'interpreter', 'latex');

figure('WindowState','maximized');
hold on;
plot_compared_costs(num_vars_1, num_vars_2, num_vars_3, num_vars_4, num_vars_5);
% set(gca, 'YScale', 'log');
legend({"Joint Velocity", "Joint torque", "Cartesian Velocity", "Joint torque change", "Joint jerk"}, 'location', 'eastoutside', 'interpreter', 'latex');


figure('WindowState','maximized');
hold on;
plot_segment_vels_from_vars(num_vars_1);
plot_segment_vels_from_vars(num_vars_2);
plot_segment_vels_from_vars(num_vars_3);
plot_segment_vels_from_vars(num_vars_4);
plot_segment_vels_from_vars(num_vars_5);
legend({"Joint Velocity", "Joint torque", "Cartesian Velocity", "Joint torque change", "Joint jerk"}, 'location', 'eastoutside', 'interpreter', 'latex');


% TileFigures