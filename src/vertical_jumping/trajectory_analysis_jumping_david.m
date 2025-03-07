% n = 3;
% N = 108;
% T = 1.2;

% if n == 6
%     % n = 4;
%     N = find(ivars.functions.F{1}(2, :) < 0, 1);
%     q = q_ik;
% end
q = q_ik;

warmStartName = sprintf("warmStart-n%02d-N%04d.mat", n, N);
[opti, vars] = make_ndof_jumping_model(n, N);


%% Parameters
% dt = 0.01;
% dt = T / (N-1);
T = (N-1)*dt;

Mtot = 77.3;    
Htot = 1.77;

mu = 0.6;

if n == 3
    L = [0.433; 0.432; (93+151+334)/1000; 0.277; (283 + 80) / 1000];
    L = L(1:n);
    COM = vertcat(.5 * ones(1, n), zeros(1, n)) .* L.';
    M = [2 * 0.048; 2 * 0.123; (14.2 + 2.9 + 30.4 + 6.7) / 100; 2 * 0.024; 2 * 0.017] .* Mtot;
    M = [M(1:n-1); sum(M(n:end))];
    I = 1/12 * M .* L;
        
    [qmin, qmax] = humanJointLimits(n);
    [dqmin, dqmax] = humanVelocityLimits(n);
    [taumin, taumax] = humanTorqueLimits(n);
    [zmpmin, zmpmax] = humanZmpLimits(n);
elseif n == 6 || n == 4
    L = [0.139; 0.433; 0.432; (93+151+334)/1000; 0.277; (283 + 80) / 1000];
    L = L(1:n);
    COM = vertcat(.5 * ones(1, n), zeros(1, n)) .* L.';
    M = [2 * 0.012; 2 * 0.048; 2 * 0.123; (14.2 + 2.9 + 30.4 + 6.7) / 100; 2 * 0.024; 2 * 0.017] .* Mtot;
    M = [M(1:n-1); sum(M(n:end))];
    I = 1/12 * M .* L;

    [qmin, qmax] = humanJointLimits(n,true);
    [dqmin, dqmax] = humanVelocityLimits(n);
    [taumin, taumax] = humanTorqueLimits(n,true);
    [zmpmin, zmpmax] = humanZmpLimits(n);
end

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
% q = [pi/2 * ones(1, N); zeros(n-1, N)];
if n == 3
    q = [pi/2 - 0.5*sin(((1:N)-1)/(N-1)*pi); 1.3*sin(((1:N)-1)/(N-1)*pi); -1.3*sin(((1:N)-1)/(N-1)*pi)];
    q = q(1:n, :);
else
    q = q(1:n,1:N);
end
% noise = deg2rad(3 / (N)) * randn(size(q));
% q = q + noise;


% goal = [2; 0];
% q = [ ...
%     linspace(q0(1, 1), q0(1, end), N);
%     linspace(q0(2, 1), q0(2, end), N); 
% ];

dq = diff(q, 1, 2) ./ dt;
dq = [dq, dq(:, end)];
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
instantiate_ndof_jumping_model(vars, opti, dt, q0, dq0, mu, L, COM, M, I, qmin, qmax, dqmin, dqmax, taumin, taumax, zmpmin, zmpmax, gravity, Fext, ddq, dq, q);
ivars = numerize_vars(vars, opti, true);



            % + (5.0e+00 * 2.4664e+00) * vars.costs.com_horizontal_vel_cost ...
            % + (1.0e+00 * 1.0400e-01) * vars.costs.hip_behind_com ...
            % + (-1.00e+00) *  vars.functions.Vcomtotal(2, end) ...


% Optimize options
opti.solver('ipopt', struct(), struct("max_iter", 10000));
opti.minimize(5.0e+01*vars.costs.max_com_height_cost ...
            + (-2.00e+00) * vars.functions.Vcomtotal(2, end) ...
            + (-1.00e+01) *  vars.functions.Pcomtotal(2, end) ...
            + (5.0e+01 * 2.4664e+00) * (vars.functions.Vcomtotal(1, end)).^2 ...
            + (1.0e-01/2 * 9.5500e-02) * vars.costs.avg_joint_vel_cost ...
            + (1.0e-01/2 * 1.3469e-04) * vars.costs.avg_joint_acc_cost ...
            + (1.0e-01/1 * 2.8494e-05) * vars.costs.avg_joint_torque_cost ...
            + (1.0e-01/1 * 5.0561e-08) * vars.costs.avg_joint_torque_change_cost ...
);
% opti.minimize(vars.costs.max_com_height_cost);
% opti.minimize(vars.costs.takeoff_grf_cost + 100*sum(sum((vars.variables.q - q).^2)) - 1e4*vars.functions.Vcomtotal(2, end).^2);
sol_1 = opti.solve();

% Numerize
nvars = numerize_vars(vars, sol_1);

[constraints_violated, constraint_violations] = determine_infeasibility_from_vars(nvars)

%%
close all

figure('WindowState', 'maximized');
hold all;
plot_snapshots_from_vars(nvars, 4);
axis('equal');
expandAxes(1.2);
grid;
xlabel('Sagittal axis: $x$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
ylabel('Vertical axis: $z$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
ax = gca; ax.FontSize = 25; ax.TickLabelInterpreter = 'latex';

figure('WindowState', 'maximized');
hold all;
plot_separate_snapshots_from_vars(nvars, 12);

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

figure('WindowState','maximized');
hold on;
plot_zmp_from_vars(nvars, 'LineWidth', 2);

%% Saving for warmStart
if ~isempty(input(sprintf("Any key then enter if the solution should be saved in %s:\n", warmStartName)))
    save(warmStartName, "nvars");
end

% TileFigures