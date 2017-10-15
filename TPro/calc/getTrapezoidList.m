%%
function list = getTrapezoidList(handles, type1, type2, type3, flyIDs)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    frame_num = size(sharedInst.vxy, 1);
    fly_num = size(sharedInst.vxy, 2);
    
    % count spike number
    spikeNum = sum(sum(sharedInst.updownVxy~=0)) - fly_num;
%    spikeNum = sum(updown(:,1)~=0) - 1;
    list = cell(spikeNum,1);
    
    j = 1;
    for fn = 1:fly_num
        if length(flyIDs) > 0 && sum(flyIDs==fn) == 0
            continue;
        end
        spikes = find(sharedInst.updownVxy(:,fn) ~= 0);
        for i = 1:(length(spikes)-1)
            % clustering value 1
            switch type1
            case 'velocity'
                f1 = sharedInst.vxy(spikes(i), fn);
                f2 = sharedInst.vxy(spikes(i+1), fn);
                v1 = max([f1 f2]);
            end
            % clustering value 2
            switch type2
            case 'acceralation'
                v2 = abs((f2 - f1) / (spikes(i+1) - spikes(i)));
            case 'circularity'
                v2 = (1 - min(sharedInst.ecc(spikes(i):spikes(i+1), fn))) * 100;
            case 'angle_velocity'
                v2 = max(sharedInst.av(spikes(i):spikes(i+1), fn));
            case 'sideways'
                v2 = max(sharedInst.sideways(spikes(i):spikes(i+1), fn)) * 100;
            case 'sideways_velocity'
                v2 = max(sharedInst.sidewaysVelocity(spikes(i):spikes(i+1), fn));
            end
            % clustering value 3
            v3 = 0;
            
            if ~isnan(v2)
                list{j} = [fn, spikes(i), spikes(i+1), 0, v1, v2, v3];
                j = j + 1;
            end
        end
    end
    if j < spikeNum
        list(j:spikeNum) = [];
    end
end
