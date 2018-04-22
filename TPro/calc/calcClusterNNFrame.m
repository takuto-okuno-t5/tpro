% ----- calculate nearest neighbor clustering (frame) -----
function [result, wcount] = calcClusterNNFrame(x, y, method, distance)
    % calc nearest neighbor clustering
    pts = [x, y];
    dist = pdist(pts);
    tree = linkage(dist,method);
    wcount = calcWeightedGroupCountFrame(tree, size(pts,1), distance);
    result = cluster(tree,'cutoff',distance,'criterion','distance');
end
