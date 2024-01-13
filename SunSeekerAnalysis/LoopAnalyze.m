FirstDir = '/Volumes/Geoff/ShadeSeekerData/25c/CS'
Folders ={
    '/Volumes/Geoff/ShadeSeekerData/25c/CS/17-Jun-2023_25'
    '/Volumes/Geoff/ShadeSeekerData/25c/CS/16-May-2023'
    '/Volumes/Geoff/ShadeSeekerData/25c/CS/31-May-2023'
}

SleepPITable = table();

for i = 1:length(Folders)
    curDir = Folders{i};
    cd(curDir);
    newDir = dir();
    AnalysisDir = vertcat({newDir.name});
    idx = find(contains(AnalysisDir,'analysis'));
    load('Params.mat')
    

    
    cd(AnalysisDir{idx})
    load('FilteredData.mat')
    load('AnalysisParams.mat')
    if isfield(FData,'ShadySleep') == 0
        cd ..
        shadeSeekerAnalysis
        cd(AnalysisDir{idx})
        load('FilteredData.mat')
        load('AnalysisParams.mat')
    end
    
    LightsOffIdx = 1:24;
    for i = 1:AnalysisParams.Length - 1
        newStart = max(LightsOffIdx)+25
        newAdd = newStart:newStart+24
        LightsOffIdx = [LightsOffIdx,newAdd]
    end
    
       
        
        SleepPI = mean(FData.ShadeSleepPI(LightsOffIdx,:),'omitnan');
        
        
        newTable = table();
        newTable.Genotype = repmat({Params.Genotype},size(SleepPI,2),1);
        newTable.SleepPI = SleepPI';
        newTable.Time = repmat({'Day'},size(SleepPI,2),1);
        newTable.FileName = repmat({Params.saveDir},size(SleepPI,2),1);
        
        SleepPITable = [SleepPITable;newTable];
    
    clearvars -except i SleepPITable  Folders FirstDir
    cd(FirstDir)
end















