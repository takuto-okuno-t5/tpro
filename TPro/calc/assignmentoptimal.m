%%
function [assignment, cost] = assignmentoptimal(distMatrix)
    %ASSIGNMENTOPTIMAL    Compute optimal assignment by Munkres algorithm
    %   ASSIGNMENTOPTIMAL(DISTMATRIX) computes the optimal assignment (minimum
    %   overall costs) for the given rectangular distance or cost matrix, for
    %   example the assignment of tracks (in rows) to observations (in
    %   columns). The result is a column vector containing the assigned column
    %   number in each row (or 0 if no assignment could be done).
    %
    %   [ASSIGNMENT, COST] = ASSIGNMENTOPTIMAL(DISTMATRIX) returns the
    %   assignment vector and the overall cost.
    %
    %   The distance matrix may contain infinite values (forbidden
    %   assignments). Internally, the infinite values are set to a very large
    %   finite number, so that the Munkres algorithm itself works on
    %   finite-number matrices. Before returning the assignment, all
    %   assignments with infinite distance are deleted (i.e. set to zero).
    %
    %   A description of Munkres algorithm (also called Hungarian algorithm)
    %   can easily be found on the web.
    %
    %   <a href="assignment.html">assignment.html</a>  <a href="http://www.mathworks.com/matlabcentral/fileexchange/6543">File Exchange</a>  <a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=EVW2A4G2HBVAU">Donate via PayPal</a>
    %
    %   Markus Buehren
    %   Last modified 05.07.2011

    % save original distMatrix for cost computation
    originalDistMatrix = distMatrix;

    % check for negative elements
    if any(distMatrix(:) < 0)
        error('All matrix elements have to be non-negative.');
    end

    % get matrix dimensions
    [nOfRows, nOfColumns] = size(distMatrix);

    % check for infinite values
    finiteIndex   = isfinite(distMatrix);
    infiniteIndex = find(~finiteIndex);
    if ~isempty(infiniteIndex)
        % set infinite values to large finite value
        maxFiniteValue = max(max(distMatrix(finiteIndex)));
        if maxFiniteValue > 0
            infValue = abs(10 * maxFiniteValue * nOfRows * nOfColumns);
        else
            infValue = 10;
        end
        if isempty(infValue)
            % all elements are infinite
            assignment = zeros(nOfRows, 1);
            cost       = 0;
            return
        end
        distMatrix(infiniteIndex) = infValue;
    end

    % memory allocation
    coveredColumns = zeros(1,       nOfColumns);
    coveredRows    = zeros(nOfRows, 1);
    starMatrix     = zeros(nOfRows, nOfColumns);
    primeMatrix    = zeros(nOfRows, nOfColumns);

    % preliminary steps
    if nOfRows <= nOfColumns
        minDim = nOfRows;

        % find the smallest element of each row
        minVector = min(distMatrix, [], 2);

        % subtract the smallest element of each row from the row
        distMatrix = distMatrix - repmat(minVector, 1, nOfColumns);

        % Steps 1 and 2
        for row = 1:nOfRows
            for col = find(distMatrix(row,:)==0)
                if ~coveredColumns(col)%~any(starMatrix(:,col))
                    starMatrix(row, col) = 1;
                    coveredColumns(col)  = 1;
                    break
                end
            end
        end

    else % nOfRows > nOfColumns
        minDim = nOfColumns;

        % find the smallest element of each column
        minVector = min(distMatrix);

        % subtract the smallest element of each column from the column
        distMatrix = distMatrix - repmat(minVector, nOfRows, 1);

        % Steps 1 and 2
        for col = 1:nOfColumns
            for row = find(distMatrix(:,col)==0)'
                if ~coveredRows(row)
                    starMatrix(row, col) = 1;
                    coveredColumns(col)  = 1;
                    coveredRows(row)     = 1;
                    break
                end
            end
        end
        coveredRows(:) = 0; % was used auxiliary above
    end

    if sum(coveredColumns) == minDim
        % algorithm finished
        assignment = buildassignmentvector(starMatrix);
    else
        % move to step 3
        [assignment, distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows] = ...
            assignstep3(distMatrix, starMatrix, primeMatrix, coveredColumns, coveredRows, minDim); %#ok
    end

    % compute cost and remove invalid assignments
    [assignment, cost] = computeassignmentcost(assignment, originalDistMatrix, nOfRows);
end