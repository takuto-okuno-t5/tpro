% ----- calculate nearest neighbor clustering (frame) -----
function result = calcClusterNNFrame(x, y, method, distance)
    % calc nearest neighbor clustering
    pts = [x, y];
    dist = pdist(pts);
    tree = linkage(dist,method);
    result = cluster(tree,'cutoff',distance,'criterion','distance');
end
