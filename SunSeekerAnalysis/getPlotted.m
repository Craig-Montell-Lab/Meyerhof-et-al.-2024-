%Get arousal plots 
figure
AvgVeloc = []
for i = 1:height(ArousalTable)
    AvgVeloc(i,1) = mean(ArousalTable(i,:).AvgVelocToStim)
end

ZT = ArousalTable.ZT
scatter(ZT,AvgVeloc)
hold on
plot(ZT,AvgVeloc)
%% arousal plot 
figure
scatter(ArousalTable.ZT,mean(ArousalTable.AwakeAtStart,2),'filled')
vol1Idx = find(ArousalTable.Volt == 1)
vol3Idx = find(ArousalTable.Volt == 3)
vol5Idx = find(ArousalTable.Volt == 5)
vol0Idx = find(ArousalTable.Volt == 0)

hold on
xline(ArousalTable(vol1Idx,:).ZT,'blue')
xline(ArousalTable(vol3Idx,:).ZT,'green')
xline(ArousalTable(vol5Idx,:).ZT,'m')
xline(ArousalTable(vol0Idx,:).ZT,'red')

