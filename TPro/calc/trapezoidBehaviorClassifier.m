%%
function annotation = trapezoidBehaviorClassifier(handles)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    fps = sharedInst.fpsNum;
    frame_num = size(sharedInst.vxy, 1);
    fly_num = size(sharedInst.vxy, 2);
    annotation = zeros(frame_num,fly_num);

    beMinLv = readTproConfig('beMinLv', 2);
    beDuration = round(readTproConfig('beDuration', 5) * fps / 60);
    beDurationSM = round(readTproConfig('beDurationSM', 5) * fps / 60);
    beJumpLv = readTproConfig('beJumpLv', 63);
    beJumpAcc = readTproConfig('beJumpAcc', 40);
    beRight = readTproConfig('beRight', 21);
    beRightGap = round(readTproConfig('beRightGap', 20) * fps / 60);
    beWalkLv = readTproConfig('beWalkLv', 8);
    beWalkGap = round(readTproConfig('beWalkGap', 5) * fps / 60);
    beSWalkLv = readTproConfig('beSWalkLv', 4);
    beSWalkGap = round(readTproConfig('beSWalkGap', 5) * fps / 60);
    beClimb = readTproConfig('beClimb', 0.92);
    beClimbLv = readTproConfig('beClimbLv', 11);
    beClimbGap = round(readTproConfig('beClimbGap', 8) * fps / 60);
    bePivot = readTproConfig('bePivot', 11);
    bePivotLv = readTproConfig('bePivotLv', 22);
    bePivotGap = round(readTproConfig('bePivotGap', 5) * fps / 60);
    beSharpSlope = readTproConfig('beSharpSlope', 19);
    beSmallSlope = readTproConfig('beSmallSlope', 99);

    lv = sharedInst.vxy;
    updown = sharedInst.updownVxy;
    lv(lv <= beMinLv) = 0;  % need to cut noise ...

    % ----- search jump: local max >= 63 [mm/s] -----
    jump = beJumpFilter(lv, updown, beJumpLv, beJumpAcc);
    jump = beDurationFilter(jump, beDuration);

    % ----- classifying -----
    annotation(jump==1) = 1; % jump label
end
