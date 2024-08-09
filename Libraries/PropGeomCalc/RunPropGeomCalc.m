function          satGEOM = RunPropGeomCalc(userInput,rhoFOVeff_ori)
%Usage: satGEOM = RunPropGeomCalc(userInput,rhoFOVeff_ori)
%This program prepares the parameters required for PropGeomCalc function which calculates the geometric propagation parameters.
% included in the satGEOM struct.
%INPUT:
%   userInput - dateTime, length, PRN
%   rhoFOVeff_ori - L1 rhoFOVeff value mapped from user input S4 and tau.
%   Used to infer the drift velocity.

%OUTPUT:
%	satGEOM - including: los range, propagation distance, veff. 

%written by Dongyang.Xu@colorado.edu
%
%Major subfunctions: GenUserTraj ExtractRINEXeph PropGeomCalc
%Libraries:  PropGeomCalc 
freqL1=154*10.23e6;
freqL2=120*10.23e6;
freqL5=115*10.23e6;
c = 299792458;             %Speed of light (vacuum)
dtr=pi/180;                %degree to radius factor

PRN = userInput.PRN;
year = userInput.dateTime(1);
UTCDateTime = userInput.dateTime;
day_of_year = fix(datenum(userInput.dateTime)-datenum(year,0,0,0,0,0));
fprintf('\n')
fprintf('[%4i,%2i,%2i]   day_of_year=%4i  \n',UTCDateTime(1),UTCDateTime(2),UTCDateTime(3),day_of_year);
fprintf('Start Time %2i hrs %2i min %4.2f sec PRN %d\n',UTCDateTime(4),UTCDateTime(5),UTCDateTime(6),PRN);

%% Generate user platform trajectory***************************************
origin_llh = GenUserTraj(userInput);

%% Download and extract the ephemeris of the satellite to be simulated*****
eph = ExtractRINEXeph(userInput);

%% Generate 1-s time samples for Geometry
[GPStime_sec_start,GPSweek,~,~]=UT2GPStime(userInput.dateTime);
GPSTime_sec_end = GPStime_sec_start + userInput.length-1;

GPSWeeknSec(1,:) = ones(1,userInput.length)*GPSweek;
GPSWeeknSec(2,:) = GPStime_sec_start:GPSTime_sec_end;

indexTemp = find(GPSWeeknSec(2,:)>=604800);
GPSWeeknSec(1,indexTemp) = GPSWeeknSec(1,indexTemp)+1;
GPSWeeknSec(2,indexTemp) = GPSWeeknSec(2,indexTemp)-604800;

h_intercept = 350000;
drift_ini = [0 100 0]';

origin_llh_stationary(1,:) = origin_llh(1,1) * ones(1,userInput.length);
origin_llh_stationary(2,:) = origin_llh(2,1) * ones(1,userInput.length);
origin_llh_stationary(3,:) = origin_llh(3,1) * ones(1,userInput.length);

