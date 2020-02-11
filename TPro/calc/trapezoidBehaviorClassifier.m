%%
function annotation = trapezoidBehaviorClassifier(handles)
    if isfield(handles, 'figure1')
        sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
        fps = sharedInst.fpsNum;
        mmPerPixel = sharedInst.mmPerPixel;
        lv = sharedInst.vxy;
        updown = sharedInst.updownVxy;
        av = sharedInst.av;
        ecc = sharedInst.ecc;
        side = sharedInst.sidewaysVelocity;
        rWingAngle = sharedInst.rWingAngle;
        lWingAngle = sharedInst.lWingAngle;
        rwav = sharedInst.rWingAngleV;
        lwav = sharedInst.lWingAngleV;
        dir = sharedInst.dir;
        x = sharedInst.keep_data{2}(:,:);
        y = sharedInst.keep_data{1}(:,:);
    else
        fps = handles.fpsNum;
        mmPerPixel = handles.mmPerPixel;
        lv = handles.vxy;
        updown = handles.updownVxy;
        av = handles.av;
        ecc = handles.ecc;
        side = handles.sidewaysVelocity;
        rWingAngle = handles.rWingAngle;
        lWingAngle = handles.lWingAngle;
        rwav = handles.rWingAngleV;
        lwav = handles.lWingAngleV;
        dir = handles.dir;
        x = handles.keep_data{2}(:,:);
        y = handles.keep_data{1}(:,:);
    end

    accSide = calcDifferential2(side);
    bin = calcBinarize(accSide, 0);
    updownAcc = calcDifferential(bin);
    updownAcc(isnan(updownAcc)) = 0;

    frame_num = size(lv, 1);
    fly_num = size(lv, 2);
    annotation = nan(frame_num,fly_num);
    annotation(~isnan(lv)) = 0;

    beMinLv = readTproConfig('beMinLv', 2);
    beDuration = round(readTproConfig('beDuration', 5/60) * fps);
    beDurationSM = round(readTproConfig('beDurationSM', 5/60) * fps);
    beDurationSleep = round(readTproConfig('beDurationSleep', 300) * fps);
    beJumpLv = readTproConfig('beJumpLv', 63);
    beJumpAcc = readTproConfig('beJumpAcc', 40);
    beRight = readTproConfig('beRight', 21);
    beRightGap = round(readTproConfig('beRightGap', 20/60) * fps);
    beWalkLv = readTproConfig('beWalkLv', 8);
    beWalkGap = round(readTproConfig('beWalkGap', 5/60) * fps);
    beSWalkLv = readTproConfig('beSWalkLv', 4);
    beSWalkGap = round(readTproConfig('beSWalkGap', 5/60) * fps);
    beSleepGap = round(readTproConfig('beSleepGap', 5/60) * fps);
    beClimb = readTproConfig('beClimb', 0.92);
    beClimbLv = readTproConfig('beClimbLv', 11);
    beClimbGap = round(readTproConfig('beClimbGap', 8/60) * fps);
    bePivot = readTproConfig('bePivot', 11);
    bePivotLv = readTproConfig('bePivotLv', 22);
    bePivotGap = round(readTproConfig('bePivotGap', 5/60) * fps);
    beSharpSlope = readTproConfig('beSharpSlope', 19);
    beSmallSlope = readTproConfig('beSmallSlope', 99);
    beWingAngle = readTproConfig('beWingAngle', 18);
    beWingAngleV = readTproConfig('beWingAngleV', 7.5);
    beGroomingGap = round(readTproConfig('beGroomingGap', 1.0) * fps);
    beDurationGm = round(readTproConfig('beDurationGm', 0.2) * fps);
    beCourtShipWAng = readTproConfig('beCourtShipWAng', 24);
    beCourtShipWAngV = readTproConfig('beCourtShipWAngV', 7.5);
    beCourtShipDist = readTproConfig('beCourtShipDist', 6) / mmPerPixel;
    beCourtShipDir = readTproConfig('beCourtShipDir', 45);
    beCourtShipLv = readTproConfig('beCourtShipLv', 32);
    beCourtShipDuration = round(readTproConfig('beCourtShipDuration', 0.2) * fps);
    beCourtShipGap = round(readTproConfig('beCourtShipGap', 1.0) * fps);

    lv(lv <= beMinLv) = 0;  % need to cut noise ...

    % ----- search jump: local max >= 63 [mm/s] -----
    jump = beJumpFilter(lv, updown, beJumpLv, beJumpAcc);
    jump = beDurationFilter(jump, beDuration);

    % ----- righting filter -----
    right = beRightingFilter(side, updownAcc, lv, beJumpLv, beRight, beMinLv);
    right = beGapFilter(right, beRightGap);
    right = beDurationFilter(right, beDuration); % duration filter: >= 5 frames

    % ----- wall climbing ----
    climb = beClimbFilter(ecc, lv, beClimb, beClimbLv);
    climb = beGapFilter(climb, beClimbGap);
    climb = beDurationFilter(climb, beDuration); % duration filter: >= 5 frames

    % ----- pivot turn ----
    pivot = bePivotFilter(av, lv, bePivot, bePivotLv);
    pivot = beGapFilter(pivot, bePivotGap);

    % ----- sharp move -----
    sharp = beSharpWalkFilter(lv, updown, beJumpLv, beWalkLv, beSharpSlope);
    sharp = beGapFilter(sharp, beSWalkGap);

    % ----- walking filter -----
    walk = beWalkFilter(lv, updown, beJumpLv, beWalkLv, beSharpSlope);
    walk = beGapFilter(walk, beWalkGap);
    walk = beDurationFilter(walk, beDuration); % duration filter: >= 5 frames

    % ----- small walk -----
    swalk = beWalkFilter(lv, updown, beWalkLv, beSWalkLv, beSmallSlope);
    swalk = beDurationFilter(swalk, beDurationSM); % duration filter: >= 5 frames

    % ----- small move -----
    smove = beWalkFilter(lv, updown, beSWalkLv, beMinLv, beSmallSlope);
    smove = beDurationFilter(smove, beDurationSM); % duration filter: >= 5 frames

    % ----- sleep -----
    sleep = beWalkFilter(lv, updown, beMinLv, 0, beSleepGap);
    sleep = beDurationFilter(sleep, beDurationSleep); % duration filter: >= 5 frames

    % ----- grooming -----
    groom = beGroomingFilter(rWingAngle, lWingAngle, rwav, lwav, lv, beWingAngle, beWingAngleV, beMinLv);
    groom = beGapFilter(groom, beGroomingGap); % long gap filter
    groom = beDurationFilter(groom, beDurationGm); % duration filter

    % ----- courtship -----
    court = beCourtShipFilter(x, y, lv, dir, rWingAngle, lWingAngle, rwav, lwav, beCourtShipWAng, beCourtShipWAngV, beCourtShipLv, beCourtShipDist, beCourtShipDir);
    court = beGapFilter(court, beCourtShipGap); % long gap filter
    court = beDurationFilter(court, beCourtShipDuration); % duration filter

    % ----- classifying -----
    annotation(smove==1) = 8; % BE_SMALL_MOVE
    annotation(swalk==1) = 7; % BE_SMALL_WALK
    annotation(walk==1)  = 2; % BE_WALK
    annotation(sharp==1) = 6; % BE_SHARP_MOVE
    annotation(pivot==1) = 5; % BE_PIVOT
    annotation(climb==1) = 4; % BE_CLIBM
    annotation(groom==1) = 9; % BE_GROOMING
    annotation(court==1) = 11; % BE_COURTSHIP
    annotation(right==1) = 3; % BE_RIGHT
    annotation(sleep==1) = 10; % BE_SLEEP
    annotation(jump==1)  = 1; % BE_JUMP
end
