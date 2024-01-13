function [WrapData] = DataWrap(FData,AnalysisParams,Wrap_X_By)

%% function creates wrapped data from shade seeker parameters stored in FData (filtered data) input
% Wrap_X_By: number of hours to take average from, usually 24h
% Analysis Params stores bin lengths

WrapData = struct(); %WrapData output structure
binLength = AnalysisParams.ActivityBinLength;
ZT = (0:AnalysisParams.Length*24/(AnalysisParams.Length*1440/binLength):(AnalysisParams.Length*24) - ((AnalysisParams.Length*24)/1440/binLength))'
[ZT,binShade] = TimeWrapXY(ZT,FData.binShade,Wrap_X_By);
WrapData.binShade = binShade;

%% create shade preference plot
figure('Position',[0.13,0.111112650479146,0.775*500,0.123209383419159*10000])
subplot(5,1,1)
title('Wrapped Data')
binLength = AnalysisParams.ActivityBinLength;
hold on
LightsOffHour = AnalysisParams.LightsOffHour;
LightsOnHour = 24
fill([LightsOffHour LightsOnHour LightsOnHour LightsOffHour],[1 1 0 0],'black','FaceAlpha',0.3,'LineStyle','none')
for i = 1:(Wrap_X_By/24)-1
    LightsOffHour = LightsOffHour + 24;
    LightsOnHour = LightsOnHour+24;
    fill([LightsOffHour LightsOnHour LightsOnHour LightsOffHour],[1 1 0 0],'black','FaceAlpha',0.3,'LineStyle','none')
end
SEMplot(ZT,WrapData.binShade,'r');
ylabel('Time spent in shaded region (min)');
xlabel('Hour');
xlim([0,ZT(end)]);
set(gca,'TickDir','out');
set(gca,'linewidth',1.5);

%
subplot(5,1,2)
binLength = AnalysisParams.ActivityBinLength;
ZT = (0:AnalysisParams.Length*24/(AnalysisParams.Length*1440/binLength):(AnalysisParams.Length*24) - ((AnalysisParams.Length*24)/1440/binLength))'

[ZT,binDist] = TimeWrapXY(ZT,FData.binDist,Wrap_X_By);
WrapData.binDist = binDist;

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
SEMplot(ZT,WrapData.binDist)
ylabel('Distance')
xlabel('Hour')
xlim([0,ZT(end)])
set(gca,'TickDir','out');
set(gca,'linewidth',1.5)
hold off
%
subplot(5,1,3)
binLength = 30
ZT = (0:AnalysisParams.Length*24/(AnalysisParams.Length*1440/binLength):(AnalysisParams.Length*24) - ((AnalysisParams.Length*24)/1440/binLength))'

[ZT,SleepBin] = TimeWrapXY(ZT,FData.SleepBin,Wrap_X_By);
WrapData.SleepBin = SleepBin;

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
SEMplot(ZT,WrapData.SleepBin)
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
[ZT,ShadySleep] = TimeWrapXY(ZT,FData.ShadySleep,Wrap_X_By);

ZT = (0:AnalysisParams.Length*24/(AnalysisParams.Length*1440/binLength):(AnalysisParams.Length*24) - ((AnalysisParams.Length*24)/1440/binLength))'
[ZT,SunnySleep] = TimeWrapXY(ZT,FData.SunnySleep,Wrap_X_By);

WrapData.ShadySleep = ShadySleep;
WrapData.SunnySleep = SunnySleep;

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
SEMplot(ZT,WrapData.ShadySleep,'b','b')
SEMplot(ZT,-WrapData.SunnySleep,'r','r')
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

[ZT,ShadeSleepPI] = TimeWrapXY(ZT,FData.ShadeSleepPI,Wrap_X_By);
WrapData.ShadeSleepPI = ShadeSleepPI;

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
SEMplot(ZT,WrapData.ShadeSleepPI,'r','r')
ylabel('Shaded Sleep PI')
xlabel('Hour')
xlim([0,ZT(end)])
set(gca,'TickDir','out');
set(gca,'linewidth',1.5)
end