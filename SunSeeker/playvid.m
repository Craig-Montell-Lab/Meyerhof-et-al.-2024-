% playvid
%get XY coordinates 
XYs = vertcat(FlyTracks.data);
idx = ~isnan(XYs(:,1));
XYs = XYs(idx,:);
XYs = [XYs,ones(size(XYs,1),1)*10];
%show XY coordinates 
showFrame = insertShape(frame,'FilledCircle',XYs,'Color','m','Opacity',0.5);
ImmobileTimes = minutes(vertcat(FlyTracks.TimeImmobile));

%show immobile times 
ImmobileTimes = cellstr(num2str(round(ImmobileTimes(idx),2)));
showFrame = insertText(showFrame,XYs(:,1:2),ImmobileTimes);

%show pulse parameters 
showFrame = insertText(showFrame,[0,0],['Current Voltage =' num2str(FlyShake.CurrentVoltage)]);
showFrame = insertText(showFrame,[0,50],['TimeFromLastShake =' num2str(seconds(FlyShake.TimeSinceLastShake))]);
showFrame = insertText(showFrame,[0,100],['Shaking Initialized =' num2str(FlyShake.Shaking)]);

%play video 
vidPlayer(showFrame);
