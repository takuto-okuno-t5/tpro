%%
function data = processDataByCommand(ops, data)
    frameNum = size(data,1);
    for j=1:length(ops)
        procData = [];
        op = ops{j};
        if strfind(op,'count==') > 0
            val = str2num(extractAfter(op,'=='));
            procData = nan(frameNum,1);
            for i=1:frameNum
                procData(i) = length(find(data(i,:)==val));
            end
        elseif strfind(op,'count>') > 0
            val = str2num(extractAfter(op,'>'));
            procData = nan(frameNum,1);
            for i=1:frameNum
                procData(i) = length(find(data(i,:)>val));
            end
        elseif strfind(op,'count<') > 0
            val = str2num(extractAfter(op,'<'));
            procData = nan(frameNum,1);
            for i=1:frameNum
                procData(i) = length(find(data(i,:)<val));
            end
        else
            switch op
            case 'mean'
                procData = nan(frameNum,1);
                for i=1:frameNum
                    procData(i) = nanmean(data(i,:));
                end
            case 'min'
                procData = nan(frameNum,1);
                for i=1:frameNum
                    procData(i) = nanmin(data(i,:));
                end
            case 'max'
                procData = nan(frameNum,1);
                for i=1:frameNum
                    procData(i) = nanmax(data(i,:));
                end
            case 'nancount'
                procData = nan(frameNum,1);
                for i=1:frameNum
                    procData(i) = length(find(isnan(data(i,:))));
                end
            end
        end
        if ~isempty(procData)
            data = procData;
        end
    end
end
