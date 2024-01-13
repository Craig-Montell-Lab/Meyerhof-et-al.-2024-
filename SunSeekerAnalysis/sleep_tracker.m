%Sleep annotation function 
%Time index indicates times of interest for sleep tracking (usually 30
%minute intervals
function [Sleep,SleepBin] = sleep_tracker(MoveArray,TimeArray,BinLength)

%Find length of 5-minute time step
Time1 = TimeArray(1);%First time
TP5(1:2,1) = [Time1, Time1+minutes(5)]

for i = 1:size(TP5,1)
    [minDistance, IndexA] = min(abs(TP5(i)-TimeArray));
    idx5(i,:) = IndexA;
end

time_step = diff(idx5(1:2,1));

%Annotate with sleep. Sleep = 1; Awake = 0;
Sleep = nan(size(MoveArray));
for ii = 1:size(MoveArray,2)
    Count = ii
    for i = 1:size(MoveArray,1)-time_step
        box = MoveArray(i:i+time_step,ii);
        if sum(isnan(box)) == size(box,1)
            Sleep(i,ii) = nan;
        elseif sum(box)==0
            Sleep(i,ii) = 1;
        else
            Sleep(i,ii) = 0;
        end
    end
end

%Create Bin times for binLength step (usually 30minutes)
Time1 = TimeArray(1);%First time
TimeFinal = TimeArray(end);%Last time
Time_diff = TimeFinal-Time1;%Difference in time
Time_diff = seconds(Time_diff)/60;%Diff time in minutes
nBins = Time_diff/BinLength; %number of bins 

%Create Bin times 
TimeIndex(1,:) = Time1;
for i = 2:round(nBins+1)
    TimeIndex(i,:) = TimeIndex(i-1,:)+minutes(BinLength);
end
%Find bin indexes 
for i = 1:size(TimeIndex,1)
    [~, IndexA] = min(abs(TimeIndex(i)-TimeArray));
    index(i,:) = IndexA;
end

index(end,:) = size(Sleep,1);

%Calculate average sleep in each bin
SleepBin = nan(48,size(MoveArray,2));
for i = 2:size(index,1)
    SleepBin(i-1,:) = mean(Sleep(index(i-1):index(i),:),'omitnan');
end
end





