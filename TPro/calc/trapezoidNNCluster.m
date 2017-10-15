%%
function result = trapezoidNNCluster(handles, addResultToAxesCallback)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    % show nnClusteringStartDialog
    [dlg, flyIDs, numClusters, type1, type2] = nnClusteringStartDialog({});
    delete(dlg);
    if numClusters < 0
        return;
    end
    type3 = 'none'; % TODO: currently dummy
    
    % ----- clustering loop -----
    i = 0;
    while true
        switch type1
        case 'velocity'
            v1str = 'v';
        end
        switch type2
        case 'acceralation'
            v2str = 'acc';
        case 'circularity'
            v2str = 'cir';
        case 'angle_velocity'
            v2str = 'av';
        case 'sideways'
            v2str = 'side';
        case 'sideways_velocity'
            v2str = 'sv';
        end
            
        i = i + 1;
        cname = [v1str '_' v2str '_nn_clustering' num2str(i)];
        % show wait dialog
        hWaitBar = waitbar(0,'processing ...','Name',['clustering ', sharedInst.shuttleVideo.name]);
        if i==1
            % get cells of TrapezoidList {flynum, beginframe, endframe, 0, maxvalue, slope}
            t = getTrapezoidList(handles, type1, type2, type3, flyIDs);
        else
            t = getTrapezoidListInCluster(handles, t, clustered, type1, type2, type3, clusterIDs);
        end
        updateWaitbar(0.2, hWaitBar);
        
        clustered = calcClasteringAndPlot(handles, t, numClusters, type1, type2, type3, cname);
        updateWaitbar(0.5, hWaitBar);

        result = saveClusteredCsvAndShow(handles, t, clustered, type1, type2, type3, [cname '.txt']);
        updateWaitbar(0.8, hWaitBar);

        % delete dialog bar
        delete(hWaitBar);
        
        % add clustering result to axes
        if ~isempty(addResultToAxesCallback)
            addResultToAxesCallback(handles, result, [cname '_result']);
        end

        % show nnClusteringContinueDialog
        [dlg, clusterIDs, numClusters, type1, type2] = nnClusteringContinueDialog({});
        delete(dlg);
        if numClusters < 0
            break;
        end
    end
end
