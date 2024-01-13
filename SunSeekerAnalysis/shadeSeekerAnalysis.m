%% shade Seeker analysis
%% read in data
addpath('/Users/geoffmeyerhof/Library/Mobile Documents/com~apple~CloudDocs/SunSeeker/SunSeekerAnalysis')
addpath('/Users/geoffmeyerhof/Documents/MATLAB/my_funcs')
ttFname = 'TimeTable.txt'
xyFname = 'PosXY.txt'

load('Params.mat');
if exist('sParams')
    Params = sParams;
end
TimeTable = readtable(ttFname);
PosXY = readmatrix(xyFname);
%% Filter data 
% Enter experimental parameters 
predStart = Params.StartTime;
predLength = days(TimeTable(end,:).currTime - Params.StartTime);
% prompt = {'start date(YYYY,M,D,H,M,S):'...
%     ,'Enter length of recording (d):',...
%     'Enter activity bin length (min)',...
%     'Lights off time (ZT)'}; %Death thresh for diapause is .1%
% dlgtitle = 'Parameters';
% dims = [1 35];
% definput = {datestr(predStart),num2str(predLength),'10','12'};
% answer = inputdlg(prompt,dlgtitle,dims,definput);

AnalysisParams.StartTime = predStart% datetime(datestr(answer{1}));
AnalysisParams.Length = predLength% str2num(answer{2});
AnalysisParams.EndTime = AnalysisParams.StartTime + AnalysisParams.Length;
AnalysisParams.LightsOffHour = 12% str2num(answer{4});
AnalysisParams.ActivityBinLength = 10% str2num(answer{3});

% Apply experimental parameters to data 
[~, IndexA] = min(abs(AnalysisParams.StartTime-TimeTable.currTime));
[~, IndexB] = min(abs(AnalysisParams.EndTime-TimeTable.currTime));

AnalysisParams.StartIndex = IndexA;
AnalysisParams.EndIndex = IndexB;
  
% Filtered Data 
FData.PosXY = PosXY(AnalysisParams.StartIndex:AnalysisParams.EndIndex,:);
FData.TimeTable = TimeTable(AnalysisParams.StartIndex:AnalysisParams.EndIndex,:);

% claculate distance and movement 
AnalysisParams.MoveThresh = 5; %minimum change in location of pixel centroid for movement to be registered
AnalysisParams.DeathThreshold = 6 %number of consecutive hours of immobility required for a fly to be counted as dead
AnalysisParams.pix2m = mean(vertcat(Params.ROI(:,3)))/0.045 %assumes that width of chamber is 45mm

%create analysis directory
if exist('sParams')
   Params.saveDir = sParams.Genotype;
end
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


%% Calculate shade preference for living flies
MidPoints = Params.ROI(:,1) + Params.ROI(:,3)/2;
liveIdx = find(vertcat(FData.LivingFlies) == 1)

% get shade logical where 1 is in shade and 0 is sun
ShadeLogical = FData.PosXY(:,liveIdx) < MidPoints(liveIdx)';
[~,binShade,~] = binnedMove(ShadeLogical,ShadeLogical,FData.TimeTable.currTime,AnalysisParams.ActivityBinLength);
FData.ShadeLogical = ShadeLogical;
FData.binShade = binShade;
% calculate shady sleep PI (i.e., time spent asleep and in shade)
% calculate shady sleep PI (i.e., time spent asleep and in shade)
ShadySleep = FData.ShadeLogical ==1 & FData.SleepLogical == 1;
[~,ShadySleep,~] = binnedMove(ShadySleep,ShadySleep,FData.TimeTable.currTime,30);
FData.ShadySleep = ShadySleep;
SunnySleep = FData.ShadeLogical ==0 & FData.SleepLogical == 1;
[~,SunnySleep,~] = binnedMove(SunnySleep,SunnySleep,FData.TimeTable.currTime,30);
FData.SunnySleep = SunnySleep;
[ShadeSleepPI] = sleepPI(FData,30);
FData.ShadeSleepPI = ShadeSleepPI;

