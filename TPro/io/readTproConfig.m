%%
function result = readTproConfig(itemName, defaultValue)
    tproConfig = 'etc/tproconfig.csv';
    result = defaultValue;
    if exist(tproConfig, 'file')
        tproConfTable = readtable(tproConfig,'ReadRowNames',true);
        values = tproConfTable{itemName,1};
        if size(values,1) > 0
            result = values{1};
            if ~isempty(str2num(result))
                result = str2num(result);
            end
        end
    end
end