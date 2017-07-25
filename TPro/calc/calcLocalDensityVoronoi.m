% calculate local density (voronoi)
function result = calcLocalDensityVoronoi(X, Y, roiMask, roiX, roiY)
    xsize = length(X);
    result = zeros(length(xsize),1);
    tic;
    % calc roi unique points
    if ~isempty(roiX)
        last = length(roiX);
        if roiX(1) == roiX(last) && roiY(1) == roiY(last)
            roiX(last) = [];
            roiY(last) = [];
        end
    end
    % calc voronoi
    for row_count = 1:xsize
        % get detected points and roi points
        fy = Y{row_count}(:);
        fx = X{row_count}(:);
        flyCount = length(fy);
        if ~isempty(roiX)
            fy = [fy; roiX(:)];
            fx = [fx; roiY(:)];
        end
        
        DT = delaunayTriangulation(fy,fx);
        [V,R] = voronoiDiagram(DT);
%        sharedInst.V{row_count} = V;
%        sharedInst.R{row_count} = R;
        area = zeros(flyCount,1);
        for j=1:flyCount
            poly = V(R{j},:);
            area(j) = polyarea(poly(:,1),poly(:,2));
        end
        totalArea = nansum(area);
        result(row_count) = 1 / (totalArea / flyCount);
%        sharedInst.vArea{row_count} = area;
    end
    time = toc;
    disp(['calcLocalDensityVoronoi ... done : ' num2str(time) 's']);
end
