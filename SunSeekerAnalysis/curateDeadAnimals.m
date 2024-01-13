function [LiveFly,DeathStart] = curateDeadAnimals(DistanceMatrix,MovementMatrix,HoursImmobile,TimeMatrix)
%curateDeadAnimals function to eliminate dead animals
%from data and replace values following proximal time of death with Nans
%Convert immobility time to index length
[~,I] = min(abs(TimeMatrix - (TimeMatrix(1) + hours(HoursImmobile))))

ImmobilityMat = zeros(size(MovementMatrix));
for i = 2:size(MovementMatrix,1)
    for ii = 1:size(MovementMatrix,2)
        if MovementMatrix(i,ii)==0
            ImmobilityMat(i,ii) = ImmobilityMat(i-1,ii) + 1;
        end
    end
end

DeathStart = nan(1,size(ImmobilityMat,2));
for i = 1:size(ImmobilityMat,2)
    if isempty(find(ImmobilityMat(:,i)>=I))==0
        DeathStart(1,i) = min(find(ImmobilityMat(:,i)>=I)) - I;
    end
end

% for i = 1:size(MovementMatrix,2)
% figure
% plot(DistanceMatrix(:,i))
% hold on
% if isnan(DeathStart(1,i)) == 0
% xline(DeathStart(1,i),'r','LineWidth',2)
% end
% end
LiveFly = zeros(1,size(DeathStart,2));
LiveFly(isnan(DeathStart)) = 1;
LiveFly = logical(LiveFly);
end
