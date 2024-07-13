function F = backward_propagation(Fcom, Fext, Pcom, P, M, gravity)
%Fcom = Fi - Fi+1 + M*gravity + Fext
%Fi = Fcom + Fi+1 - M*gravity - Fext
%Ncom = Ni - Ni+1 + Next + (-Ci) x Fi - Pi x Fi+1
%Ni = Ncom + Ni+1 - Next + Ci x Fi + Pi x Fi+1


n = length(Fcom);
N = size(Fcom{end}, 2);

F = cell(n+1, 1);
for ii = n + 1 : -1 : 1
    F{ii} = zeros(3, N, class(Fcom{end}));
end

for ii = n : - 1 : 1

    Ci = Pcom{ii} - P{ii};
    Pi = P{ii + 1} - Pcom{ii};

    F{ii}(1, :) = Fcom{ii}(1, :) + F{ii + 1}(1, :) - M(ii) * gravity(1) - Fext{ii}(1, :);
    F{ii}(2, :) = Fcom{ii}(2, :) + F{ii + 1}(2, :) - M(ii) * gravity(2) - Fext{ii}(2, :);
    F{ii}(3, :) = Fcom{ii}(3, :) + F{ii + 1}(3, :) - Fext{ii}(3, :) ...
                      + Ci(1, :) .* F{ii}(2, :) - Ci(2, :) .* F{ii}(1, :) ...
                      + Pi(1, :) .* F{ii + 1}(2, :) - Pi(2, :) .* F{ii + 1}(1, :);
end

end