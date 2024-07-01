%% quick save output data 
%Pos data 
PosXY = vertcat(FlyTracks.data);
PosX = PosXY(:,1)';
PosY = PosXY(:,2)';
PosXY = [PosX,PosY];

%Time data
TimeTable = table(currTime);

%Shake Data 
ShakeTable = table();
ShakeTable.Shaking = FlyShake.Shaking;
ShakeTable.CurrentVoltage = FlyShake.CurrentVoltage;

if fNum == 1
    save(strcat(Params.saveDir,'/',"PosXY.txt"),"PosXY","-ascii");
    writetable(TimeTable,strcat(Params.saveDir,'/',"TimeTable"));
    writetable(ShakeTable,strcat(Params.saveDir,'/',"ShakeTable"));
else
    save(strcat(Params.saveDir,'/',"PosXY.txt"),"PosXY","-ascii","-append");
    writetable(TimeTable,strcat(Params.saveDir,'/',"TimeTable"),"WriteMode","append");
    writetable(ShakeTable,strcat(Params.saveDir,'/',"ShakeTable"),"WriteMode","append");
end




