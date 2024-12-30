close all

n = 2;
% N = 20;
% T = 1.5;
N = 120;
T = 1.2;

% 
rng(420);
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
theta_1 = [1, 5000, 1, 1, 1];
% theta_1 = [1, 200, 500, 300, 1];
% theta_1 = [1, 5000, 1];
theta_1 = theta_1 ./ sum(theta_1);
instantiate_parametrized_ndof_cf(vars, opti, theta_1);
% Solve
sol_1 = opti.solve();
% Numerize
lambda_1 = sol_1.value(opti.lam_g); % Extract dual variables
num_vars_1 = numerize_vars(vars, sol_1);

% Optimize other stuff
theta_2 = [200, 150, 30, 1, 1];
% theta_2 = [200, 150, 30];
theta_2 = theta_2 ./ sum(theta_2);
instantiate_parametrized_ndof_cf(vars, opti, theta_2);
sol_2 = opti.solve();
% Numerize
lambda_2 = sol_2.value(opti.lam_g); % Extract dual variables
num_vars_2 = numerize_vars(vars, sol_2);

%% Make IOC

[opti_ioc, vars_ioc] = make_ndof_ioc_model(n, N);

% Instantiate
instantiate_ndof_model(vars_ioc, opti_ioc, dt, q0, dq0, L, COM, M, I, gravity, Fext, goal, num_vars_2.variables.ddq, num_vars_2.variables.dq, num_vars_2.variables.q);

% Do IOC with different noise levels
Nnoise = 11;
noise_level_1 = logspace(-1, 1, Nnoise);
noise_level_2 = logspace(-1, 1, Nnoise);
Theta = nan(size(vars_ioc.variables.theta, 1), Nnoise, Nnoise);
ThetaErr = nan(Nnoise, Nnoise);
TrajErr = nan(Nnoise, Nnoise);

% Initialize noisy
num_vars_noisy = num_vars_1;

for ii = 1 : Nnoise
    for jj = 1 : Nnoise
        noise_variance = diag(deg2rad([noise_level_1(ii), noise_level_2(jj)]));
        noise = noise_variance * randn(size(num_vars_1.variables.q));
        num_vars_noisy.variables.q = num_vars_1.variables.q + noise;
        instantiate_ndof_ioc(vars_ioc, opti_ioc, lambda_2, theta_2, num_vars_noisy.variables.q);

        % Optimize options
        opti_ioc.solver('ipopt');
        sol_ioc = opti_ioc.solve();
        
        % Numerize
        num_vars_ioc = numerize_vars(vars_ioc, sol_ioc);

        % Store
        Theta(:, ii, jj) = num_vars_ioc.variables.theta;
        ThetaErr(ii, jj) = norm(num_vars_ioc.variables.theta - reshape(theta_1, [], 1));
        TrajErr(ii, jj) = sqrt(num_vars_ioc.target.loss ./ numel(num_vars_ioc.variables.q));

        % Print identification
        printFormat = sprintf("True theta = [%s]\nId.  theta = [%s].\n", repmat('%.4f, ', 1, length(theta_1)), repmat('%.4f, ', 1, length(theta_1)));
        fprintf(printFormat, theta_1, num_vars_ioc.variables.theta);
    end
end

% Make grid
[noise_grid_1, noise_grid_2] = meshgrid(noise_level_1, noise_level_2);

%%

% Parameter errors
figure('Position', [100, 100, 700, 500]);
surf(noise_grid_1, noise_grid_2, ThetaErr.');
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
view(2);
c = colorbar; % Adds a color bar and returns its handle
ylabel(c, {'Distance $\| \hat{\theta} - \theta \|_2$ between the true and the'; 'retrieved objective function parameters [1]'}, 'Interpreter', 'latex', 'FontSize', 15); % Labels the color bar
caxis([min(ThetaErr(:)) max(ThetaErr(:))]); % Optional: Sets the color axis limits to the range of ThetaErr

xlabel({"Variance $\sigma_1$ of noise added"; "to the first joint's trajectory [$^\circ$]"}, 'Interpreter', 'latex', 'FontSize', 15);
ylabel({"Variance $\sigma_2$ of noise added"; "to the second joint's trajectory [$^\circ$]"}, 'Interpreter', 'latex', 'FontSize', 15);
ax = gca; ax.FontSize = 15; ax.TickLabelInterpreter = 'latex';

axis('square');

% Trajectory errors
degTrajErr = rad2deg(TrajErr).';

figure('Position', [100, 100, 700, 500]);
surf(noise_grid_1, noise_grid_2, degTrajErr);
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
view(2);
c = colorbar; % Adds a color bar and returns its handle
ylabel(c, {'RMSE $\sqrt{\frac{1}{2N} \sum_{i} \sum_{k} (\hat{q}_{k, i} - q_{k, i})^2}$ between the noisy'; 'true and the retrieved optimal trajectory [$^\circ$]'}, 'Interpreter', 'latex', 'FontSize', 15); % Labels the color bar

xlabel({"Variance $\sigma_1$ of noise added"; "to the first joint's trajectory [$^\circ$]"}, 'Interpreter', 'latex', 'FontSize', 15);
ylabel({"Variance $\sigma_2$ of noise added"; "to the second joint's trajectory [$^\circ$]"}, 'Interpreter', 'latex', 'FontSize', 15);
ax = gca; ax.FontSize = 15; ax.TickLabelInterpreter = 'latex';

axis('square');

% Saving figures
% TileFigures
%%
figure(1)
exportgraphics(gcf, "../../img/ThetaErr.pdf", "ContentType", "vector");
exportgraphics(gcf, "../../img/ThetaErr.png", "ContentType", "image", "Resolution", 600);

figure(2)
exportgraphics(gcf, "../../img/TrajErr.pdf", "ContentType", "vector");
exportgraphics(gcf, "../../img/TrajErr.png", "ContentType", "image", "Resolution", 600);

%%
% close all
% 
% figure('WindowState', 'maximized');
% hold all;
% plot_traj_from_vars(num_vars_1, 10);
% plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
% axis('equal');
% 
% figure('WindowState', 'maximized');
% hold all;
% plot_traj_from_vars(num_vars_2, 10);
% plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
% axis('equal');
% 
% figure('WindowState', 'maximized');
% hold all;
% plot_traj_from_vars(num_vars_ioc, 10);
% plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
% axis('equal');
% 
% figure('WindowState','maximized');
% hold on;
% plot_joint_traj_from_vars(num_vars_1);
% plot_joint_traj_from_vars(num_vars_noisy);
% % plot_joint_traj_from_vars(num_vars_2);
% plot_joint_traj_from_vars(num_vars_ioc);
% 
% % figure('WindowState','maximized');
% % hold on;
% % plot_compared_costs(num_vars_1);
% % plot_compared_costs(num_vars_2);
% % plot_compared_costs(num_vars_ioc);
% 
% 
% figure('WindowState','maximized');
% hold on;
% plot_segment_vels_from_vars(num_vars_1);
% plot_segment_vels_from_vars(num_vars_2);
% plot_segment_vels_from_vars(num_vars_ioc);
% 
% TileFigures