%%
function data = processDataByCommand(ops, data, fpsNum)
    for j=1:length(ops)
        % init
        frameNum = size(data,1);
        flyNum = size(data,2);
        op = ops{j};
        prestr3 = extractBefore(op,4);
        if length(op) > 5
            prestr5 = extractBefore(op,6);
        else
            prestr5 = [];
        end

        % check operation string
        if strcmp(prestr3, 'col') > 0
            % check column operation
            af = extractAfter(op,3);
            if strfind(af,'sum') > 0
                colop = extractBefore(af,4);
            elseif strfind(af,'mean') > 0
                colop = extractBefore(af,5);
            elseif strfind(af,'min') > 0
                colop = extractBefore(af,4);
            elseif strfind(af,'max') > 0
                colop = extractBefore(af,4);
            elseif strfind(af,'count') > 0
                colop = extractBefore(af,6);
            elseif strfind(af,'median') > 0
                colop = extractBefore(af,7);
            else
                continue;
            end
            if strfind(af,'/') > 0
                cycleStr = extractAfter(af,'/');
                colopval = extractBefore(af,'/');
            else
                cycleStr = [];
                colopval = af;
            end

            % check cycle
            if strfind(cycleStr,'sec') > 0
                cycle = floor(fpsNum * str2num(extractBefore(cycleStr,'sec')));
            elseif strfind(cycleStr,'frame') > 0
                cycle = str2num(extractBefore(cycleStr,'frame'));
            else
                cycle = frameNum;
            end
            rowNum = ceil(frameNum/cycle);
            procData = nan(rowNum,flyNum);

            if strcmp(colop, 'count') > 0
                % check column count operation
                if strfind(colopval,'==') > 0
                    val = str2num(extractAfter(colopval,'=='));
                    opn = 1;
                elseif strfind(colopval,'>') > 0
                    val = str2num(extractAfter(colopval,'>'));
                    opn = 2;
                elseif strfind(colopval,'<') > 0
                    val = str2num(extractAfter(colopval,'<'));                
                    opn = 3;
                else
                    val = 0;
                    opn = 2;
                end
                for i=1:rowNum
                    bg = cycle*(i-1) + 1;
                    en = cycle*i;
                    if en > frameNum
                        en = frameNum;
                    end
                    for fn=1:flyNum
                        switch opn
                        case 1
                            procData(i,fn) = length(find(data(bg:en,fn)==val));
                        case 2
                            procData(i,fn) = length(find(data(bg:en,fn)>val));
                        case 3
                            procData(i,fn) = length(find(data(bg:en,fn)<val));
                        end
                    end
                end
            else
                for i=1:rowNum
                    bg = cycle*(i-1) + 1;
                    en = cycle*i;
                    if en > frameNum
                        en = frameNum;
                    end
                    switch colop
                    case 'sum'
                        procData(i,:) = nansum(data(bg:en,:));
                    case 'mean'
                        procData(i,:) = nanmean(data(bg:en,:));
                    case 'median'
                        procData(i,:) = nanmedian(data(bg:en,:));
                    case 'min'
                        procData(i,:) = nanmin(data(bg:en,:));
                    case 'max'
                        procData(i,:) = nanmax(data(bg:en,:));
                    case 'nancount'
                        for fn=1:flyNum
                            procData(i,fn) = length(find(isnan(data(bg:en,fn))));
                        end
                    otherwise
                        procData = [];
                    end
                end
            end
        elseif strcmp(prestr5, 'count') > 0
            % check row count operation
            procData = nan(frameNum,1);
            if strfind(op,'==') > 0
                val = str2num(extractAfter(op,'=='));
                opn = 1;
            elseif strfind(op,'>') > 0
                val = str2num(extractAfter(op,'>'));
                opn = 2;
            elseif strfind(op,'<') > 0
                val = str2num(extractAfter(op,'<'));                
                opn = 3;
            else
                val = 0;
                opn = 2;
            end

            for i=1:frameNum
                switch opn
                case 1
                    procData(i) = length(find(data(i,:)==val));
                case 2
                    procData(i) = length(find(data(i,:)>val));
                case 3
                    procData(i) = length(find(data(i,:)<val));
                end
            end
        else
            % check row operation
            switch op
            case 'sum'
                procData = nansum(data,2);
            case 'mean'
                procData = nanmean(data,2);
            case 'median'
                procData = nanmedian(data,2);
            case 'min'
                procData = nanmin(data,2);
            case 'max'
                procData = nanmax(data,2);
            case 'nancount'
                procData = nan(frameNum,1);
                for i=1:frameNum
                    procData(i) = length(find(isnan(data(i,:))));
                end
            case 'transpose'
                procData = data';
            otherwise
                procData = [];
            end
        end
        if ~isempty(procData)
            data = procData;
        end
    end
end
