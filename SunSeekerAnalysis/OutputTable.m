%generates output table for raw data 
%Summary 
OutputTable = table();
OutputTable.FlyID = find(FData.LivingFlies==1)'
OutputTable.Temp = repmat(10,height(OutputTable),1)
OutputTable.DayShadeTime = sum(WrapData.binShade(1:72,:)*10,'omitnan')'
OutputTable.NightShadeTime = sum(WrapData.binShade(73:end,:)*10,'omitnan')'
OutputTable.DaytimeSleepTime = sum(WrapData.SleepBin(1:24,:)*30,'omitnan')'
OutputTable.NighttimeSleepTime = sum(WrapData.SleepBin(25:end,:)*30,'omitnan')'
OutputTable.SleepPIDay = mean(WrapData.ShadeSleepPI(1:24,:),'omitnan')'
OutputTable.SleepPINight = mean(WrapData.ShadeSleepPI(25:end,:),'omitnan')'
saveDir = strcat(Params.saveDir,'_analysis');
fName = strcat(saveDir,'/OutputTable.xlsx')
writetable(OutputTable,fName,'Sheet','Summary')