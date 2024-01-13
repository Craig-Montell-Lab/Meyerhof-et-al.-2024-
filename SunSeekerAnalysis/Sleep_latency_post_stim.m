%%Calculate sleep latency following arousal 
%1.) Add paths 

addpath('/Users/geoffmeyerhof/Library/Mobile Documents/com~apple~CloudDocs/SunSeeker/SunSeekerAnalysis')
addpath('/Users/geoffmeyerhof/Documents/MATLAB/my_funcs')

%2.) Read in relevant raw data 

load('Params.mat');
TimeTable = readtable('TimeTable.txt');
PosXY = readmatrix('PosXY.txt');
try
    ShakeTable = readtable('ShakeTable.txt');
catch
    ShakeTable=readtable('LightTable.txt');
end

ShakeTable.currTime = TimeTable.currTime;
FirstDir = pwd
if exist('sParams')
    Params=sParams
end
cd(Params.Genotype + "_analysis")
load("AnalysisParams.mat")
ArousalThresh = readtable('ArousalThresh_v2.txt')
load("FilteredData.mat")
%3.) Begin stim analysis 
ShakeIndex = getStartShake(ShakeTable);
[Mvmnt,Dist] = FlyMove(PosXY,Params.NumFlies,AnalysisParams.MoveThresh);
[Sleep,SleepBin] = sleep_tracker(Mvmnt(:,FData.LivingFlies),TimeTable.currTime,30);
    % get volts and times 
    Volt = []
    ZT = [] 
    ArousalTable = table()
    for i = 1:height(ShakeIndex)
        Volt(i) = ShakeIndex(i,:).VoltStart;
        ZT(i) = hours(TimeTable.currTime(ShakeIndex(i,:).StartIndex) - AnalysisParams.StartTime);
    end
    ArousalTable.Volt = Volt';
    ArousalTable.ZT = ZT';
%% get latency to next sleep bout if awoken by stimulus
numWakes = find(~isnan(ArousalThresh.wakeVoltage));
FlyIds = [FData.LivingFlies',(1:Params.NumFlies)'];
FlyIds(FlyIds(:,1)==0,:) = [];
SleepLatency = nan(size(ArousalThresh,1),1);
for i = 1:length(numWakes)
    FlyID = ArousalThresh(numWakes(i),:).FlyID;
    FlyID = find(FlyID == FlyIds(:,2));
    wakeVoltage = ArousalThresh(numWakes(i),:).wakeVoltage;
    if wakeVoltage>0&&wakeVoltage<6
        ZT = round(ArousalThresh(numWakes(i),:).ZT);
        wakeIndex = find(ZT == round(ArousalTable.ZT)&ArousalTable.Volt == wakeVoltage,1);
        wakeIndex = ShakeIndex(wakeIndex,:).StartIndex;
        
        SleepIndex = find(Sleep(:,FlyID)==1);
        firstBoutIdx =find(SleepIndex>wakeIndex,1,'first');
        firstBoutIdx = SleepIndex(firstBoutIdx);
        SleepBoutLatency = minutes(TimeTable.currTime(firstBoutIdx) - TimeTable.currTime(wakeIndex))
        SleepLatency(numWakes(i),1) = SleepBoutLatency;
      
    end
end
ArousalThresh.SleepLatency = SleepLatency

%Plot sleep latency vs. time (sanity check)
AT = [];
ZTs = unique(ArousalThresh.ZT);
aData = [];
for i = 1:length(ZTs)
    subTable = ArousalThresh(ArousalThresh.ZT == ZTs(i),:)
    aData(i,:) = subTable.SleepLatency;
end

figure('Position',[800,800,300,300])
SEMplot(ZTs,aData,'b','b')
xlim([0,24])
ylabel('Sleep latency (minutes)')
xlabel('ZT')


%save output 
SleepLatency = ArousalThresh;
sName = ('SleepLatency')
writetable(SleepLatency,sName)
cd(FirstDir)



