%Get start of each shaking event
% outputs table with 1,3,and 5 volt indices
function ShakeIndex = getStartShake(MasterTable)
%reformat table depending on whether its for vibration stim or light pulse stim
Exist_Column = strcmp('LightsOn',MasterTable.Properties.VariableNames);
if sum(Exist_Column)>0
   MasterTable.Shaking = MasterTable.LightsOn; 
end

UniqueStims = unique(MasterTable.CurrentVoltage);
UniqueStims(UniqueStims==0) = [];

ShakeEvents = sum(diff(find(MasterTable.Shaking==1))>100) + 1;
ShakeIndex = nan(ShakeEvents,length(UniqueStims)+3);
ShakeIndex(:,end) = 1:ShakeEvents;

VoltCount = 2;
for k = 1:length(UniqueStims)
    VOI = UniqueStims(k);
    FirstShake = find(MasterTable.CurrentVoltage==VOI);
    ShakeIndex(1,VoltCount) = FirstShake(1);
    VoltCount = VoltCount + 1;
end
%get before first stimulus 
for i = 1:size(ShakeIndex,1)
    jumpIndex = ShakeIndex(i,3) - ShakeIndex(i,2);
    ShakeIndex(i,1) = ShakeIndex(i,2) - jumpIndex;
end
%get after last stimulus 
for i = 1:size(ShakeIndex,1)
    jumpIndex = ShakeIndex(i,end-2) - ShakeIndex(i,end-3);
    ShakeIndex(i,end-1) = ShakeIndex(i,end-2) + jumpIndex;
end


VoltCount = 2;
for k = 1:length(UniqueStims)
    VOI = UniqueStims(k);
    ShakeStarts = find(MasterTable.CurrentVoltage==VOI);
    diff_shakes = [1;diff(ShakeStarts)];
    counter = 2;
    for i = 2:length(diff_shakes)
        testIdx = diff_shakes(i);
        if testIdx > 100
            ShakeIndex(counter,VoltCount) = ShakeStarts(i);
            counter = counter + 1;
        end
    end
    VoltCount = VoltCount + 1;
end
%get before first stimulus 
for i = 1:size(ShakeIndex,1)
    jumpIndex = ShakeIndex(i,3) - ShakeIndex(i,2);
    ShakeIndex(i,1) = ShakeIndex(i,2) - jumpIndex;
end

%get after last stimulus
for i = 1:size(ShakeIndex,1)
    jumpIndex = ShakeIndex(i,end-2) - ShakeIndex(i,end-3);
    ShakeIndex(i,end-1) = ShakeIndex(i,end-2) + jumpIndex;
end

%Create output table 
sTable = ShakeIndex;
ShakeIndex = table();
newTable = table();
VoltCount = 1;
for i = 0:length([0;UniqueStims])-1
    newTable.VoltStart = repmat(i,size(sTable(:,VoltCount),1),1);
    newTable.StartIndex = sTable(:,VoltCount);
    newTable.EndIndex = sTable(:,VoltCount+1)-1;
    newTable.ShakeEvent = (1:ShakeEvents)';
    ShakeIndex = [ShakeIndex;newTable];
    
    VoltCount = VoltCount + 1;
end
ShakeIndex = sortrows(ShakeIndex,'StartIndex','ascend');

    


