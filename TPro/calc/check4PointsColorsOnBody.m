%%
function [ outVector, isFound ] = check4PointsColorsOnBody(vec, c1, c2, c3, c4, TH_OVER_HEAD_COLOR, TH_WING_COLOR_MAX, TH_WING_COLOR_MIN)
    found = true;
    % if c1 is darker, c1 is head.
    if c1 > c2
        if c3 < c4
            % c2 should be head (darker), then c3 should be wing (darker). so flip now
            vec = -vec;
        else
            % oops c1-c2 and c3-c4 is conflicted
            if c3 > TH_OVER_HEAD_COLOR && TH_WING_COLOR_MIN < c4 && c4 < TH_WING_COLOR_MAX % c4 should be wing & c3 should be over head
                vec = -vec;
            else
                found = false;
            end
        end
    else
        % c1 should be head (darker), then c4 should be wing (darker).
        if c3 < c4
            % oops c1-c2 and c3-c4 is conflicted
            if c4 > TH_OVER_HEAD_COLOR && TH_WING_COLOR_MIN < c3 && c3 < TH_WING_COLOR_MAX % c3 should be wing & c4 should be over head
                vec = -vec;
            else
                found = false;
            end
        end
    end
    outVector = vec;
    isFound = found;
end
