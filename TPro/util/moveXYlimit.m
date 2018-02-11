%% 
function imglimit = moveXYlimit(img_w, imglimit, dir)
    w = imglimit(2) - imglimit(1) + 1;
    if dir > 0
        if imglimit(2) + w/10 > img_w
            move = img_w - imglimit(2);
        else
            move = w/10;
        end
        imglimit = imglimit + move;
    else
        if imglimit(1) - w/10 < 1
            move = imglimit(1) - 1;
        else
            move = w/10;
        end
        imglimit = imglimit - move;
    end
end
