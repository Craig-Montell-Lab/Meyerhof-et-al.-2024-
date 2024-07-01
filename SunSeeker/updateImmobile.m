%update immobile flies 
function [FlyTracks] = updateImmobile(FlyTracks,immobileId,currTime)

for i = 1:length(immobileId)
    FlyTime = FlyTracks(immobileId(i)).StartImmobile;
    
    if isnat(FlyTime)
        FlyTracks(immobileId(i)).StartImmobile = currTime;
    end
    FlyTracks(immobileId(i)).TimeImmobile = currTime - FlyTracks(immobileId(i)).StartImmobile;

    if FlyTracks(immobileId(i)).TimeImmobile >= minutes(5)
        FlyTracks(immobileId(i)).Sleeping = true;
    end

end
end

