%%
function clustered = calcClasteringAndPlot(handles, t, numCluster, type1, type2, type3, cname)
    % clastering
    tsize = size(t,1);
    points = zeros(tsize,3);
    x = zeros(tsize,1);
    y = zeros(tsize,1);
    z = zeros(tsize,1);
    for j = 1:tsize
        points(j,:) = [t{j}(1,5) t{j}(1,6) t{j}(1,7)];
        x(j) = t{j}(1,5);
        y(j) = t{j}(1,6);
        z(j) = t{j}(1,7);
    end
    try
        dist = pdist(points);
        tree = linkage(dist,'average');
        c = cophenet(tree,dist)
    catch e
        errordlg(e.message, 'Error');
        throw(e);
    end
%    clustered = cluster(tree,'cutoff',1.2);
%    clustered = cluster(tree,'maxclust',50);

    % plot Scatter
    f = figure;
    set(f, 'name', [cname, ' scatter']); % set window title
    scatter(x,y);

    % plot dendrogram
    f = figure;
    set(f, 'name', [cname, ' dendrogram']); % set window title
    [h,clustered,outperm] = dendrogram(tree, numCluster);
    ax = gca; % current axes
    ax.FontSize = 6;
end
