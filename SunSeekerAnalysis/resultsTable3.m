saveDir = strcat(Params.saveDir,'_analysis');

ShakeIndex = getStartShake(ShakeTable);
ShakeEvents = max(ShakeIndex.ShakeEvent)
VelocityBin = Params.PulseWait %time for binning velocity before start of stimulus (s)
[Mvmnt,Dist] = FlyMove(PosXY,Params.NumFlies,AnalysisParams.MoveThresh);
Dist = Dist/AnalysisParams.pix2m;

%Filter dead animals 
Mvmnt = Mvmnt(:,FData.LivingFlies);
Dist = Dist(:,FData.LivingFlies);

%Get shade data (where 1 is in shade and 0 is sun)
MidPoints = Params.ROI(:,1) + Params.ROI(:,3)/2;
liveIdx = find(vertcat(FData.LivingFlies) == 1)
ShadeLogical = PosXY(:,liveIdx) < MidPoints(liveIdx)';

ArousalTable = table();
ArousalTable.ShakeEvent = ShakeIndex.ShakeEvent;

% Table parameters %
% 'Volt',... %voltage applied to shaker
% 'ZT',... %time of stimulus 
% 'MovingAtStart',... %how many flies were moving at start of lowest stimulus (e.g. volt = 1)
% 'AwakeAtStart',...%which flies were awake at the start of stimulus
% 'MvmntAtEnd',...  %how many flies started moving during/after each stimulus 
% 'ImmobileTime',... %how long were flies immobile if they were immobiile at start
% 'AvgVelocToStim',... %average velocity of each fly up to start of stimulus.
        %first value, 0, is velocity before the first stimulus 

% get volts and times 
Volt = []
ZT = [] 
for i = 1:height(ShakeIndex)
    Volt(i) = ShakeIndex(i,:).VoltStart;
    ZT(i) = hours(TimeTable.currTime(ShakeIndex(i,:).StartIndex) - AnalysisParams.StartTime);
end

ArousalTable.Volt = Volt';
ArousalTable.ZT = ZT';

