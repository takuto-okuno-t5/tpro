% find clossed trajectory
function result = findClossedTrajectory(X, Y, roiMask)
    flameMax = size(X, 1);
    flyNum = size(X, 2);
    
    result = zeros(flameMax,1);
    tic;
    for i = 2:flameMax
        % get detected points and roi points
        fx0 = X(i-1,:);
        fy0 = Y(i-1,:);
        fx1 = X(i,:);
        fy1 = Y(i,:);
        fx0(fx0==0) = NaN;
        fy0(fy0==0) = NaN;
        fx1(fx1==0) = NaN;
        fy1(fy1==0) = NaN;
        count = 0;
        for j = 1:(flyNum-1)
            for k = j+1:flyNum
                if isCloss(fx0(j), fy0(j), fx1(j), fy1(j), fx0(k), fy0(k), fx1(k), fy1(k))
                    count = count + 1;
                end
            end
        end
        result(i) = count;
    end
    time = toc;
    disp(['findClossedTrajectory ... done : ' num2str(time) 's']);
end

function cross = isCloss(ax, ay, bx, by, cx, cy, dx, dy)
    if ax==bx && ay==by && cx==dx && cy==dy
        cross = 0;
        return;
    end
	ta = (cx - dx) * (ay - cy) + (cy - dy) * (cx - ax);
	tb = (cx - dx) * (by - cy) + (cy - dy) * (cx - bx);
	tc = (ax - bx) * (cy - ay) + (ay - by) * (ax - cx);
	td = (ax - bx) * (dy - ay) + (ay - by) * (ax - dx);
    cross = ((tc * td <= 0) && (ta * tb <= 0)); 
end
