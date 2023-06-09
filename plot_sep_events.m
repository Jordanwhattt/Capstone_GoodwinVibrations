
% Change the start and stop values to see different events 
% (num_events tells you how many events occured over entire dataset)
event_start = 1;
event_stop = 20;

% Range of events to plot
for e = event_stop:-1:event_start
    
    % initialize current event vector
    event = [];
    col = e;

    % get current event's time and get rid of zeros
    event_time = event_time_matrix(:,col);
    first_zero = find(event_time == 0,1);
    event(:,1) = event_time_matrix(1:first_zero-1,col);
    event(:,2) = event_kurt_matrix(1:first_zero-1,col);
    
   
    % grab indexes of the time interval
    start = min(event(:,1));
    stop = max(event(:,1));
    idx = find(time >= start & time <= stop);

    % accel and time during the current event
    e_accel = accel(idx);
    e_time = time(idx)';
    
    % accel vs time plot of one event
    figure(e);
    subplot(211);
    plot(e_time, e_accel);

    % graph size specifications
    x0=10;
    y0=10;
    width=1000;
    height=800;
    set(gcf,'position',[x0,y0,width,height]);
    
    % red lines to seperate windows
    xline(event(:,1), 'r');
    
    % labels
    title('Event '+ string(e), 'FontSize', 24);
    xlabel('Time', 'FontSize', 24);
    ylabel('Acceleration', 'FontSize', 24);
    
    % label kurtosis value for each window
    for i = 1:length(event(:,1))-1
        text(event(i,1), max(e_accel),'  k = ' + string(round(event(i,2), 2)), 'FontSize', 10)
    end
    
    % Power density vs Frequency plot
    wdwsec = e_time(end,1) - e_time(1,1); 
    wdw = floor(wdwsec*fs);
    [Paa, f] = pwelch(e_accel(:,1),wdw,wdw/2,wdw,fs); 
    subplot(212);
    plot(f,Paa);

    % labels
    title('Event '+ string(e), 'FontSize', 24);
    xlabel('Frequency', 'FontSize', 24);
    ylabel('Power Density', 'FontSize', 24);
end