%get average velocity at each stimulus (0 is before stimulus, 1 is 1:2, 2
% is 2:3, and 5 is 5:5 + pulse wait
%       *Also get whether fly was in shade*
AvgVeloc = [];
InShade = [];
for i = 1:height(ShakeIndex)
    Range = ShakeIndex(i,:).StartIndex:ShakeIndex(i,:).EndIndex;
    AvgVeloc(i,:) = sum(Dist(Range,:));
    InShade(i,:) = round(sum(ShadeLogical(Range,:))/length(Range));
end

ArousalTable.AvgVelocToStim = AvgVeloc;
ArousalTable.InShade = InShade;
%% get id of flies that were immobile at the start of each stimulus (e.g. 0.5
ImmobileTime = seconds(1); % consecutive time of inactivity 
ImmobilityThresh = 0.07 %proportion of tube fly must travel after stim to be considered awake
AwakeAtStart = [];
for i = 1:height(ShakeIndex)
    if ShakeIndex(i,:).VoltStart == 0
        TOI = TimeTable(ShakeIndex(i,:).EndIndex+1,:).currTime - ImmobileTime;
        [~,jumpIdx] = min(abs(TOI - TimeTable.currTime));
        Range = jumpIdx:ShakeIndex(i,:).EndIndex;
%         Awake  = sum(Dist(Range,:))*AnalysisParams.pix2m > mean(Params.ROI(:,3))/(1/ImmobilityThresh);
        Awake  = sum(Mvmnt(Range,:))>0;
    else
          Range = ShakeIndex(i,:).StartIndex:ShakeIndex(i,:).EndIndex;
          Awake  = sum(Dist(Range,:))*AnalysisParams.pix2m > mean(Params.ROI(:,3))/(1/ImmobilityThresh);
          Awake = Awake + AwakeAtStart(i-1,:);
          Awake = Awake>0;
    end
    AwakeAtStart(i,:) = Awake;
end
ArousalTable.AwakeAtStart = AwakeAtStart;

%Get wake voltage
ArousalThresh = table();
FlyIds = find(FData.LivingFlies == 1);
for i = 1:ShakeEvents
    subTable = ArousalTable(ArousalTable.ShakeEvent == i,:);
    miniTable = table();
    %get awake and asleep at start of experiment ids
    for ii = 1:length(FlyIds)
        miniTable.ZT = round(subTable.ZT(1,1),1);
        miniTable.FlyID = FlyIds(ii);
        miniTable.InShade = subTable.InShade(1,ii); %annotate with whether fly was in shade b4 start of stim train
        %immobile check (if moving, assign nans)
        AwakeCheck = subTable.AwakeAtStart(1,ii);
        if AwakeCheck == 1
            miniTable.wakeVoltage = nan;
        else
            Stimmy = [subTable.AwakeAtStart(:,ii),unique(ArousalTable.Volt)];
            [wakeIdx] = find(Stimmy(:,1) == 1,1,'first');
            if isempty(wakeIdx)
                miniTable.wakeVoltage = 6;
            else
                miniTable.wakeVoltage = Stimmy(wakeIdx,2);
            end
        end
        ArousalThresh = [ArousalThresh;miniTable];
        
    end
end

% %write arousal table
% sName = strcat(saveDir,'/','ArousalThresh.mat');
% save(sName,'ArousalThresh')

%Plot Arousal Threshold (sanity check)
AT = [];
ZTs = unique(ArousalThresh.ZT);
aData = [];
for i = 1:length(ZTs)
    subTable = ArousalThresh(ArousalThresh.ZT == ZTs(i),:)
    aData(i,:) = subTable.wakeVoltage;
end

figure('Position',[800,800,300,300])
SEMplot(ZTs,aData,'b','b')
xlim([0,24])
ylabel('Arousal Threshold')
xlabel('ZT')


%% get time that each fly was immobile for at start of stimulus
LengthOfImmobility = nan(height(ArousalThresh),1);
numWakes = find(~isnan(ArousalThresh.wakeVoltage));

FlyIds = [FData.LivingFlies',(1:Params.NumFlies)'];
FlyIds(FlyIds(:,1)==0,:) = [];
for i = 1:length(numWakes)
    FlyID = ArousalThresh(numWakes(i),:).FlyID;
    FlyID = find(FlyID == FlyIds(:,2));
    wakeVoltage = ArousalThresh(numWakes(i),:).wakeVoltage;
    if wakeVoltage == 6
        wakeVoltage = 5;
    end
    ZT = round(ArousalThresh(numWakes(i),:).ZT);
    
    wakeIndex = find(ZT == round(ArousalTable.ZT)&ArousalTable.Volt == wakeVoltage,1);
    wakeIndex = ShakeIndex(wakeIndex,:).StartIndex;
    %Loop over distance data to find last movement of fly
    GO = 1;
    DistTraveled = 0;
    StepIndex = wakeIndex;
    while GO == 1
        STEP = Dist(StepIndex-1,FlyID) * AnalysisParams.pix2m;
        DistTraveled = DistTraveled + STEP;
        if DistTraveled > (mean(Params.ROI(:,3))/(1/ImmobilityThresh)) 
            GO = 0;
            startSleepIndex = StepIndex;
        else
            StepIndex = StepIndex - 1;
        end
    end
    
    immobileDur = TimeTable(wakeIndex,:).currTime - TimeTable(startSleepIndex,:).currTime;
    LengthOfImmobility(numWakes(i),:) = minutes(immobileDur);
    disp(strcat('Number of events remaining:',num2str(length(numWakes) - i)))
end
ArousalThresh.LengthOfImmobility = LengthOfImmobility;

%write results to table 
sName = strcat(saveDir,'/','ArousalThresh_v2');
writetable(ArousalThresh,sName)
% %% Plot immobility time vs. arousal threshold 
% figure
% hold on
% for i = 1:6
%     subTable = ArousalThresh(ArousalThresh.wakeVoltage==i,:);
%     scatter(subTable.wakeVoltage,subTable.LengthOfImmobility,'f','MarkerFaceAlpha',0.4);
%     meaVal = mean(subTable.LengthOfImmobility,'omitnan');
%     scatter(unique(subTable.wakeVoltage),meaVal,'r','f');
%     ylabel('Mean time immobile')
% end
% 
% figure
% hold on
% for i = 1:6
%     subTable = ArousalThresh(ArousalThresh.wakeVoltage==i,:);
%     scatter(subTable.wakeVoltage,subTable.ZT,'f','MarkerFaceAlpha',0.1);
%     meaVal = mean(subTable.ZT,'omitnan');
%     scatter(unique(subTable.wakeVoltage),meaVal,100,'r','f');
% end
% 


