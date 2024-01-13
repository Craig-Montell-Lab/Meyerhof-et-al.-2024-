%Sun Seeker analysis
%% read in data
addpath('/Users/geoffmeyerhof/Library/Mobile Documents/com~apple~CloudDocs/SunSeeker/SunSeekerAnalysis')
stFname = 'ShakeTable.txt'
ttFname = 'TimeTable.txt'
xyFname = 'PosXY.txt'

load('Params.mat');
TimeTable = readtable(ttFname);
ShakeTable = readtable(stFname);
ShakeTable.currTime = TimeTable.currTime;
PosXY = readmatrix(xyFname);

%% Filter data 
% Enter experimental parameters 
predStart = Params.StartTime;
predLength = days(Params.EndTime - Params.StartTime);
prompt = {'start date(YYYY,M,D,H,M,S):'...
    ,'Enter length of recording (d):',...
    'Enter activity bin length (min)',...
    'Lights off time (ZT)'}; %Death thresh for diapause is .1%
dlgtitle = 'Parameters';
dims = [1 35];

definput = {datestr(predStart),num2str(predLength),'1','12'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

AnalysisParams.StartTime = datetime(datestr(answer{1}));
AnalysisParams.Length = str2num(answer{2});
AnalysisParams.EndTime = AnalysisParams.StartTime + AnalysisParams.Length;
AnalysisParams.LightsOffHour = str2num(answer{4});
AnalysisParams.ActivityBinLength = str2num(answer{3});

% Apply experimental parameters to data 
[~, IndexA] = min(abs(AnalysisParams.StartTime-TimeTable.currTime));
[~, IndexB] = min(abs(AnalysisParams.EndTime-TimeTable.currTime));

AnalysisParams.StartIndex = IndexA;
AnalysisParams.EndIndex = IndexB;
  
% Filtered Data 
FData.PosXY = PosXY(AnalysisParams.StartIndex:AnalysisParams.EndIndex,:);
FData.ShakeTable = ShakeTable(AnalysisParams.StartIndex:AnalysisParams.EndIndex,:);
FData.TimeTable = TimeTable(AnalysisParams.StartIndex:AnalysisParams.EndIndex,:);

% claculate distance and movement 
AnalysisParams.MoveThresh = 5; %minimum change in location of pixel centroid for movement to be registered
AnalysisParams.DeathThreshold = 10 %number of consecutive hours of immobility required for a fly to be counted as dead
AnalysisParams.pix2m = mean(vertcat(Params.ROI(:,3)))/0.045 %assumes that width of chamber is 45mm

%create analysis directory
saveDir = strcat(Params.saveDir,'_analysis');
mkdir(saveDir);
sName = strcat(saveDir,'/','AnalysisParams');
save(sName,'AnalysisParams');

[Mvmnt,Dist] = FlyMove(FData.PosXY,Params.NumFlies,AnalysisParams.MoveThresh);

FData.Mvmnt = Mvmnt;
FData.Dist = Dist/AnalysisParams.pix2m;
[LiveFly,DeathStart] = curateDeadAnimals(FData.Dist,FData.Mvmnt,AnalysisParams.DeathThreshold,FData.TimeTable.currTime);
FData.LivingFlies = LiveFly;

% bin distance, sleep, and movement with living flies 
[binDist,binMove,~] = binnedMove(FData.Mvmnt(:,FData.LivingFlies),FData.Dist(:,FData.LivingFlies),FData.TimeTable.currTime,AnalysisParams.ActivityBinLength);

FData.binDist = binDist;
FData.binMove = binMove;

[Sleep,SleepBin] = sleep_tracker(Mvmnt(:,FData.LivingFlies),FData.TimeTable.currTime,30);
FData.SleepLogical = Sleep;
FData.SleepBin = SleepBin;

sName = strcat(saveDir,'/','FilteredData');
save(sName,'FData')

clearvars -except AnalysisParams Params TimeTable ShakeTable PosXY FData saveDir

%% Calculate wakeup parameters 

% get shake start indices (this should be improved)
ShakeIndex = getStartShake(ShakeTable);
%get results table 
%resultsTable
resultsTable2
clearvars -except AnalysisParams Params TimeTable ShakeTable PosXY FData ArousalTable saveDir

% generate plots 
% getPlotted 








