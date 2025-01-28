function num_vars = numerize_vars(vars, opti, varargin)
    % Flag dictating if the vars should be evaluated at the initial
    % solution. This is because you cannot evaluate opti before optimizing.
    if nargin >= 3
        initialFlag = varargin{1};
    else
        initialFlag = false;
    end
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
                    if ~initialFlag
                        num_vars.(category_{1}).(computable_{1}){ii} = opti.value(vars.(category_{1}).(computable_{1}){ii});
                    else
                        num_vars.(category_{1}).(computable_{1}){ii} = opti.value(vars.(category_{1}).(computable_{1}){ii}, opti.initial());
                    end
                end
            % other times, the computables are directly stored
            else
                if ~initialFlag
                    num_vars.(category_{1}).(computable_{1}) = opti.value(vars.(category_{1}).(computable_{1}));
                else
                    num_vars.(category_{1}).(computable_{1}) = opti.value(vars.(category_{1}).(computable_{1}), opti.initial());
                end
            end
        end   
    end

end