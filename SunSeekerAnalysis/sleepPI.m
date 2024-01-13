% Creates binned shaded sleep PI
% binlength measured in minutes
% returns times of interest (TOI), binned distance (binDist), and binned
function [ShadeSleepPI] = sleepPI(FData,BinLength)

Time1 = FData.TimeTable.currTime(1);%First time
TimeFinal = FData.TimeTable.currTime(end);%Last time
Time_diff = TimeFinal-Time1;%Difference in time
Time_diff = seconds(Time_diff)/60;%Diff time in minutes
nBins = Time_diff/BinLength; %number of bins 
TrueFinal = Time1+days(1);
Time_diff2 = TrueFinal - Time1;
TrueBinNum = seconds(Time_diff2)/60;
TrueBinNum = TrueBinNum/BinLength;

%Create Bin times 

TOI(1,:) = Time1;
for i = 2:round(nBins+1)
    TOI(i,:) = TOI(i-1,:)+minutes(BinLength);
end

for i = 1:size(TOI,1)
    [minDistance, IndexA] = min(abs(TOI(i)-FData.TimeTable.currTime));
    index(i,:) = IndexA;
end

ShadySleep = FData.ShadeLogical ==1 & FData.SleepLogical == 1;
SunnySleep = FData.ShadeLogical ==0 & FData.SleepLogical == 1;
ShadeDiff = ShadySleep - SunnySleep;

for i = 2:size(index,1)
    ShadeSleepPI(i-1,:) = sum(ShadeDiff(index(i-1):index(i),:),'omitnan')./sum(FData.SleepLogical(index(i-1):index(i),:),'omitnan');
end
end



