function [timeStamp PDcenter PDerror sawtoothErr sawtoothCorr outlierRemoved averagerOut DACvoltage] = read_gpdo_log_bin_data()

[FileName,PathName] = uigetfile('*.bin','Select GPSDO binary data file');
filename = fullfile(PathName, FileName);

disp(sprintf('\n Reading GPSDO binary data: %s \n',filename));


%get the number of elements in file
fid=fopen(filename);
[~, count] = fread(fid,'double');
fclose(fid);

%read file into a [8,N] matrix
fid=fopen(filename);
[tmp] = fread(fid,[8,count./8],'double');
fclose(fid);

%extract data from [6,N] matrix
timeStamp      = tmp(1,:); %[matlab datenum format]
PDcenter       = tmp(2,:); %[ns]
PDerror        = tmp(3,:); %[ns]
sawtoothErr    = tmp(4,:); %[ns]
sawtoothCorr   = tmp(5,:); %[ns]
outlierRemoved = tmp(6,:); %[ns]
averagerOut    = tmp(7,:); %[ns]
DACvoltage     = tmp(8,:); %[mV] LSB = 10/(2^20) approx 10uV

disp(sprintf('   Data time span:'));
disp(sprintf('   Start time: %s',datestr(timeStamp(1))));
disp(sprintf('   Stop time: %s ',datestr(timeStamp(end))));
disp(sprintf('   Total time: %s \n',datestr(timeStamp(end)-timeStamp(1),13)));

disp('...Done!');

end

    
