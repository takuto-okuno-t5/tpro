%%
function result = readTproConfig(itemName, defaultValue)
    tproConfig = getTproEtcFile('tproconfig.csv');
    result = defaultValue;
    if exist(tproConfig, 'file')
        tproConfTable = readtable(tproConfig,'ReadRowNames',true);
        try
            values = tproConfTable{itemName,1};
            result = values{1};
            if ~isempty(str2num(result))
                result = str2num(result);
            end
        catch
        end
    end
end