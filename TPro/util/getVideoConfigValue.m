%%
function result = getVideoConfigValue(records, index, defaultValue)
    if length(records) < index
        result = defaultValue;
    else
        result = records{index};
    end
end