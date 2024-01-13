%assign blobs to flies
function [FlyTracks,immobileId] = assignBlobs(FlyTracks,Area,Centroids)
if ~isempty(Centroids)
    immobileId = [];
    for i = 1:length(FlyTracks)
        QueryX = [FlyTracks(i).ROI(1,1),FlyTracks(i).ROI(1,1) + FlyTracks(i).ROI(1,3),FlyTracks(i).ROI(1,1) + FlyTracks(i).ROI(1,3),FlyTracks(i).ROI(1,1)];
        QueryY = [FlyTracks(i).ROI(1,2),FlyTracks(i).ROI(1,2),FlyTracks(i).ROI(1,2) + FlyTracks(i).ROI(1,4),FlyTracks(i).ROI(1,2) + FlyTracks(i).ROI(1,4)];
        [in,on] = inpolygon(Centroids(:,1),Centroids(:,2),QueryX,QueryY);
        
        matches = in + on;
        matchIdx = find(matches>0);
        
        if ~isempty(matchIdx)
            FlyTracks(i).data = Centroids(matchIdx(1,1),:);
            FlyTracks(i).StartImmobile = NaT;
            FlyTracks(i).TimeImmobile = minutes(0);
        else
            immobileId = [immobileId,FlyTracks(i).id];
        end
    end
    
else
    immobileId = 1:length(FlyTracks);
end



end







