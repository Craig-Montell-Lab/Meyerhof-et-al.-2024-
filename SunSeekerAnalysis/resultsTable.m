ShakeIndex = sortrows(ShakeIndex,'Index','ascend');
ShakeEvents = max(ShakeIndex.ShakeEvent)
VelocityBin = Params.PulseWait %time for binning velocity before start of stimulus (s)
ArousalTable = table();
ArousalTable.ShakeEvent = ShakeIndex.ShakeEvent;

% Table parameters %
% 'Volt',... %voltage applied to shaker
% 'ZT',... %time of stimulus 
% 'MovingAtStart',... %how many flies were moving at start of lowest stimulus (e.g. volt = 1)
% 'AwakeAtStart',...%which flies were awake at the start of stimulus
% 'MvmntAtEnd',...  %how many flies started moving during/after each stimulus 
% 'ImmobileTime',... %how long were flies immobile if they were immobiile at start
% 'AvgVelocB4',... %average velocity of each fly up to start of stimulus.
        %final value, 0, is velocity after the last stimulus 

% get volts and times 
Volt = []
ZT = [] 
 
for i = 1:height(ShakeIndex)
    Volt(i) = ShakeIndex(i,:).VoltStart;
    ZT(i) = hours(FData.TimeTable.currTime(ShakeIndex(i,:).Index) - AnalysisParams.StartTime);
end

ArousalTable.Volt = Volt';
ArousalTable.ZT = ZT';

% get number of flies moving at start of stimulus 
MovingAtStart = []
for i = 1:height(ShakeIndex)
    
    if ShakeIndex(i,:).Index == 1
        Range = ShakeIndex(i:i,:).Index:ShakeIndex(i:i,:).Index+4;
    else
        Range = ShakeIndex(i:i,:).Index-4:ShakeIndex(i:i,:).Index;
    end
    MovingAtStart(i) = sum(sum(FData.Mvmnt(Range,:))>0);
end
ArousalTable.MovintAtStart = MovingAtStart';

% get number of flies that moved after stimulus
MvmntAtEnd = [];

for i = 1:height(ShakeIndex)-1
    Range = ShakeIndex(i,:).Index:ShakeIndex(i+1,:).Index-1;
    MvmntAtEnd(i) = sum(sum(FData.Mvmnt(Range,:))>0);
end
jumpIndex = ShakeIndex.Index(end) - ShakeIndex.Index(end-1);
Range = ShakeIndex(end,:).Index:ShakeIndex(end,:).Index+jumpIndex
MvmntAtEnd(end+1) = sum(sum(FData.Mvmnt(Range,:))>0);
ArousalTable.MvmntAtEnd = MvmntAtEnd';

% get time that each fly was immobile for at start of stimulus

% get number of flies moving at start of stimulus 
                        %To do%

%get average velocity before stimulus 
[~,jumpIdx] = min(abs((seconds(VelocityBin)+FData.TimeTable.currTime(1)) -  FData.TimeTable.currTime))
[Mvmnt,Dist] = FlyMove(PosXY,Params.NumFlies,AnalysisParams.MoveThresh);
Dist = Dist/AnalysisParams.pix2m;
VelocIndexes = nan(height(ShakeIndex),2);
VelocIndexes(1,1:2) = [AnalysisParams.StartIndex-jumpIdx,AnalysisParams.StartIndex-1]

StartStim = find(ShakeIndex.VoltStart == 1);
StartStim(1) = [];
for i = 1:length(StartStim)
    idx = StartStim(i);
    VelocIndexes(idx,1:2) = [ShakeIndex.Index(idx)-jumpIdx,ShakeIndex.Index(idx)]; 
end

[StartStim,~] = find(isnan(VelocIndexes(:,1)));
for i = 1:length(StartStim)
    idx = StartStim(i);
    VelocIndexes(idx,1:2) = [ShakeIndex.Index(idx-1),ShakeIndex.Index(idx)]; 
end

AvgVelocB4 = nan(height(ShakeIndex),size(FData.Dist,2));
AvgVelocB4(1,1:size(FData.Dist,2)) = sum(Dist(VelocIndexes(1,1):VelocIndexes(1,2),:))

for i = 2:size(AvgVelocB4,1)
    AvgVelocB4(i,:) = sum(FData.Dist(VelocIndexes(i,1):VelocIndexes(i,2),:));
end

ArousalTable.AvgVelocToStim = AvgVelocB4;

% get id of flies that were immobile at the start of each stimulus (e.g. 0.5
% consecutive minutes of inactivity 
ImmobileTime = minutes(0.5);
AwakeAtStart = [];
[~,jumpIdx] = min(abs((FData.TimeTable.currTime(1) + ImmobileTime) - FData.TimeTable.currTime))
Range = (AnalysisParams.StartIndex - jumpIdx):AnalysisParams.StartIndex
AwakeAtStart(1,:) = sum(Mvmnt(Range,:))>0;

for i = 2:height(ShakeIndex)
    Range = (AnalysisParams.StartIndex + ShakeIndex(i,:).Index - jumpIdx):AnalysisParams.StartIndex + ShakeIndex(i,:).Index;
    Awake = sum(Mvmnt(Range,:))>0;
    if ShakeIndex(i,:).VoltStart ~= 1
        Awake = Awake + AwakeAtStart(i-1,:);
        Awake = Awake>0;
    end
    AwakeAtStart(i,:) = Awake;
end
ArousalTable.AwakeAtStart = AwakeAtStart;
%writetable(ArousalTable,'data.txt')

% calculate and plot arousal threshold 
AAS = []
stims = [1 3 5]
for k = 1:12
    TOI = find(ArousalTable.ShakeEvent == k)
    subTable = ArousalTable(TOI,:).AwakeAtStart;
    AsleepAfterStim = []
    for i = 1:4
        AsleepAfterStim(i,1) = sum(subTable(i,:) == 0)
    end
    MaxSleepers = max(AsleepAfterStim);
    MinSleepers = min(AsleepAfterStim);
    WakeAfterStim = []
    AsleepAfterStim = AsleepAfterStim(2:end,:)
    for ii = 1:3 
        WakeAfterStim(ii,1) = MaxSleepers - AsleepAfterStim(ii,1)
        WakeAfterStim(ii,2) = stims(ii)
        WakeAfterStim(ii,3) = k
        MaxSleepers = MaxSleepers - WakeAfterStim(ii,1)
    end
    if max(WakeAfterStim(:,1)) == 0 
        WakeAfterStim(:,1) = [0;0;1]
    else
        WakeAfterStim(:,1) = WakeAfterStim(:,1)/max(WakeAfterStim(:,1))
    end
    AAS = [AAS;WakeAfterStim]
end

ArousalThreshold = []
for i = 1:12 
    TOI = find(AAS(:,3) == i)
    TOI = AAS(TOI,1:2)
    x = TOI(:,2)
    w = TOI(:,1)
    wMean = sum(w.*x,1)./sum(w,1);
    ArousalThreshold(i,1) = wMean;
end

ZT = 0:2:22
plot(ZT,ArousalThreshold)
hold on
scatter(ZT,ArousalThreshold)
ylim([0,6])
xlim([0,24])
ylabel('Arousal Threshold')
xlabel('ZT')

AT = table()
AT.ZT = ZT';
AT.ArousalThreshold = ArousalThreshold;

%writetable(AT,'MeanArousalThresh.txt');













    








