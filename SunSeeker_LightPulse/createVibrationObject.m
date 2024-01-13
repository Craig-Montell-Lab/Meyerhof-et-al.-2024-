% Create vibration object 
FlyShake = struct(...
    'ExpStartTime', Params.StartTime, ...
    'StartOfShake',NaT,...
    'EndOfShake',datetime,...
    'Shaking',false,...
    'CurrentVoltage',0,...
    'ShakeSchedule',[],...
    'TimeSinceLastShake',minutes(Params.PulseWait));

ShakeSchedule = []
Stims =  Params.FirstStim:2:5;
counter = 1;
for i = 1:2:6
    ShakeSchedule(i,1) = Stims(counter);
    ShakeSchedule(i,2) = Params.PulseLength;
    counter = counter + 1;
end
lIdx = ~any(ShakeSchedule,2);
 
ShakeSchedule(lIdx,2) = Params.PulseWait;
for i = 2:size(ShakeSchedule,1)
   ShakeSchedule(i,2) = ShakeSchedule(i,2) + ShakeSchedule(i-1,2);
end
FlyShake.ShakeSchedule = ShakeSchedule
clearvars -except Params FlyTracks FlyShake 
