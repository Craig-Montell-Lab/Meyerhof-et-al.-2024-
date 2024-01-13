%% Create tracks object :)
function [FlyTracks] = creatTrackingObject(Params)
NumFlies = Params.NumFlies * Params.numGenotypes;
% create an empty array of tracks
FlyTracks = struct(...
    'id', {}, ...
    'ROI',{},...
    'data', {}, ...
    'Sleeping', {}, ...
    'StartImmobile',{},...
    'TimeImmobile',{});

ids = 1:NumFlies;
genotypes = repelem(Params.Genotype,Params.NumFlies,1,1);
%ids
for i = 1:length(ids)
    FlyTracks(i,1).id = ids(1,i);
end
%genotypes
for i = 1:length(ids)
    FlyTracks(i,1).genotype = genotypes(i,1);
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

%Time imobile
for i = 1:length(ids)
    FlyTracks(i,1).StartImmobile = NaT;
end

%Time imobile
for i = 1:length(ids)
    FlyTracks(i,1).TimeImmobile = minutes(0);
end

end


