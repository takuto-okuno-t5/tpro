% Step 2: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [assignment, distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows] = ...
    assignstep2(distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows, minDim)

    % cover every column containing a starred zero
    maxValue = max(starMatrix);
    coveredColumns(maxValue == 1) = 1;

    if sum(coveredColumns) == minDim
        % algorithm finished
        assignment = buildassignmentvector(starMatrix);
    else
        % move to step 3
        [assignment, distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows] = ...
            assignstep3(distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows, minDim);
    end
end