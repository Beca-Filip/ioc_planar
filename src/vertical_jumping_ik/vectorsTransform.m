function Vectors3DTransformed = vectorsTransform(Transforms, Vectors3D)
    % applies batch transformation to 3D vectors.
    %
    %   Vectors3D - Tx3xN or 3xTxN array of 3D vectors.
    %   Transforms - 4x4xN array of homogeneous transformation matrices.
    %
    %   Output:
    %   Vectors3DTransformed - Tx3xN array of transformed 3D vectors.

    % Check Transforms size
    szTransforms = size(Transforms);
    if szTransforms(1) ~= 4 || szTransforms(2) ~=4
        error("batchSpatialForceTransforms:Transforms must have the first 2 dimensions equal to 4.");        
    end
    
    % Check Vectors3D size
    szVectors3D = size(Vectors3D);
    if szVectors3D(1) ~= 3 && szVectors3D(2) ~= 3
        error("batchSpatialForceTransforms:Vectors3D must have at least one of the first 2 dimensions equal to 3.");
    end

    % Bring Vectors3D to Tx3xN through Vectors3DTransformed 
    if szVectors3D(1) == 3
        T = szVectors3D(2);
        Vectors3DTransformed = pagetranspose(Vectors3D);
    elseif szVectors3D(2) == 3
        T = szVectors3D(1);
        Vectors3DTransformed = Vectors3D;
    end

    % Transform
    Vectors3DTransformed = pagetranspose(pagemtimes(Transforms(1:3, 1:3, :), 'none', Vectors3DTransformed(:, 1:3, :), 'transpose')) + pagetranspose(Transforms(1:3, 4, :));

end