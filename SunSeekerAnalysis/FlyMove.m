% annotate movement: 1 is move, 0 is stationary   
function [Mvmnt,Dist] = FlyMove(PosXY,numAnimal,MoveThresh)
dY = diff(PosXY(:,1:numAnimal)).^2;
dX = diff(PosXY(:,1+numAnimal:end)).^2;
Dist = [repelem(0,numAnimal);sqrt(double(dY)+double(dX))];

Mvmnt = zeros(size(Dist));
Mvmnt(Dist>=MoveThresh) = 1;

% %Pull XY values 
% Xs = PosXY(:,1:numAnimal);
% Ys = PosXY(:,numAnimal+1:numAnimal*2);
% %Allocate distance and movement arrays 
% Dist = zeros(size(Xs));
% Mvmnt = zeros(size(Xs));
% %Calculate ecludiean distance for eachmovement pair 
% Counter = 1; 
% for ii = 1:size(PosXY,2)/2
%      for i = 2:size(PosXY,1)
%         P1 = double([PosXY(i-1,ii),PosXY(i-1,ii+numAnimal)]);
%         P2 = double([PosXY(i,ii),PosXY(i,ii+numAnimal)]);
%         [D] = pdist2(P1,P2,'euclidean');
%             if D > MoveThresh
%                 Mvmnt(i,Counter) = 1;
%                 Dist(i,Counter) = D;
%             else
%                 Mvmnt(i,Counter) = 0;
%                 Dist(i,Counter) = D;
%             end
%      end
% Counter = Counter +1
% end
% 
%      
end


        