%% save filtered data 
sName = strcat(saveDir,'/','FilteredData');
save(sName,'FData')
%% create shade preference plot 
figure('Position',[0.13,0.111112650479146,0.775*500,0.123209383419159*10000])
subplot(5,1,1)
title(Params.Genotype);
binLength = AnalysisParams.ActivityBinLength
ZT = (0:AnalysisParams.Length*24/(AnalysisParams.Length*1440/binLength):(AnalysisParams.Length*24) - ((AnalysisParams.Length*24)/1440/binLength))'
hold on
LightsOffHour = AnalysisParams.LightsOffHour;
LightsOnHour = 24
fill([LightsOffHour LightsOnHour LightsOnHour LightsOffHour],[1 1 0 0],'black','FaceAlpha',0.3,'LineStyle','none') 
for i = 1:AnalysisParams.Length-1
LightsOffHour = LightsOffHour + 24;
LightsOnHour = LightsOnHour+24;
fill([LightsOffHour LightsOnHour LightsOnHour LightsOffHour],[1 1 0 0],'black','FaceAlpha',0.3,'LineStyle','none') 
end
SEMplot(ZT,FData.binShade,'r')
ylabel('Time spent in shaded region (min)')
xlabel('Hour')
xlim([0,ZT(end)])
set(gca,'TickDir','out');
set(gca,'linewidth',1.5)


subplot(5,1,2)
binLength = AnalysisParams.ActivityBinLength
ZT = (0:AnalysisParams.Length*24/(AnalysisParams.Length*1440/binLength):(AnalysisParams.Length*24) - ((AnalysisParams.Length*24)/1440/binLength))'
hold on
LightsOffHour = AnalysisParams.LightsOffHour;
LightsOnHour = 24
fill([LightsOffHour LightsOnHour LightsOnHour LightsOffHour],[1 1 0 0],'black','FaceAlpha',0.3,'LineStyle','none') 
for i = 1:AnalysisParams.Length-1
LightsOffHour = LightsOffHour + 24;
LightsOnHour = LightsOnHour+24;
fill([LightsOffHour LightsOnHour LightsOnHour LightsOffHour],[1 1 0 0],'black','FaceAlpha',0.3,'LineStyle','none') 
end
xlabel('ZT')
SEMplot(ZT,FData.binDist)
ylabel('Distance')
xlabel('Hour')
xlim([0,ZT(end)])
set(gca,'TickDir','out');
set(gca,'linewidth',1.5)
hold off 

subplot(5,1,3)
binLength = 30
ZT = (0:AnalysisParams.Length*24/(AnalysisParams.Length*1440/binLength):(AnalysisParams.Length*24) - ((AnalysisParams.Length*24)/1440/binLength))'
hold on
LightsOffHour = AnalysisParams.LightsOffHour;
LightsOnHour = 24
fill([LightsOffHour LightsOnHour LightsOnHour LightsOffHour],[1 1 0 0],'black','FaceAlpha',0.3,'LineStyle','none') 
for i = 1:AnalysisParams.Length-1
LightsOffHour = LightsOffHour + 24;
LightsOnHour = LightsOnHour+24;
fill([LightsOffHour LightsOnHour LightsOnHour LightsOffHour],[1 1 0 0],'black','FaceAlpha',0.3,'LineStyle','none') 
end
ylabel('Sleep/30min')
xlabel('ZT')
SEMplot(ZT,FData.SleepBin)
xlabel('Hour')
xlim([0,ZT(end)])
set(gca,'TickDir','out');
set(gca,'linewidth',1.5)
hold off 


