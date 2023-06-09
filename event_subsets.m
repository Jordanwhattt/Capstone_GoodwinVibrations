%Subsetting Data Events
clc; clearvars
walk = load("Walking.mat");

tdat = walk.TDATA;
curr_accel = 20 % Accelerometer 3C-20. Located middle of heaviliy instrumented hallway
accel = tdat.data(:,curr_accel);
time = tdat.time;

fs = tdat.fs
fpass = 10; % 10 Hz filter (Passband frequency)
hpass_accel = highpass(accel,fpass, fs);

date = "01-Apr-2023 ";
tims_time_start = "11:41:55";
tims_time_end = "11:42:40";
jordan_time_start = "11:44:22";
jordan_time_end = "11:44:22";

fs = tdat.fs;


for i = 1:fs:size(tdat.timeStamp,1)
    str = extractAfter(string(tdat.timeStamp(1,i)), date);
    if(str == jordan_time_start)
        jordan_timeStamp_index = i
        str
    end
end



% Doing simple math, My footsteps began ~167 seconds after the time started
% and ended at  ~228
jordan_event_start_index = 167;
jordan_event_end_index = 228;

jordan_event_time = time(jordan_event_start_index*fs:jordan_event_end_index*fs);
jordan_accel = hpass_accel(jordan_event_start_index*fs:jordan_event_end_index*fs);

buffer1 = 128;  % Size of Sample
overlap1 = 64; % overlap expressed in samples
m = size(hpass_accel,1); %(mx1)
m1 = size(jordan_accel,1); %(mx1)

shift1 = buffer1-overlap1;    % nb of samples between 2 contiguous buffers  
len1 = fix((m1-buffer1)/shift1 +1); % Number of Kurtosis Samples
time_index1 = zeros(1, len1); %Index of time Array
time_arr1 = zeros(1, len1); %Time array based on the samples of Kurtosis
jordan_kurtosis_data = zeros(len1, 1); %Kurtosis 

for ci=1:fix((m1-buffer1)/shift1 +1)
    start_index = 1+(ci-1)*shift1;
    stop_index = min(start_index+ buffer1-1,m1);
    time_index1(ci) = round((start_index+stop_index)/2);  % time index expressed as sample unit (dt = 1 in this simulation)
    time_arr1(ci) = time(time_index1(ci)); % Used for Kurtosis
    jordan_kurtosis_data(ci,:) = kurtosis_func(buffer1, jordan_accel(start_index:stop_index,:));  % 
end

buffer = 64;  % Size of Sample
overlap = 32; % overlap expressed in samples
shift = buffer-overlap;    % nb of samples between 2 contiguous buffers  
len = fix((m-buffer)/shift +1); % Number of Kurtosis Samples
time_index = zeros(1, len); %Index of time Array
time_arr = zeros(1, len); %Time array based on the samples of Kurtosis
kurtosis_data = zeros(len, 1); %Kurtosis 

for ci=1:fix((m-buffer)/shift +1)
    start_index = 1+(ci-1)*shift;
    stop_index = min(start_index+ buffer-1,m);
    time_index(ci) = round((start_index+stop_index)/2);  % time index expressed as sample unit (dt = 1 in this simulation)
    time_arr(ci) = time(time_index(ci)); % Used for Kurtosis
    kurtosis_data(ci,:) = kurtosis_func(buffer, hpass_accel(start_index:stop_index,:));  % 
end

figure;
kurtosis_plot(jordan_event_time, jordan_accel, time_arr1, jordan_kurtosis_data, 1, 0, 420) % Me walking


figure;
kurtosis_plot(time, hpass_accel, time_arr, kurtosis_data, 1, 0, 420) % Everyone Walking








