%Calculate difference between test frame and background model and returns
function bw_im = extractForeground(frame,backgroundModel,Thresh)
    
    backgroundModel = mean(backgroundModel,3);
    dframe = imsubtract(uint8(backgroundModel),uint8(frame));
    dframe = dframe>=Thresh;
    bw_im = imopen(dframe, strel('disk',2));

end