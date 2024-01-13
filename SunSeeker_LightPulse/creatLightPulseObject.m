% Create vibration object
clear ArduinoPort
Com = '/dev/cu.usbmodem141301';%arduino serial port
ArduinoPort = serialport(Com,115200);%open serial port 
%add light pulse params to structure
Params.LightPulseInterval = 120; %pulse interval in minutes (i.e. how long to wait for a new pulse)
Params.LightPulseWait = 10; %time between subsequent light pulses 
Params.LightPulseLength = 3; %time of stimulus (s)
Params.PulseThreshold = 0;
Params.numLightPulses = 5;

LightPulse = struct(...
    'ExpStartTime', Params.StartTime, ...
    'StartOfPulse',NaT,...
    'EndOfPulse',datetime-minutes(Params.LightPulseInterval),...
    'LightsOn',false,...
    'CurrentVoltage',0,...
    'PulseSchedule',[],...
    'TimeSinceLastPulse',minutes(Params.LightPulseInterval));

LightPulseSchedule = []
Pulses =  1:Params.numLightPulses;
Pulses = reshape([Pulses;zeros(1,numel(Pulses))],1,[])'
numWaits = repmat([Params.LightPulseLength;Params.LightPulseWait],length(Pulses)/2,1)
LightPulseSchedule(:,1) = Pulses';
LightPulseSchedule(:,2) = numWaits;
LightPulseSchedule(end,:) = [];
for i = 2:size(LightPulseSchedule,1);
   LightPulseSchedule(i,2) = LightPulseSchedule(i,2) + LightPulseSchedule(i-1,2);
end
LightPulse.LightPulseSchedule = LightPulseSchedule
clearvars -except Params FlyTracks LightPulse ArduinoPort