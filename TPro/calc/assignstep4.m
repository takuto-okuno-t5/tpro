% Step 4: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [assignment, distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows] = ...
    assignstep4(distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows, row, col, minDim)

    newStarMatrix          = starMatrix;
    newStarMatrix(row,col) = 1;

    starCol = col;
    starRow = find(starMatrix(:, starCol));

    while ~isempty(starRow)

        % unstar the starred zero
        newStarMatrix(starRow, starCol) = 0;

        % find primed zero in row
        primeRow = starRow;
        primeCol = find(primeMatrix(primeRow, :));

        % star the primed zero
        newStarMatrix(primeRow, primeCol) = 1;

        % find starred zero in column
        starCol = primeCol;
        starRow = find(starMatrix(:, starCol));

    end
    starMatrix = newStarMatrix;

    primeMatrix(:) = 0;
    coveredRows(:) = 0;

    % move to step 2
    [assignment, distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows] = ...
        assignstep2(distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows, minDim);
end