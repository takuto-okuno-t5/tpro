%%
function pc_data = calcPolarChartAllFly(X, Y, dir, ecc, br, ir, eccTh)
    flameMax = size(X, 1);
    flyNum = size(X, 2);

    hhPx = zeros(200,200);
    haPx = zeros(200,200);
    hhHist = zeros(1,36);
    haHist = zeros(1,36);
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
        fecc = ecc(i,:);

        [hhPx1, haPx1, hhHist1, haHist1, hx(i,:), hy(i,:), ax(i,:), ay(i,:)] = calcPolarChartFrame(fx,fy,fdir,fecc,br,ir,eccTh);
        hhPx = hhPx + hhPx1;
        haPx = haPx + haPx1;
        hhHist = hhHist + hhHist1;
        haHist = haHist + haHist1;

        if mod(i,200)==0
            rate = i/flameMax * 100;
            disp(['calcPolarChart : ' num2str(i) '(' num2str(rate) '%)']);
        end
    end
    % return value
    pc_data = cell(8,1);
    pc_data{1} = hhPx;
    pc_data{2} = haPx;
    pc_data{3} = hhHist;
    pc_data{4} = haHist;
    pc_data{5} = hx;
    pc_data{6} = hy;
    pc_data{7} = ax;
    pc_data{8} = ay;

    time = toc;
    disp(['calcPolarChartAllFly ... done : ' num2str(time) 's']);
end
