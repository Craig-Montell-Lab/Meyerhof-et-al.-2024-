%% Get ROI for arena
showFrame = im2gray(step(Params.videoSource));
showFrame = insertText(showFrame,[size(frame,1)/4,0],...
    ("draw rectangle around all arena(s)" ),'FontSize',40);
imshow(showFrame)
hold on
pos = getrect();
showFrame = insertShape(showFrame,'FilledRectangle',pos,'Color','m');
imshow(showFrame)
drawnow()
ArenaPos = pos;
%% dialog box to check correct zone
answer = questdlg('Is Zone Correct?', ...
    '', ...
    'Yes','No','Yes');
% Handle response
switch answer
    case 'Yes'
        close('all');
        Params.ArenaROI = round(ArenaPos);
    case 'No'
        close('all');
        run('getROIs.m')
        return
end
%% Get ROIs for chamber
roiCount = 1;
frame = im2gray(step(Params.videoSource));
frame = imcrop(frame,Params.ArenaROI);
ROIs = [];
for genoCount = 1:Params.numGenotypes*Params.NumFlies
    genotype = FlyTracks(genoCount).genotype{:};
    id = genoCount;
    if id>Params.NumFlies
        id = mod(FlyTracks(genoCount).id,Params.NumFlies);
    end
    
    showFrame = insertText(frame,[0,0],...
        "draw rectangle around each chamber for " + genotype + num2str(id),'FontSize',20);
    showFrame = insertShape(showFrame,'FilledRectangle',[ROIs],'Color','m');
    imshow(showFrame)
    drawnow()
    pos = getrect();
    ROIs(genoCount,1:4) = pos;
    
    roiCount = roiCount + 1;
    
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
        for i = 1:Params.numGenotypes*Params.NumFlies
            FlyTracks(i).ROI = round(ROIs(i,:));
            FlyTracks(i).data = [FlyTracks(i).ROI(1) + FlyTracks(i).ROI(3)/2,FlyTracks(i).ROI(2) + FlyTracks(i).ROI(4)/2]
        end
        Params.ReferenceImage = showFrame;
        Params.ROI = ROIs;
        Params.genoId = vertcat(FlyTracks.genotype)';
        % save parameters
        for i = 1:length(Params.saveDir)

            sParams = Params;
            sParams.Genotype = Params.Genotype{i};
            GOI = strfind(Params.genoId,sParams.Genotype);
            GOI = find(~cellfun('isempty',GOI));
            sParams.ROI = Params.ROI(GOI,:);
            SaveDir = strcat(Params.saveDir{i},'/','Params.mat');
            save(SaveDir,'sParams')
        end
        
    case 'No'
        close('all');
        run('getROIs.m')
        return
end

clearvars -except Params FlyTracks FlyShake ArduinoPort