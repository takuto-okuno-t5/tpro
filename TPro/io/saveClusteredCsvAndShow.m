%% save a cluster csv
function result = saveClusteredCsvAndShow(handles, t, clustered, type1, type2, type3, filename)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    frame_num = size(sharedInst.vxy, 1);
    fly_num = size(sharedInst.vxy, 2);
    tsize = size(t,1);

    result = zeros(frame_num,fly_num);
    t2 = cell(tsize,8);
    for j = 1:tsize
        t3 = t{j}(1,:);
        t2(j,:) = {t3(1) t3(2) t3(3) t3(4) t3(5) t3(6) t3(7) clustered(j)};
        result(t3(2):t3(3), t3(1)) = clustered(j);
    end
    T = cell2table(t2);
    header = {'FlyNo', 'StartFrame', 'EndFrame', 'Dmy', type1, type2, type3, 'Cluster'};
    T.Properties.VariableNames = header;

    clusterFileName = [sharedInst.confPath 'output/' filename];
    writetable(T,clusterFileName, 'delimiter', '\t');
    winopen(clusterFileName);
end
