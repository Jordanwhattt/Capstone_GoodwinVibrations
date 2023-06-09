clearvars;

mat2 = load("Walking.mat");
TDAT = mat2.TDATA;
data = mat2.TDATA.data; % data structure containing time and accel
time = mat2.TDATA.time; 
curr_accel = 20; % hallway = accelerometers 19-38
accel = data(:,curr_accel); 


% Highpass Filter

fs = 1024; % collected at 1024 Hz (Sample rate)
fpass = 64; % 10 Hz filter (Passband frequency)
nSignals = size(time,1); % i.e 60 mins = 3686400 values since 1024/s - 9830400 2 hours 40 mins

hpass_accel = highpass(accel, fpass, fs); % Filtered Data

% Sliding Window (Movie)
buffer = 64;  % nb of samples in one buffer (buffer size) 
overlap = 32; % overlap expressed in samples
[m,n] = size(hpass_accel);

%Window Calculation
shift = buffer-overlap;    % nb of samples between 2 contiguous buffers  
for ci=1:fix((m-buffer)/shift +1)
    start_index = 1+(ci-1)*shift;
    stop_index = min(start_index+ buffer-1,m);
    time_index(ci) = round((start_index+stop_index)/2);  % time index expressed as sample unit (dt = 1 in this simulation)
    time_arr(ci) = time(time_index(ci)); % Used for Kurtosis
    kurtosis_data(ci,:) = kurtosis_func(buffer, hpass_accel(start_index:stop_index,:));  % 
end

% Create binary vector
kurt_len = length(kurtosis_data);
kurt_bin = zeros(kurt_len, 1);
for i = 1:kurt_len
    if kurtosis_data(i,1) > 1
        kurt_bin(i,1) = 1;
    end
end

% Creation of list of event stamps
wind_start = 0;
wind_end = 0;
wind_list = zeros(1,2);
for j = 2:kurt_len
    if (kurt_bin(j-1)) == 0
        if kurt_bin(j) == 1
            wind_start = time_index(1,j-1);
            k = j;
            while (kurt_bin(k+1)) ~= 0
                k = k+1;
            end
            wind_end = time_index(1,j+1);
            wind_dbl = [wind_start, wind_end];
            wind_list = [wind_list;wind_dbl];
        end
    end
end
wind_list(1,:) = [];

event_qty = numel(find(kurt_bin==1));          





clf;
% Original Time data, accel data, kurtosis time aray, kurtosis data,
% threshold, xlim, ylim
kurtosis_plot(time, hpass_accel, time_arr, kurtosis_data, 1, min(time), max(time)) % Plots 1 Person Walking


%%
clc; clf;
timeRange = [time(wind_list(52,1)) time(wind_list(52,2))];
new_TDAT = TDAT.trim('Time', timeRange);

sensor_ind = [19 20 21];
tdat_trimmed = new_TDAT;
wdwsec = seconds(new_TDAT.duration);
wdw = floor(wdwsec*new_TDAT.fs);
[Paa,f] = pwelch(new_TDAT.data(:,sensor_ind),wdw,wdw/2,wdw,new_TDAT.fs);
            
subplot(211)
plot(new_TDAT.time,new_TDAT.data(:,sensor_ind));
xlabel('Relative time - sec');
ylabel(new_TDAT.units);
set(gca,'Fontsize',14);

subplot(212)
plot(f,Paa);
set(gca,'Yscale','log');
xlabel('Frequency - Hz ');
ylabel(['Power Spectral Density - ' new_TDAT.units '^2/Hz']);
legend(new_TDAT.sensorName(sensor_ind));
grid on
set(gca,'Fontsize',14);


%%
% function
function plots = kurtosis_plot(time, y_array, time_arr, kurtosis_data, threshold, x1, x2)

tiledlayout(2,1);

nexttile;
plot(time, y_array);
title('Filtered Accelerometer, Footsteps', 'FontSize', 24);
xlabel('Seconds', 'FontSize', 30);
ylabel('Acceleration (Meters per Seconds Squared)', 'FontSize', 18);
xlim([x1 x2])
nexttile;
% plot of above threshold rms values

splitcolorplot(time_arr, kurtosis_data', threshold, 'r-', 'b-');
title('Kurtosis of Filtered Accelerometer Data', 'FontSize', 24);
xlabel('Seconds', 'FontSize', 30);
ylabel('Kurtosis', 'FontSize', 30);
xlim([x1 x2])


end

% Functions
function kurtosis = kurtosis_func(n, x) % Calculates Kurtosis
    num_sum = sum((x-mean(x)).^4);
    den_sum = sum((x - mean(x)).^2);
    kurtosis_num = (1/n) * num_sum;
    kurtosis_den = ((1/n)*den_sum)^2;
    kurtosis = (kurtosis_num / kurtosis_den) - 3;
    return
end


function window_kurt = window_func(n, nWindows, x)
for j = 1:nWindows
    windowSignals = n/nWindows;
    data_window = x(windowSignals*(j-1) + 1 : windowSignals*(j));
    window_kurt(j) = kurtosis_func(windowSignals, data_window);  
end
end









