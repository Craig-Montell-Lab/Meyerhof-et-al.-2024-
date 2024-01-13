%SunSeeker parameters
%% dialogue box to set parameters 
predDate = datestr(datetime+1);
predStart = datetime(strcat(predDate(1:11), ' 08:00:00'));
predLength = 1;
predName = datestr(predDate(1:11));
prompt = {
    'start date(YYYY,M,D,H,M,S):',...
    'Enter length of recording (d):',...
    'Enter number of animals/arena',...
    'Enter genotype (sep. with "~" if>1)',...
    'Save folder name',...
    'Number of genotypes'}; 

dlgtitle = 'Parameters';
dims = [1 35];
definput = {datestr(predStart),num2str(predLength),'30','wt',predName, '2'};
answer = inputdlg(prompt,dlgtitle,dims,definput);
numGenotypes = str2double(answer{6});
%% save params
mkdir(answer{5})
Params.saveDir = answer{5};

%% video params 
% Params.File = '/Volumes/SENS-RF/sunSeeker_no_stim/Example_stim.mp4'
% Params.videoSource = vision.VideoFileReader(Params.File,'VideoOutputDataType','uint8')%video example
Params.videoSource = imaq.VideoDevice('winvideo',1,'MJPG_1920x1080',...
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
Params.numGenotypes = numGenotypes;
if Params.numGenotypes > 1 
    Params.Genotype =split(Params.Genotype,"~");
    newDir = {};
    for i = 1:length(Params.Genotype)
        newDir{i,1} = Params.saveDir +"/"+Params.Genotype{i};
        mkdir(Params.saveDir +"/"+Params.Genotype{i});
    end
    Params.saveDir = newDir;
end
% %% Arousal params
% %vibration stim
% Params.PulseInterval = 120; %pulse interval in minutes (i.e. how long to wait for a new pulse)
% Params.PulseWait = 120; %time between low, medium, high stim (s)
% Params.PulseLength = 3; %time of stimulus (s)
% Params.PulseThreshold = 0; %proportion of flies that must be asleep for a pulse 

% %% Arduino Params 
% Params.Arduino = arduino();
% Params.ArduinoPin = 'D3';
% Params.FirstStim = 1; %voltage to write for first of three stims


%% Tracking params 
Params.bModelNum = 30;
Params.Threshold = 6;


clearvars -except Params FlyTracks FlyShake