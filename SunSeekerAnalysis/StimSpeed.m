%% Generate reaction plots 
%% read in data
addpath('/Users/geoffmeyerhof/Library/Mobile Documents/com~apple~CloudDocs/SunSeeker/SunSeekerAnalysis')
addpath('/Users/geoffmeyerhof/Documents/MATLAB/my_funcs')
ttFname = 'TimeTable.txt'
xyFname = 'PosXY.txt'
stFname = 'ShakeTable.txt'

load('Params.mat');
TimeTable = readtable(ttFname);
PosXY = readmatrix(xyFname);
ShakeTable = readtable(stFname);
ShakeTable.currTime = TimeTable.currTime;
saveDir = strcat(Params.saveDir,'_analysis');
firstDir = pwd
cd(saveDir)
load('AnalysisParams.mat')
load('FilteredData.mat')
cd(firstDir)
%% 
ShakeIndex = getStartShake(ShakeTable);
TimeB4 = 5 %time before onset of stim in minutes 
TimeAfter = 15 %time after last stim 

%%change start index to reflect before and after times of interest 
Vnaughts = find(ShakeIndex.VoltStart == 0)
%change B4
for i = 1:length(Vnaughts)
    StartIndex = ShakeIndex(Vnaughts(i)+1,:).StartIndex - 1;
    currTime = TimeTable(StartIndex,:).currTime;
    WantedTime = currTime - minutes(TimeB4);
    [~,newIdx] = min(abs(TimeTable.currTime - WantedTime));
    ShakeIndex(Vnaughts(i),:).StartIndex = newIdx;
end
%change After 
Vnaughts = find(ShakeIndex.VoltStart == 5)    
for i = 1:length(Vnaughts)
    EndIndex = ShakeIndex(Vnaughts(i),:).EndIndex + 1;
    currTime = TimeTable(EndIndex,:).currTime;
    WantedTime = currTime + minutes(TimeAfter);
    [~,newIdx] = min(abs(TimeTable.currTime - WantedTime));
    ShakeIndex(Vnaughts(i),:).EndIndex = newIdx;
end

% annotate with times 
ZT = [] 
for i = 1:height(ShakeIndex)
    ZT(i) = hours(TimeTable.currTime(ShakeIndex(i,:).StartIndex) - AnalysisParams.StartTime);
end
ShakeIndex.ZT = ZT'

[Mvmnt,Dist] = FlyMove(PosXY,Params.NumFlies,AnalysisParams.MoveThresh);
Dist = Dist/AnalysisParams.pix2m;

%Filter dead animals 
Mvmnt = Mvmnt(:,FData.LivingFlies);
Dist = Dist(:,FData.LivingFlies);

%% Generate binned speeds 
BinTime = 1 %in seconds 
timeCheck = [];
for i = 1:max(ShakeIndex.ShakeEvent)
    miniTable = ShakeIndex(ShakeIndex.ShakeEvent == i,:);
    StartIndex = miniTable(1,:).StartIndex;
    EndIndex = miniTable(end,:).EndIndex;
    timeStep = TimeTable(EndIndex,:).currTime - TimeTable(StartIndex,:).currTime;
    timeCheck(i,1) = seconds(timeStep);
end
%Get number of steps 
timeCheck = round(mean(timeCheck/BinTime));

LengthOfStimTrain = 65; %length of stim train in seconds 
%NumSteps = (60/BinTime)*TimeB4 + LengthOfStimTrain + 60*TimeAfter;
NumSteps = timeCheck;

%Get binned distance data stored in some kind of container..
StimSpeed_table = table()
%BinDist = {};
for i = 1:max(ShakeIndex.ShakeEvent)
     miniTable = ShakeIndex(ShakeIndex.ShakeEvent == i,:);
     StartIndex = miniTable(1,:).StartIndex;
     EndIndex = miniTable(end,:).EndIndex;
     Range = ((EndIndex - StartIndex)/NumSteps);
     Idx = round((StartIndex:Range:EndIndex))';
     distArray = [];
     for k = 2:length(Idx)
         Range = Idx(k-1):Idx(k);
         distArray(k-1,:) = mean(Dist(Range,:));
     end
     %BinDist{i,1} = distArray;
     %build output table 
     miniTable(:,2:3) = [];
     miniTable = miniTable(2,:);
     miniTable.BinDist = {distArray};
     StimSpeed_table = [StimSpeed_table;miniTable]; 
end
%% save stim speed table data 
sName = strcat(saveDir,'/','StimSpeedTable');
save(sName,'StimSpeed_table')
%% group daytime and nighttime stim speeds 
DayStim = []
for i = 1:6
    DayStim = [DayStim,StimSpeed_table(i,:).BinDist{:}];
end
NightStim = []
for i = 8:12
    NightStim = [NightStim,StimSpeed_table(i,:).BinDist{:}];
end
ZT = 1:NumSteps
SEMplot(ZT',DayStim,'#FFBF00')
hold on
SEMplot(ZT',NightStim)



















