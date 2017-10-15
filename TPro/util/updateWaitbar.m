%%
function updateWaitbar(rate, handle)
    waitbar(rate, handle, [num2str(int64(100*rate)) ' %']);
end
