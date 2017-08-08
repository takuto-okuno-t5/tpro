% Step 3: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [assignment, distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows] = ...
    assignstep3(distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows, minDim)

    zerosFound = 1;
    while zerosFound

        zerosFound = 0;
        for col = find(~coveredColumns)
            for row = find(~coveredRows')
                if distMatrix(row,col) == 0

                    primeMatrix(row, col) = 1;
                    starCol = find(starMatrix(row,:));
                    if isempty(starCol)
                        % move to step 4
                        [assignment, distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows] = ...
                            assignstep4(distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows, row, col, minDim);
                        return
                    else
                        coveredRows(row)        = 1;
                        coveredColumns(starCol) = 0;
                        zerosFound              = 1;
                        break % go on in next column
                    end
                end
            end
        end
    end
    
    % move to step 5
    [assignment, distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows] = ...
        assignstep5(distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows, minDim);
end
