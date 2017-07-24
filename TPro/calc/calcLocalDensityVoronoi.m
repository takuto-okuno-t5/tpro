% calculate local density (voronoi)
function result = calcLocalDensityVoronoi(X, Y, roiMasks, roiX, roiY, currentROI)
    xsize = length(X);
    result = zeros(length(xsize),1);
    tic;
    % calc roi unique points
    for i=1:length(roiX)
        [C,ia,ic] = unique(roiX{i}(:));
        roiX{i} = roiX{i}(ia);
        roiY{i} = roiY{i}(ia);
    end
    % calc voronoi
    for row_count = 1:xsize
        % get detected points and roi points
        fy = Y{row_count}(:);
        fx = X{row_count}(:);
        flyCount = length(fy);
        for i=1:length(roiMasks)
            if currentROI == 0 || (currentROI > 0 && currentROI==i)
                if ~isempty(roiX)
                    fy = [fy; roiX{i}(:)];
                    fx = [fx; roiY{i}(:)];
                end
            end
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
