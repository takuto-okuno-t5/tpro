%%
function chase = trapezoidFindChase(handles, addResultToAxesCallback)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    fps = sharedInst.fpsNum;
    lv = sharedInst.vxy;
    updown = sharedInst.updownVxy;
    dir = sharedInst.dir;
    x = sharedInst.keep_data{2}(:,:);
    y = sharedInst.keep_data{1}(:,:);

    beMinLv = readTproConfig('beMinLv', 2);
    beDuration = round(readTproConfig('beDuration', 5/60) * fps);
    beJumpLv = readTproConfig('beJumpLv', 63);
    beWalkLv = readTproConfig('beWalkLv', 8);
    beWalkGap = round(readTproConfig('beWalkGap', 5/60) * fps);
    beSharpSlope = readTproConfig('beSharpSlope', 19);
    beChaseMinDist = readTproConfig('beChaseMinDist', 5) / sharedInst.mmPerPixel;
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