%% Obtain the drift_ori based on user input tau through interpolation
satGEOM = PropGeomCalc(GPSWeeknSec,UTCDateTime,eph,origin_llh_stationary,h_intercept,[0 0 0]',drift_ini);
sat_rngeG = satGEOM.sat_rnge;
rngp         = satGEOM.rngp;
rngp_eff   = rngp.*(sat_rngeG-rngp)./sat_rngeG;
veff_ori = sqrt(rngp_eff)./(rhoFOVeff_ori*sqrt(2*pi*freqL1/c));
nn=0;

drift_East_range = 0:25:200;

for drift_East = drift_East_range %Establish the baseline of veff versus drift_East 
    nn = nn+1;
    satGEOM = PropGeomCalc(GPSWeeknSec,UTCDateTime,eph,origin_llh_stationary,h_intercept,[0 0 0]',[0 drift_East 0]');
    veff_range(nn) = mean(satGEOM.veff);
end
drift_East_est = mean(interp1(veff_range,drift_East_range,veff_ori,'spline')); %Interpolation
if(drift_East_est>250||drift_East_est<=0||mean(satGEOM.sat_elev)<=15*pi/180)
    error('RunPropGeomCalc:BadGeometry', 'bad geometry for Vdrift estimation and dynamic platform scintillation simulation');
end
%% Obtain the geometry based on the user defined dynamic platform
satGEOM = PropGeomCalc(GPSWeeknSec,UTCDateTime,eph,origin_llh,h_intercept,userInput.RXVel,[0 drift_East_est 0]');
VIpp_East = -mean(satGEOM.vkyz(1,:));
VIpp_North = mean(satGEOM.vkyz(2,:));

if (userInput.plotSign)
    hfig = figure;
    skyPlotFrame();
        xs=(90-satGEOM.sat_elev/dtr).*sin(satGEOM.sat_phi)/90;
        ys=(90-satGEOM.sat_elev/dtr).*cos(satGEOM.sat_phi)/90;
        plot(xs, ys, 'r', 'LineWidth', 3);
        hold on
        plot(xs(1), ys(1), 'or', 'LineWidth', 1, 'MarkerSize',4);
    text(xs(1)+0.03, ys(1),sprintf('%d',PRN));
    
    axis off
    title({['Sky View of GNSS SV Track ', userInput.PRN];...
        [num2str(fix(userInput.length/60)) ' min from UTC ' num2str(UTCDateTime(1)) '-' num2str(UTCDateTime(2)) '-' num2str(UTCDateTime(3))...
        ' ' num2str(UTCDateTime(4),'%02d') ':' num2str(UTCDateTime(5),'%02d') ':' num2str(UTCDateTime(6),'%02d')]});
    
    hfig2 = figure;
    plot3(satGEOM.satp_tcs(1,:)/1000,satGEOM.satp_tcs(2,:)/1000,satGEOM.satp_tcs(3,:)/1000,'k')
    hold on
    plot3(satGEOM.satp_tcs(1,1)/1000,satGEOM.satp_tcs(2,1)/1000,satGEOM.satp_tcs(3,1)/1000,'ko','LineWidth',6);
%     h = quiver3(satGEOM.satp_tcs(1,1:50:end)/1000,satGEOM.satp_tcs(2,1:50:end)/1000,satGEOM.satp_tcs(3,1:50:end)/1000,...
%         satGEOM.s(2,1:50:end)*5e4,-satGEOM.s(3,1:50:end)*5e4,-satGEOM.s(1,1:50:end)*5e4);
    h = quiver3(satGEOM.satp_tcs(1,1:50:end)/1000,satGEOM.satp_tcs(2,1:50:end)/1000,satGEOM.satp_tcs(3,1:50:end)/1000,...
        satGEOM.s(2,1:50:end)*5e4,-satGEOM.s(3,1:50:end)*5e4,0*satGEOM.s(1,1:50:end));
    set(h,'MaxHeadSize',0.05,'AutoScaleFactor',0.2);
%     h2 = quiver3(satGEOM.satp_tcs(1,1:50:end)/1000,satGEOM.satp_tcs(2,1:50:end)/1000,satGEOM.satp_tcs(3,1:50:end)/1000,...
%         -satGEOM.vkyz(1,1:50:end)*100000,satGEOM.vkyz(2,1:50:end)*100000,0*satGEOM.vkyz(2,1:50:end));
    h2 = quiver3(satGEOM.satp_tcs(1,1:50:end)/1000,satGEOM.satp_tcs(2,1:50:end)/1000,satGEOM.satp_tcs(3,1:50:end)/1000,...
        -satGEOM.vkyz(1,1:50:end)*100000,satGEOM.vkyz(2,1:50:end)*100000,0*satGEOM.vkyz(2,1:50:end));
    set(h2,'MaxHeadSize',0.04,'AutoScaleFactor',0.1);
    h2.Color = 'r';
    grid on
    xlabel('Eastward-km')
    xlim([min(satGEOM.satp_tcs(1,:)/1000)-10 max(satGEOM.satp_tcs(1,:)/1000)+10]);
    ylabel('Northward-km')
    ylim([min(satGEOM.satp_tcs(2,:)/1000)-10 max(satGEOM.satp_tcs(2,:)/1000)+10]);
    zlabel('Upward-km')
    zlim([min(satGEOM.satp_tcs(3,:)/1000)-10 max(satGEOM.satp_tcs(3,:)/1000)+10]);
    title({'Ionosphere Pierce Point';[' East V_d_r_i_f_t=', num2str(drift_East_est,3),...
        'm/s'];[' V_s_c_a_n [East, North] = [',num2str(VIpp_East,3),', ',num2str(VIpp_North,3),']m/s']});
    bold_fig
    legend('IPP','startPoint','Geomagn','V_s_c_a_n');
end
return
