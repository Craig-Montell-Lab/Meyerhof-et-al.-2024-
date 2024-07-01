%SunSeeker parameters
%% dialogue box to set parameters 
predDate = datestr(datetime+1);
predStart = datetime(strcat(predDate(1:11), ' 08:00:00'));
predLength = 1;
predName = datestr(predDate(1:11));
prompt = {
    'start date(YYYY,M,D,H,M,S):',...
    'Enter length of recording (d):',...
    'Enter number of animals',...
    'Enter genotype',...
    'Save folder name'}; 

dlgtitle = 'Parameters';
dims = [1 35];
definput = {datestr(predStart),num2str(predLength),'30','wt',predName};
answer = inputdlg(prompt,dlgtitle,dims,definput);

%% save params
mkdir(answer{5})
Params.saveDir = answer{5};

%% video params 
% Params.File = '/Volumes/Backup Plus/reviewer_exps/sleep_depth/Example_stim.mp4'
% Params.videoSource = vision.VideoFileReader(Params.File,'VideoOutputDataType','uint8')%video example
Params.videoSource = imaq.VideoDevice('winvideo',2,'MJPG_1920x1080',...
    'ReturnedColorSpace',...
    'rgb','ReturnedDataType','uint8');

Params.videoSource.DeviceProperties.ExposureMode = char("manual");
Params.videoSource.DeviceProperties.Exposure = -5;

%% time params 
Params.StartTime = datetime(answer{1});
Params.EndTime = datetime(Params.StartTime) + str2double(answer{2}); 

%% fly params
Params.Genotype = answer{4};
Params.NumFlies = str2double(answer{3});
Params.maxArea = 500; %max area of fly
Params.minArea = 10; %min area of fly 

%% Arousal params
Params.PulseInterval = 120; %pulse interval in minutes (i.e. how long to wait for a new pulse)
Params.PulseWait = 10; %time between low, medium, high stim (s)
Params.StimStep = 1; %change in voltage between each stimulation
Params.PulseLength = 10; %time of stimulus (s)
Params.PulseThreshold = 0; %proportion of flies that must be asleep for a pulse 

%% Arduino Params 
Params.Arduino = arduino();
Params.ArduinoPin = 'D3';
Params.FirstStim = 1; %voltage to write for first of three stims

%% Tracking params 
Params.bModelNum = 30;
Params.Threshold = 6;


clearvars -except Params FlyTracks FlyShake