function matchedFrame = referenceFrameMatch(inputFrame, targetFrame)
%REFERENCEFRAMEMATCH looks at dot products between axes of the input frame
%and the axes of the target frame, then permutes the order of the axes of
%the input frame and adjusts their direction so that they match the target
%frame. This is equivalent to having positive elements on the diagonal of
%inputFrame.' * targetFrame, such that the elements on the diagonal are
%also the largest by absolute value in their column and their row.

prodMat = targetFrame.' * inputFrame;
absProdMat = abs(prodMat);
sgnProdMat = sign(prodMat);

[~, permuationVector] = max(absProdMat, [], 2);

% Construct output
matchedFrame = inputFrame(:, permuationVector);
matchedFrame = diag(diag(sgnProdMat(:, permuationVector))) * matchedFrame;
end