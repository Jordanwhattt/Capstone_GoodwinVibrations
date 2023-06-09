% uncomment to load walking data
load("Walking.mat");

% uncomment to load random data
% load("RandomEvents.mat");

Tdata = TDATA;
time = Tdata.time; 

curr_accel = 20; % Acclerometer number

accel = Tdata.data(:,curr_accel); %Unfiltered Accelerometer Data

% Higpass Filter

fs = 1024; % sample rate (Hz)
fpass = 10; % filter (Passband frequency)
nSignals = size(time,1); % total signals

hpass_accel = highpass(accel, fpass, fs); % Filtered Data

% Sliding Window

buffer = 32;  % num of samples in one buffer (buffer size) 
overlap = 16; % overlap expressed in samples
[m,n] = size(hpass_accel);

%Window Calculation
shift = buffer-overlap;    % num of samples between 2 contiguous buffers  
for ci=1:fix((m-buffer)/shift +1)
    start_index = 1+(ci-1)*shift;
    stop_index = min(start_index+ buffer-1,m);
    time_index(ci) = round((start_index+stop_index)/2);  % time index expressed as sample unit (dt = 1 in this simulation)
    time_arr(ci) = time(time_index(ci)); % Used for Kurtosis
    kurtosis_data(ci,:) = kurtosis_func(buffer, hpass_accel(start_index:stop_index,:));  % 
end

% all the data
testData = kurtosis_data;

% Initialize the event markers array
event_markers = zeros(size(testData));

% track amount of events occurring
num_events = 0;

% matrix column length
col_len = 256;

% matrix of indexs during event occuring
event_idx_matrix = zeros(col_len, 1);

% matrix of kurtosis values during event occuring
event_kurt_matrix = zeros(col_len, 1);

% matrix of time values during event occuring
event_time_matrix = zeros(col_len, 1);

% kurtosis threshold
threshold = 1;

% Loop over each sample in the data
i = 1;

while i <= length(testData)

    if testData(i) > threshold

        % Find the start and end of the event
        event_start = i;
        event_end = i;
        
        % Extend the event until the signal goes above the threshold
        bool_end = false; 

        % when bool_end = true we should get out of loop
        while not(bool_end)

            while (testData(event_end) > threshold) && (event_end <= length(testData))
                event_end = event_end + 1;
            end
            
            % Need there to be 8 windows of noise after event (subject to
            % change)
            if (event_end + 8) >= length(testData)
                after_event = testData(event_end+1:length(testData));
            else
                after_event = testData(event_end+1:event_end+8);
            end
            if (every_val_below(after_event, threshold))
                bool_end = true;
            else
                event_end = event_end + 1;
            end
        end

        % Mark the event in the array if it is at least 3 windows long
        % (subject to change)
        if (event_end - event_start > 3)
            event_markers(event_start:event_end-1) = 1;

            num_events = num_events + 1;

            % mark the idexes of windows during event
            event_idx_matrix(1:length(event_start:event_end-1), num_events) = [event_start:event_end-1];
            event_idx_matrix(1:col_len,num_events+1) = zeros(col_len,1);
            
            % mark the kurtosis window values during event
            event_kurt_matrix(1:length(event_start:event_end-1), num_events) = testData(event_start:event_end-1, 1);
            event_kurt_matrix(1:col_len,num_events+1) = zeros(col_len,1);

            % mark the time during event
            event_time_matrix(1:length(event_start:event_end-1), num_events) = time_arr(1, event_start:event_end-1)';
            event_time_matrix(1:col_len,num_events+1) = zeros(col_len,1);

        end

        % Move the index to the end of the event
        i = event_end;
    else
        i = i + 1;
    end
end

% remove extra column created
event_idx_matrix(:,num_events + 1) = [];
event_kurt_matrix(:,num_events + 1) = [];
event_time_matrix(:,num_events + 1) = [];

function kurtosis = kurtosis_func(n, x) % Calculates Kurtosis
    num_sum = sum((x-mean(x)).^4);
    den_sum = sum((x - mean(x)).^2);
    kurtosis_num = (1/n) * num_sum;
    kurtosis_den = ((1/n)*den_sum)^2;
    kurtosis = (kurtosis_num / kurtosis_den) - 3;
    return
end

function bool = every_val_below(array, threshold)
    for i = 1:length(array)
        if array(i) >= threshold
            bool = false;
            return;
        end
    end
    bool = true;
end