% Shade sleep time 
subplot(5,1,4)
hold on
binLength = 30;
ZT = (0:AnalysisParams.Length*24/(AnalysisParams.Length*1440/binLength):(AnalysisParams.Length*24) - ((AnalysisParams.Length*24)/1440/binLength))'
LightsOffHour = AnalysisParams.LightsOffHour;
LightsOnHour = 24
fill([LightsOffHour LightsOnHour LightsOnHour LightsOffHour],[1 1 -1 -1],'black','FaceAlpha',0.3,'LineStyle','none') 
for i = 1:AnalysisParams.Length-1
LightsOffHour = LightsOffHour + 24;
LightsOnHour = LightsOnHour+24;
fill([LightsOffHour LightsOnHour LightsOnHour LightsOffHour],[1 1 -1 -1],'black','FaceAlpha',0.3,'LineStyle','none') 
end
fill([0 hours(AnalysisParams.EndTime - AnalysisParams.StartTime) hours(AnalysisParams.EndTime - AnalysisParams.StartTime) 0],[1 1 0 0],'black','FaceAlpha',0.2,'LineStyle','none') 
hold on
SEMplot(ZT,FData.ShadySleep,'b','b')
SEMplot(ZT,-FData.SunnySleep,'r','r')
ylabel('Sleep/30 min')
xlabel('Hour')
xlim([0,ZT(end)])
set(gca,'TickDir','out');
set(gca,'linewidth',1.5)


% Shade sleep PI 
subplot(5,1,5)
hold on
binLength = 30;
ZT = (0:AnalysisParams.Length*24/(AnalysisParams.Length*1440/binLength):(AnalysisParams.Length*24) - ((AnalysisParams.Length*24)/1440/binLength))'
LightsOffHour = AnalysisParams.LightsOffHour;
LightsOnHour = 24
fill([LightsOffHour LightsOnHour LightsOnHour LightsOffHour],[1 1 -1 -1],'black','FaceAlpha',0.3,'LineStyle','none') 
for i = 1:AnalysisParams.Length-1
LightsOffHour = LightsOffHour + 24;
LightsOnHour = LightsOnHour+24;
fill([LightsOffHour LightsOnHour LightsOnHour LightsOffHour],[1 1 -1 -1],'black','FaceAlpha',0.3,'LineStyle','none') 
end
fill([0 hours(AnalysisParams.EndTime - AnalysisParams.StartTime) hours(AnalysisParams.EndTime - AnalysisParams.StartTime) 0],[1 1 0 0],'black','FaceAlpha',0.2,'LineStyle','none') 
hold on
SEMplot(ZT,FData.ShadeSleepPI,'b','b')
ylabel('Shaded Sleep PI')
xlabel('Hour')
xlim([0,ZT(end)])
set(gca,'TickDir','out');
set(gca,'linewidth',1.5)


%%  Time Wrap Plots 
if AnalysisParams.Length > 1 
    Wrap_X_By = 24; %hours to wrap data by 
    [WrapData] = DataWrap(FData,AnalysisParams,Wrap_X_By)
    sName = strcat(saveDir,'/','WrapData');
    save(sName,'WrapData')
else
    WrapData = FData;
end


%clearvars -except AnalysisParams Params TimeTable PosXY FData saveDir

%compile data to table
%OutputTable

OutputTable = table()
OutputTable.FlyID = (1:size(WrapData.binShade,2))'
OutputTable.Temp = repmat(10,height(OutputTable),1)
OutputTable.DayShadeTime = sum(WrapData.binShade(1:72,:)*10,'omitnan')'
OutputTable.NightShadeTime = sum(WrapData.binShade(73:end,:)*10,'omitnan')'
OutputTable.DaytimeSleepTime = sum(WrapData.SleepBin(1:24,:)*30,'omitnan')'
OutputTable.NighttimeSleepTime = sum(WrapData.SleepBin(25:end,:)*30,'omitnan')'
OutputTable.SleepPIDay = mean(WrapData.ShadeSleepPI(1:24,:),'omitnan')'
OutputTable.SleepPINight = mean(WrapData.ShadeSleepPI(25:end,:),'omitnan')'
%OutputTable.TotalDistance = mean(WrapData.ShadeSleepPI(25:end,:),'omitnan')'
saveDir = strcat(Params.saveDir,'_analysis');
fName = strcat(saveDir,'/OutputTable.xlsx')
writetable(OutputTable,fName)


