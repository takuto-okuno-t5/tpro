%%
function annotation = trapezoidBehaviorClassifier(handles)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    fps = sharedInst.fpsNum;
    lv = sharedInst.vxy;
    updown = sharedInst.updownVxy;
    av = sharedInst.av;
    ecc = sharedInst.ecc;
    side = sharedInst.sidewaysVelocity;
    rWingAngle = sharedInst.rWingAngle;
    lWingAngle = sharedInst.lWingAngle;

    accSide = calcDifferential2(side);
    bin = calcBinarize(accSide, 0);
    updownAcc = calcDifferential(bin);
    updownAcc(isnan(updownAcc)) = 0;

    frame_num = size(lv, 1);
    fly_num = size(lv, 2);
    annotation = zeros(frame_num,fly_num);

    beMinLv = readTproConfig('beMinLv', 2);
    beDuration = round(readTproConfig('beDuration', 5/60) * fps);
    beDurationSM = round(readTproConfig('beDurationSM', 5/60) * fps);
    beJumpLv = readTproConfig('beJumpLv', 63);
    beJumpAcc = readTproConfig('beJumpAcc', 40);
    beRight = readTproConfig('beRight', 21);
    beRightGap = round(readTproConfig('beRightGap', 20/60) * fps);
    beWalkLv = readTproConfig('beWalkLv', 8);
    beWalkGap = round(readTproConfig('beWalkGap', 5/60) * fps);
    beSWalkLv = readTproConfig('beSWalkLv', 4);
    beSWalkGap = round(readTproConfig('beSWalkGap', 5/60) * fps);
    beClimb = readTproConfig('beClimb', 0.92);
    beClimbLv = readTproConfig('beClimbLv', 11);
    beClimbGap = round(readTproConfig('beClimbGap', 8/60) * fps);
    bePivot = readTproConfig('bePivot', 11);
    bePivotLv = readTproConfig('bePivotLv', 22);
    bePivotGap = round(readTproConfig('bePivotGap', 5/60) * fps);
    beSharpSlope = readTproConfig('beSharpSlope', 19);
    beSmallSlope = readTproConfig('beSmallSlope', 99);
    beGrooming = 30;
    beGroomingGap = round(1.5 * fps);
    beDurationGm = round(0.1 * fps);

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

    % ----- grooming -----
    groom = beGroomingFilter(rWingAngle, lWingAngle, lv, beGrooming, beSWalkLv);
    groom = beDurationFilter(groom, beDurationGm); % duration filter
    groom = beGapFilter(groom, beGroomingGap); % long gap filter

    % ----- classifying -----
    annotation(smove==1) = 8; % BE_SMALL_MOVE
    annotation(swalk==1) = 7; % BE_SMALL_WALK
    annotation(walk==1)  = 2; % BE_WALK
    annotation(sharp==1) = 6; % BE_SHARP_MOVE
    annotation(pivot==1) = 5; % BE_PIVOT
    annotation(climb==1) = 4; % BE_CLIBM
    annotation(groom==1) = 9; % BE_GROOMING
    annotation(right==1) = 3; % BE_RIGHT
    annotation(jump==1)  = 1; % BE_JUMP
end
