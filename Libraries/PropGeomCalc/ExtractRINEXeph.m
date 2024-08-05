function       eph=ExtractRINEXeph(userInput)
% USAGE:  Extract RINEX ephemeris file from website 
% https://cddis.nasa.gov/archive/gnss/data/daily/YYYY/DDD/YYn/brdcDDD0.YYn.Z
% and store the parameters in the eph struct:
year = userInput.dateTime(1);
day_of_year = datenum(userInput.dateTime(1),...
    userInput.dateTime(2),userInput.dateTime(3))-datenum(year-1,12,31);
PRN = userInput.PRN;

YYYY = num2str(year);
DDD = num2str(day_of_year);
if length(DDD)== 1
    DDD = ['0','0',DDD];
elseif length(DDD) == 2
    DDD = ['0',DDD];
end
YY = YYYY(3:4);
ephfile = ['brdc',DDD,'0.',YY,'n'];
RinexFileURL = ['https://cddis.nasa.gov/archive/gnss/data/daily/',YYYY,'/',DDD,'/',YY,'n/',ephfile,'.Z'];

if ~exist(ephfile,'file')
    if ~exist([ephfile,'.Z'],'file')
        username = input('Write the username: ', 's');
        password = input('Write the password: ', 's');

        status = system(['wget --auth-no-challenge --user=', username ' --password=', password, ' -O ', ephfile, '.Z ', RinexFileURL]);
        if status ~= 0
            error(['It was not possible to download the file automatically. It occurred because either `wget`' ...
                   'is not a recognized command on your system, the username/password is incorrect, or the URL' ...
                   'link is broken. Please download this file manually and rerun this script.']);
        end
    end
    fprintf('Unzipping ephemeris file %s \n',ephfile)
    system(['uncompress ',ephfile,'.Z']);
    if status ~= 0
        error(['Some Matlab versions do not recognize .zip compression.' ...
               ' If this error occurred, please go to the folder and manually uncompress the .Z ephemeris file.'])
    end
end
fprintf('Using ephemeris file %s \n',ephfile)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eph,~] =rinexe(ephfile); %Extract 21XN ephemeris files
%eph(21,:) is toe for each 21-element ephemeris
neph=find(eph(1,:)==PRN);
if isempty(neph)
    error('RINEX error ')
else
    eph=eph(:,neph);
end

% truncate the eph data to right after the user input time.
[GPStime_sec_start,GPSweek,GPSweek_z,leapsec]=UT2GPStime(userInput.dateTime);

ind = find(eph(end,:)>GPStime_sec_start,1,'first')-1;
if isempty(ind)
    ind = length(eph(end,:));
elseif ind==0
    ind = 1;
end
eph = eph(:,ind);

return