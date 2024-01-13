addpath('/Users/geoffmeyerhof/Documents/MATLAB/my_funcs')
%nanidx = isnan(data.temp)|data.temp<8|data.temp>12;
nanidx = isnan(data.temp)|data.temp<23|data.temp>27;

filtdata = data.temp;
filtime = data.time;

filtdata(nanidx) = [];
filtime(nanidx) = [];


TOI = nan;
endTime = dateshift(filtime(1)+1,'start','minutes')
starTime = dateshift(filtime(1),'start','minutes')
go = 1
counter = 1;
TimeTable = NaT;
while go == 1
    [~,minidx] = min(abs(filtime-starTime));
    TOI(counter,1) = minidx;
    starTime = starTime + minutes(1);
    if starTime > endTime
        go = 0;
    end
    TimeTable(counter,1) = starTime;
    counter = counter + 1 ;

end

AVGTemp = [];
SEMTemp = [];
TimeTemp = NaT;
for i = 2:length(TOI)
    AVGTemp(i-1,1) = mean(filtdata(TOI(i-1):TOI(i)));
    SEMTemp(i-1,1) = std(filtdata(TOI(i-1):TOI(i)))/sqrt(length(TOI(i-1):TOI(i)));
    TimeTemp(i-1,1) = TimeTable(i-1);
end
plot(TimeTemp,AVGTemp)
hold on
ylim([22,30])


% %read in sun table and shade table 
% shade = shadeTable.Temp
% sun = sunTable.Temp
% 
% idx = (1:30)'
% Temps = []
% Sds = []
% for i = 1:48
%     Temps(i,1) = mean(shade(idx));
%     Temps(i,2) = mean(sun(idx));
%     
%     Sds(i,1) =  std(shade(idx))/sqrt(length(idx));
%     Sds(i,2) = std(sun(idx))/sqrt(length(idx));
%     
%     idx = idx + 30;
% end
% 
% fillOut = [flip(Temps(:,1)-Sds(:,1)); ([Temps(:,1)+Sds(:,1)])]
% 
% ZT = 0:0.5:24-0.5
% x2 = [flip(ZT)'; (ZT)'];
% 
% 
% patch([0, 8, 8, 0],[12,12,8,8],'black','FaceAlpha',0.3,'LineStyle','none')
% hold on
% patch([20, 24, 24, 20],[12,12,8,8],'black','FaceAlpha',0.3,'LineStyle','none')
% 
% hold on
% plot(ZT,Temps(:,1),'b')
% patch(x2, fillOut, 'b','FaceAlpha',0.3,'LineStyle','none');
% hold on
% fillOut = [flip(Temps(:,2)-Sds(:,2)); ([Temps(:,2)+Sds(:,2)])]
% patch(x2, fillOut, 'r','FaceAlpha',0.3,'LineStyle','none');
% plot(ZT,Temps(:,2),'r')
% ylim([10,11])
% xlim([0,24])
% xlabel('Hour')
% ylabel('Avg Temp (˚C)')
% legend('','','shaded','','','sunny')









