%%
function chase = trapezoidFindChase(handles, addResultToAxesCallback)
    if isfield(handles, 'figure1')
        sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
        fps = sharedInst.fpsNum;
        mmPerPixel = sharedInst.mmPerPixel;
        lv = sharedInst.vxy;
        updown = sharedInst.updownVxy;
        dir = sharedInst.dir;
        x = sharedInst.keep_data{2}(:,:);
        y = sharedInst.keep_data{1}(:,:);
    else
        fps = handles.fpsNum;
        mmPerPixel = handles.mmPerPixel;
        lv = handles.vxy;
        updown = handles.updownVxy;
        dir = handles.dir;
        x = handles.keep_data{2}(:,:);
        y = handles.keep_data{1}(:,:);
    end

    beMinLv = readTproConfig('beMinLv', 2);
    beDuration = round(readTproConfig('beDuration', 5/60) * fps);
    beJumpLv = readTproConfig('beJumpLv', 63);
    beWalkLv = readTproConfig('beWalkLv', 8);
    beWalkGap = round(readTproConfig('beWalkGap', 5/60) * fps);
    beSharpSlope = readTproConfig('beSharpSlope', 19);
    beChaseMinDist = readTproConfig('beChaseMinDist', 5) / mmPerPixel;
    beChaseMinDir = readTproConfig('beChaseMinDir', 30);
    beChaseGap = round(readTproConfig('beChaseGap', 5/60) * fps);
    beChaseDuration = round(readTproConfig('beChaseDuration', 8/60) * fps);

    lv(lv <= beMinLv) = 0;  % need to cut noise ...

    % ----- search chase -----
    chase = beChaseFilter(x, y, lv, dir, updown, beJumpLv, beWalkLv, beSharpSlope, beChaseGap, beDuration, beChaseMinDist, beChaseMinDir);
    chase = beGapFilter(chase, beChaseGap);
    chase = beDurationFilter(chase, beChaseDuration); % duration filter: >= 5 frames

    % add clustering result to axes
    if ~isempty(addResultToAxesCallback)
        addResultToAxesCallback(handles, chase, 'chase_result');
    end
end
