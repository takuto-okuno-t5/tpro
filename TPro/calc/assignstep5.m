% Step 5: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [assignment, distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows] = ...
    assignstep5(distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows, minDim)

    % find smallest uncovered element
    uncoveredRowsIndex    = find(~coveredRows');
    uncoveredColumnsIndex = find(~coveredColumns);
    [s, index1] = min(distMatrix(uncoveredRowsIndex,uncoveredColumnsIndex));
    [s, index2] = min(s); %#ok
    h = distMatrix(uncoveredRowsIndex(index1(index2)), uncoveredColumnsIndex(index2));

    % add h to each covered row
    index = find(coveredRows);
    distMatrix(index, :) = distMatrix(index, :) + h;

    % subtract h from each uncovered column
    distMatrix(:, uncoveredColumnsIndex) = distMatrix(:, uncoveredColumnsIndex) - h;

    % move to step 3
    [assignment, distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows] = ...
        assignstep3(distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows, minDim);
end