%% check mat file content type
function type = checkMatFileType(path, fileName)
    type = '';
    try
        ctrax = load([path fileName]);
    catch e
        disp(['failed to open : ' path fileName]);
        errordlg('please select a mat file.', 'Error');
        return;
    end

    if isfield(ctrax, 'trx')
        type = 'jntrx';
    elseif isfield(ctrax, 'ntargets') && isfield(ctrax, 'identity')  && isfield(ctrax, 'x_pos')  && isfield(ctrax, 'y_pos')
        type = 'ctrax';
    end
end
