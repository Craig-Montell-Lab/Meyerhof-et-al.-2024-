function [FlyShake] = checkVibrate(FlyTracks,FlyShake,Params)

currTime = datetime;

SleepCheck = sum(vertcat(FlyTracks.Sleeping))/length(FlyTracks) >= Params.PulseThreshold;
StartCheck = currTime >= Params.StartTime;
TimeCheck = FlyShake.TimeSinceLastShake >= minutes(Params.PulseInterval);
CurrentlyOn = FlyShake.Shaking == true;

if SleepCheck + StartCheck + TimeCheck == 3 || CurrentlyOn == 1
    
    if isnat(FlyShake.StartOfShake)
       FlyShake.StartOfShake = currTime;
       FlyShake.Shaking = 1;
       FlyShake.TimeSinceLastShake = currTime - currTime;
    end
    
    TimeCheck = currTime - FlyShake.StartOfShake;
    [TimeIdx] = find(TimeCheck < seconds(FlyShake.ShakeSchedule(:,2)),1);
    Voltage = FlyShake.ShakeSchedule(TimeIdx);
    
    if Voltage ~= FlyShake.CurrentVoltage
        %begin stim
        FlyShake.CurrentVoltage = Voltage;
        writePWMVoltage(Params.Arduino, Params.ArduinoPin, FlyShake.CurrentVoltage)
    end
    
    if TimeCheck>max(seconds(FlyShake.ShakeSchedule(:,2)))
        FlyShake.TimeSinceLastShake = currTime - currTime;
        FlyShake.CurrentVoltage = 0;
        writePWMVoltage(Params.Arduino, Params.ArduinoPin, FlyShake.CurrentVoltage);
        FlyShake.Shaking = 0;
        FlyShake.EndOfShake = currTime;
    end
    
else
    FlyShake.StartOfShake = NaT;
    FlyShake.Shaking = 0;
    FlyShake.TimeSinceLastShake = currTime - FlyShake.EndOfShake;
end
end

    

