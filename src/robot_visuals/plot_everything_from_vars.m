function plot_everything_from_vars(vars)

    figure('WindowState', 'maximized');
    hold all;
    plot_snapshots_from_vars(vars, 4);
    axis('equal');
    expandAxes(1.2);
    grid;
    xlabel('Sagittal axis: $x$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
    ylabel('Vertical axis: $z$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
    ax = gca; ax.FontSize = 25; ax.TickLabelInterpreter = 'latex';

    figure('WindowState', 'maximized');
    hold all;
    plot_separate_snapshots_from_vars(vars, 12);
    
    figure('WindowState','maximized');
    hold on;
    plot_joint_traj_from_vars(vars, 'LineWidth', 2);
    
    figure('WindowState','maximized');
    hold on;
    plot_segment_pos_from_vars(vars, 'LineWidth', 2);
    
    figure('WindowState','maximized');
    hold on;
    plot_segment_vels_from_vars(vars, 'LineWidth', 2);

    figure('WindowState','maximized');
    hold on;
    plot_segment_accs_from_vars(vars, 'LineWidth', 2);
    
    figure('WindowState','maximized');
    hold on;
    plot_com_pos_from_vars(vars, 'LineWidth', 2);
    
    figure('WindowState','maximized');
    hold on;
    plot_com_vels_from_vars(vars, 'LineWidth', 2);
    
    figure('WindowState','maximized');
    hold on;
    plot_com_accs_from_vars(vars, 'LineWidth', 2);
    
    figure('WindowState','maximized');
    hold on;
    plot_total_com_kinematics_from_vars(vars, 'LineWidth', 2);
    
    figure('WindowState','maximized');
    hold on;
    plot_grfs_from_vars(vars, 'LineWidth', 2);
    
    figure('WindowState','maximized');
    hold on;
    plot_zmp_from_vars(vars, 'LineWidth', 2);

end