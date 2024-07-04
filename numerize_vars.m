function num_vars = numerize_vars(vars, sol)
    % vars has 3 categories i.e. fields: variables, parameters, functions
    categories_ = fieldnames(vars);
    
    for category_ = categories_.'
        
        % for each category, all the quantities are computable
        computables_ = fieldnames(vars.(category_{1}));
    
        for computable_  = computables_.'
    
            % oftentimes computables are in cell arrays, so you have to extract
            % them
            if iscell(vars.(category_{1}).(computable_{1}))
                num_vars.(category_{1}).(computable_{1}) = cell(size(vars.(category_{1}).(computable_{1})));
                for ii = 1 : length(vars.(category_{1}).(computable_{1}))
                    num_vars.(category_{1}).(computable_{1}){ii} = sol.value(vars.(category_{1}).(computable_{1}){ii});
                end
            % other times, the computables are directly stored
            else
                num_vars.(category_{1}).(computable_{1}) = sol.value(vars.(category_{1}).(computable_{1}));
            end
        end   
    end

end