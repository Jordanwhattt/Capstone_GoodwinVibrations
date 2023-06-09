clc; clf;
walk = load("Walking.mat");

tdat = walk.TDATA;
curr_accel = 20 % Accelerometer 3C-20. Located middle of heaviliy instrumented hallway
accel = tdat.data(:,curr_accel);

fs = tdat.fs
fpass = 10; % 10 Hz filter (Passband frequency)

hpass_accel = highpass(accel,fpass, fs);

time = tdat.time;
%figure
plot(time, accel);
xlim([240 305])
ylim([-0.0015 0.0015])
%tdat.plotTimeFreq();

figure;
plot(time, hpass_accel);
xlim([240 305])
ylim([-0.0015 0.0015])

%Used for calculating the Kurtosis of a Sample from the accelerometer data.
%Size of Each window is 64 Values. (1/16th of a second)
buffer = 64;  % Size of Sample
overlap = 32; % overlap expressed in samples
[m,n] = size(hpass_accel); %(mx1)

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


kurtosis_plot(time, hpass_accel, time_arr, kurtosis_data, 1, 0, 420) % Plots 1 Person Walking

%% Decimate
% Decimate by 3 since data is over sampled
tdat = tdat.decimate(3);

%% Filter
% Bandpass filter between 2 and 256
tdat = tdat.filter([2 256],'bandpass');

tdat.plotTimeFreq();