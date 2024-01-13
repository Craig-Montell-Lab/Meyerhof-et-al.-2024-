%% quick save output data
%Pos data
for saveIdx = 1:Params.numGenotypes
    GOI = find(strcmp([FlyTracks.genotype], Params.Genotype{saveIdx}));
    
    PosXY = vertcat(FlyTracks(GOI).data);
    PosX = PosXY(:,1)';
    PosY = PosXY(:,2)';
    PosXY = [PosX,PosY];
    
    %Time data
    TimeTable = table(currTime);
    
    % %Shake Data
    % ShakeTable = table();
    % ShakeTable.Shaking = FlyShake.Shaking;
    % ShakeTable.CurrentVoltage = FlyShake.CurrentVoltage;
    
    %Light Pulse Data 
    LightTable = table();
    LightTable.LightsOn = LightPulse.LightsOn;
    LightTable.CurrentVoltage = LightPulse.CurrentVoltage;
    
    if fNum == 1
        save(strcat(Params.saveDir{saveIdx,1},'/',"PosXY.txt"),"PosXY","-ascii");
        writetable(TimeTable,strcat(Params.saveDir{saveIdx,1},'/',"TimeTable"));
        % writetable(ShakeTable,strcat(Params.saveDir,'/',"ShakeTable"));
        writetable(LightTable,strcat(Params.saveDir,'/',"LightTable"));

    else
        save(strcat(Params.saveDir{saveIdx,1},'/',"PosXY.txt"),"PosXY","-ascii","-append");
        writetable(TimeTable,strcat(Params.saveDir{saveIdx,1},'/',"TimeTable"),"WriteMode","append");
        % writetable(ShakeTable,strcat(Params.saveDir,'/',"ShakeTable"),"WriteMode","append");
        writetable(LightTable,strcat(Params.saveDir,'/',"LightTable"),"WriteMode","append");

    end
    
end





