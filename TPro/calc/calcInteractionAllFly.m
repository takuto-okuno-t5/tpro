%%
function interaction_data = calcInteractionAllFly(X, Y, dir, br, ir, angleTh)
    flameMax = size(X, 1);
    flyNum = size(X, 2);

    hhInt = single(nan(flameMax, flyNum));
    haInt = single(nan(flameMax, flyNum));
    hbInt = single(nan(flameMax, flyNum));
    hx = single(nan(flameMax, flyNum));
    hy = single(nan(flameMax, flyNum));
    ax = single(nan(flameMax, flyNum));
    ay = single(nan(flameMax, flyNum));
    tic;
    for i = 1:flameMax
        % get detected points and roi points
        fx = X(i,:);
        fy = Y(i,:);
        fx(fx==0) = NaN;
        fy(fy==0) = NaN;
        fdir = dir(i,:);

        [hhInt(i,:), haInt(i,:), hbInt(i,:), hx(i,:), hy(i,:), ax(i,:), ay(i,:)] = calcInteractionFrame(fx,fy,fdir,br,ir,angleTh);
    end
    % head > ass > body
    hbInt(hhInt>0) = NaN;
    hbInt(haInt>0) = NaN;
    haInt(hhInt>0) = NaN;
    % count result
    hhInt2 = hhInt; haInt2 = haInt; hbInt2 = hbInt;
    hhInt2(hhInt>0) = 1;
    haInt2(haInt>0) = 1;
    hbInt2(hbInt>0) = 1;
    result = nansum(hhInt2,2) + nansum(haInt2,2) + nansum(hbInt2,2);
    % return value
    interaction_data = cell(8,1);
    interaction_data{1} = result;
    interaction_data{2} = hhInt;
    interaction_data{3} = haInt;
    interaction_data{4} = hbInt;
    interaction_data{5} = hx;
    interaction_data{6} = hy;
    interaction_data{7} = ax;
    interaction_data{8} = ay;

    time = toc;
    disp(['calcInteractionAllFly ... done : ' num2str(time) 's']);
end
