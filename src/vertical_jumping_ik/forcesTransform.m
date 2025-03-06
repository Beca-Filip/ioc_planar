function Forces6DTransformed = forcesTransform(Transforms, Forces6D)
    %FORCESTRANSFORM applies transformation to 6D forces.
    %
    %   Forces6D - Tx6xN or 6xTxN array of 6D forces.
    %   Transforms - 4x4xN array of homogeneous transformation matrices.
    %
    %   Output:
    %   Forces6DTransformed - Tx6xN array of trasnformed 6D forces.

    % Check Transforms size
    szTransforms = size(Transforms);
    if szTransforms(1) ~= 4 || szTransforms(2) ~=4
        error("batchSpatialForceTransforms:Transforms must have the first 2 dimensions equal to 4.");        
    end
    
    % Check Forces6D size
    szForces6D = size(Forces6D);
    if szForces6D(1) ~= 6 && szForces6D(2) ~= 6
        error("batchSpatialForceTransforms:Forces6D must have at least one of the first 2 dimensions equal to 6.");
    end

    % Bring Forces6D to Tx6xN1xN2x... through Forces6DTransformed 
    if szForces6D(1) == 6
        T = szForces6D(2);
        Forces6DTransformed = pagetranspose(Forces6D);
    elseif szForces6D(2) == 6
        T = szForces6D(1);
        Forces6DTransformed = Forces6D;
    end

    % Transform
    Forces6DTransformed(:, 1:3, :) = pagetranspose(pagemtimes(Transforms(1:3, 1:3, :), 'none', Forces6DTransformed(:, 1:3, :), 'transpose'));
    Forces6DTransformed(:, 4:6, :) = pagetranspose(pagemtimes(Transforms(1:3, 1:3, :), 'none', Forces6DTransformed(:, 4:6, :), 'transpose')) ...
        + cross(Forces6DTransformed(:, 1:3, :), repmat(pagetranspose(Transforms(1:3, 4, :)), [T, ones(1, ndims(Transforms))]), 2);
end