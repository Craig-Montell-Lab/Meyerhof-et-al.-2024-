%% SunSeeker Trax
hblob = vision.BlobAnalysis(...
    'CentroidOutputPort', true,...
    'AreaOutputPort', true, ...
    'BoundingBoxOutputPort', false, ...
    'MinimumBlobAreaSource', 'Property',...
    'MinimumBlobArea', Params.minArea, ...
    'MaximumBlobArea', Params.maxArea, ...
    'MaximumCount',10000);%blob detector

%% create first background model
bModel = [];
for i = 1:Params.bModelNum
    bModel(:,:,i) = imcrop(im2gray(step(Params.videoSource)),Params.ArenaROI);
end
%% begin tracking
vidPlayer = vision.VideoPlayer;
fNum = 1; %frame counter
bModelNum = 1; %bModel counter
currTime = datetime;

while currTime < Params.EndTime
    %Get current time 
    currTime = datetime;
    
    %find movement
    frame = imcrop(im2gray(step(Params.videoSource)),Params.ArenaROI);
    dframe = extractForeground(frame,bModel,Params.Threshold);
    
    %get blobs
    [Area,Centroids] = hblob(dframe);
    
    %Assign blobs
    [FlyTracks,immobileId] = assignBlobs(FlyTracks,Area,Centroids);
    
    %Update immobile flies
    [FlyTracks] = updateImmobile(FlyTracks,immobileId,currTime);
    
    %Check for light pulse 
    [LightPulse] = checkLightPulse(FlyTracks,LightPulse,Params,ArduinoPort);
    %output live-video feed
    playvid
    
    %update background model
    if bModelNum <= Params.bModelNum
        bModel(:,:,bModelNum) = frame;
        bModelNum = bModelNum + 1;
    else
        bModelNum = 1;
    end
    
    %save data
    quickSave
    
    fNum = fNum+ 1; %frame counter
    
    pause(0.35)

end

