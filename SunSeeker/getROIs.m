%% Get ROI for arena 
frame = step(Params.videoSource);
showFrame = insertText(frame,[size(frame,1)/4,0],...
    'draw rectangle around the arena','FontSize',40);
imshow(showFrame)
hold on
pos = getrect();
showFrame = insertShape(showFrame,'FilledRectangle',pos,'Color','m');
imshow(showFrame)
%% dialog box to check correct zone 
answer = questdlg('Is Zone Correct?', ...
    '', ...
    'Yes','No','Yes');
% Handle response
switch answer
    case 'Yes'
        close('all');
        Params.ArenaROI = round(pos);
    case 'No'
        close('all');
        run('getROIs.m')
        return
end
%% Get ROIs for chamber 
frame = step(Params.videoSource);
frame = imcrop(frame,Params.ArenaROI);
showFrame = insertText(frame,[0,0],...
    'draw rectangle around each chamber','FontSize',20);
ROIs = [];
imshow(showFrame)
hold on
for i = 1:Params.NumFlies
    pos = getrect();
    ROIs(i,1:4) = pos;
    showFrame = insertShape(showFrame,'FilledRectangle',[ROIs],'Color','m');
    imshow(showFrame)
end
close all

showFrame = insertShape(frame,'FilledRectangle',ROIs,'Color','m');
imshow(showFrame)

%% Dialog Box to check correct zones
answer = questdlg('Are Zones Correct?', ...
    '', ...
    'Yes','No','Yes');
% Handle response
switch answer
    case 'Yes'
        close('all');
        for i = 1:Params.NumFlies
            FlyTracks(i).ROI = round(ROIs(i,:));
            FlyTracks(i).data = [FlyTracks(i).ROI(1) + FlyTracks(i).ROI(3)/2,FlyTracks(i).ROI(2) + FlyTracks(i).ROI(4)/2]
        end
        
    case 'No'
        close('all');
        run('getROIs.m')
        return
end
%% save parameters 
SaveDir = strcat(Params.saveDir,'/','Params.mat');
save(SaveDir,'Params')

clearvars -except Params FlyTracks FlyShake