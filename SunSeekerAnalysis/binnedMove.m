% Create binned movement data
% binlength measured in minutes
% returns times of interest (TOI), binned distance (binDist), and binned
% movement (binMove)
function [binDist,binMove,TOI] = binnedMove(MoveArray,DistArray,TimeArray,BinLength)

Time1 = TimeArray(1);%First time
TimeFinal = TimeArray(end);%Last time
Time_diff = TimeFinal-Time1;%Difference in time
Time_diff = seconds(Time_diff)/60;%Diff time in minutes
nBins = Time_diff/BinLength; %number of bins 
TrueFinal = Time1+days(1);
Time_diff2 = TrueFinal - Time1;
TrueBinNum = seconds(Time_diff2)/60;
TrueBinNum = TrueBinNum/BinLength;

%Create Bin times 

TOI(1,:) = Time1;
for i = 2:round(nBins+1);
    TOI(i,:) = TOI(i-1,:)+minutes(BinLength);
end

for i = 1:size(TOI,1)
    [minDistance, IndexA] = min(abs(TOI(i)-TimeArray));
    index(i,:) = IndexA;
end

binDist = nan(TrueBinNum,size(DistArray,2));
binMove = nan(TrueBinNum,size(DistArray,2));

for i = 2:size(index,1)
    binDist(i-1,:) = sum(DistArray(index(i-1):index(i),:));
    binMove(i-1,:) = mean(MoveArray(index(i-1):index(i),:),'omitnan');
end
end



