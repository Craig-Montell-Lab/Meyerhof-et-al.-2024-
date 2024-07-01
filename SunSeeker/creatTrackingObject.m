%% Create tracks object :)
function [FlyTracks] = creatTrackingObject(NumFlies)
% create an empty array of tracks
FlyTracks = struct(...
    'id', {}, ...
    'ROI',{},...
    'data', {}, ...
    'Sleeping', {}, ...
    'StartImmobile',{},...
    'TimeImmobile',{});

ids = 1:NumFlies;
%ids
for i = 1:length(ids)
    FlyTracks(i,1).id = ids(1,i);
end

%ROI
for i = 1:length(ids)
    FlyTracks(i,1).ROI = nan(1,4);
end

%data
for i = 1:length(ids)
    FlyTracks(i,1).data = nan(1,2);
end

%Sleeping
for i = 1:length(ids)
     FlyTracks(i,1).Sleeping = 0;
end

%Time imoobile
for i = 1:length(ids)
    FlyTracks(i,1).StartImmobile = NaT;
end

%Time imoobile
for i = 1:length(ids)
    FlyTracks(i,1).TimeImmobile = minutes(0);
end
end


