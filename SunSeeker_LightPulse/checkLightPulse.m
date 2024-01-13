function [LightPulse] = checkLightPulse(FlyTracks,LightPulse,Params,ArduinoPort)
%%
currTime = datetime;
%SleepCheck = sum(vertcat(FlyTracks.Sleeping))/length(FlyTracks) >= Params.PulseThreshold;
StartCheck = currTime >= Params.StartTime;
TimeCheck = LightPulse.TimeSinceLastPulse >= minutes(Params.LightPulseInterval);
CurrentlyOn = LightPulse.LightsOn == true;

if StartCheck&&TimeCheck==1||CurrentlyOn==1
    if isnat(LightPulse.StartOfPulse)
       LightPulse.StartOfPulse = currTime;
       LightPulse.LightsOn = 1;
       LightPulse.TimeSinceLastPulse= currTime - currTime;
    end
    TimeCheck = currTime - LightPulse.StartOfPulse;
    [TimeIdx] = find(TimeCheck < seconds(LightPulse.LightPulseSchedule(:,2)),1);
    Voltage = LightPulse.LightPulseSchedule(TimeIdx);
   %on condition (in stim train)
    if Voltage > 0&LightPulse.CurrentVoltage~=Voltage
        %begin stim
        LightPulse.CurrentVoltage = Voltage;
        toArduino = 1 + "/r"; %on condition 
        write(ArduinoPort,toArduino,"string")
        write(ArduinoPort,toArduino,"string")

    end
   %off condition (in stim train)
   if Voltage == 0&LightPulse.CurrentVoltage~=Voltage
       LightPulse.CurrentVoltage = Voltage;
       toArduino = 0 + "/r"; %off condition 
       write(ArduinoPort,toArduino,"string")
       write(ArduinoPort,toArduino,"string")

   end
   
   %off condition (to end stim train) 
   if TimeCheck>max(seconds(LightPulse.LightPulseSchedule(:,2)))&&LightPulse.CurrentVoltage>0
        LightPulse.TimeSinceLastShake = currTime - currTime;
        LightPulse.CurrentVoltage = 0;
        toArduino = 0 + "/r"; %off condition 
        write(ArduinoPort,toArduino,"string")        
        LightPulse.LightsOn = 0;
        LightPulse.EndOfPulse = currTime;
   end
else
    LightPulse.StartOfPulse = NaT;
    LightPulse.TimeSinceLastPulse = currTime - LightPulse.EndOfPulse;
end
end




