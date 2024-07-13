function plot_compared_costs(varargin)
    num_vars = varargin;
    cost_names = fieldnames(num_vars{1}.costs);
    
    cost_vals = zeros(length(num_vars), length(cost_names));

    for i_vars = 1 : length(num_vars)
        for i_cost = 1 : length(cost_names)
            cost_vals(i_vars, i_cost) = num_vars{i_vars}.costs.(cost_names{i_cost});
        end
    end

    max_cost_vals = max(cost_vals, [], 1);
    norm_cost_vals = cost_vals ./ max_cost_vals;
    
    bar( ...
        1 : length(cost_names), norm_cost_vals ...
    );

    for ii = 1 : length(max_cost_vals)
        text(ii, 1, sprintf("Scale: %.4e", max_cost_vals(ii)), 'FontSize', 10, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    end

    xticks(1 : length(cost_names));
    xticklabels(cost_names);
end