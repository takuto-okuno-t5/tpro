%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function assignment = buildassignmentvector(starMatrix)
    [maxValue, assignment] = max(starMatrix, [], 2);
    assignment(maxValue == 0) = 0;
end