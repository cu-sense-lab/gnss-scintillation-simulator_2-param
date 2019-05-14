function origin_llh = GenUserTraj(userInput)
% Usage: Generate origin_llh based on the original receiver location for dynamic
% platform simulation
% The components and units for origin_llh are latitude, longitude and height (rad,rad,m)
% The velocity vector consists of components in east-west, north-south, up-down
% directions.
% Joy
% Written:  03/28/2017
% Modified by Dongyang: 10/18/2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialization
eastwest_v = userInput.RXVel(1);  % east-west velocity on the earth arc (m/s, eastward +)
northsouth_v = userInput.RXVel(2);  % north-south velocity on the earch arc (m/s, northward +)
updown_v = userInput.RXVel(3); % up-down velocity (m/s, up +)
N = userInput.length; 
origin_llh = ones(3,N);
origin_llh(1,:) = origin_llh(1,:)*userInput.RXPos(1);
origin_llh(2,:) = origin_llh(2,:)*userInput.RXPos(2);
origin_llh(3,:) = origin_llh(2,:)*userInput.RXPos(3);

earthRadius = 6378.137e3;  % earth radius (m)

%% Main routine
if updown_v ~= 0
    for ii = 2:N
        origin_llh(3,ii) = origin_llh(3,ii-1)+updown_v;
    end
end
if northsouth_v ~= 0
    northsouth_radv = northsouth_v./(earthRadius+origin_llh(3,:));  % angular velocity (rad/s)
    for ii = 2:N
        origin_llh(1,ii) = origin_llh(1,ii-1)+northsouth_radv(ii-1);
    end
end
if eastwest_v ~= 0
    eastwest_radv = eastwest_v./(earthRadius+origin_llh(3,:));  % angular velocity (rad/s)
    for ii = 2:N
        origin_llh(2,ii) = origin_llh(2,ii-1)+eastwest_radv(ii-1);
    end
end