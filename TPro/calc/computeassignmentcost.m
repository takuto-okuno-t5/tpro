%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [assignment, cost] = computeassignmentcost(assignment, distMatrix, nOfRows)
    rowIndex   = find(assignment);
    costVector = distMatrix(rowIndex + nOfRows * (assignment(rowIndex)-1));
    finiteIndex = isfinite(costVector);
    cost = sum(costVector(finiteIndex));
    assignment(rowIndex(~finiteIndex)) = 0;
end