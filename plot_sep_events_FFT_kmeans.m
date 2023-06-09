
% Change the start and stop values to see different events 
% (num_events tells you how many events occured over entire dataset)
event_start = 1;
event_stop = 64;

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
    max_kurt(e) = max(event(:,2));
    
   
    % grab indexes of the time interval
    start = min(event(:,1));
    stop = max(event(:,1));
    idx = find(time >= start & time <= stop);

    % accel and time during the current event
    e_accel = accel(idx);
    e_time = time(idx)';
    
    % accel vs time plot of one event
    figure(e);
    tiledlayout(3,1);
    nexttile;
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
    event_length = length(event(:,1));
    % label kurtosis value for each window
    for i = 1:event_length-1
        text(event(i,1), max(e_accel),'  k = ' + string(round(event(i,2), 2)), 'FontSize', 10)
    end
    
    % Power density vs Frequency plot
    wdwsec = e_time(end,1) - e_time(1,1); 
    wdw = floor(wdwsec*fs);
    [Paa, f] = pwelch(e_accel(:,1),wdw,wdw/2,wdw,fs);
    [M,I] = max(Paa);
    max_f1_power_spectrum(e) = f(I);% This vector contains the 
    % frequency of the Max amplitude for the power spectrum
    


    nexttile;
    plot(f,Paa);



    % labels
    title('Frequency V.s Power Spectrum Plot','FontSize', 24);
    xlabel('Frequency (Hz)', 'FontSize', 24);
    ylabel('Power Density', 'FontSize', 24);
    P1 = zeros(floor(length(e_accel)/2)+1);
    P2 = zeros(length(e_accel));
    signal_length = length(e_accel);
    T = 1/fs;  
    t = (0:signal_length-1)*T;        % Time vector
    Y = fft(e_accel);
    P2 = abs(Y/signal_length);
    P1 = P2(1:signal_length/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f2 = fs*(0:(signal_length/2))/signal_length;
    [M,I] = max(P1);
    max_f2_fft(e) = f2(I); % This vector contains the 
    % frequency of the Max amplitude for the fft

    nexttile;
    plot(f2,P1) 
    title('Frequency V.s FFT Plot','FontSize', 24);
    xlabel("Frequency (Hz)", 'FontSize', 24);
    ylabel("|P1(f)|", 'FontSize', 24);
    
    % Noise is why we do not get exact amplitude. Frequency 
end

%% Arrays to use for K_means Clustering, 

k_means_matrix =[max_kurt; max_f1_power_spectrum; max_f2_fft];
%K_means Clustering
k_means_matrix = k_means_matrix';
[coeff,score] = pca(k_means_matrix);
%perform pca
pc_values = score(:, 1:3);
%perform k-means on data
[clusters, centroids] = kmeans(pc_values, 2);
%Separate into footsteps and non-footsteps
cluster_legend = {'Footsteps', 'Non-Footsteps'};
cluster_names = cell(1, size(k_means_matrix, 1));
for i = 1:size(k_means_matrix, 1)
    if (clusters(i) == 1)
        cluster_name = cluster_legend{1};
        cluster_names{i} = cluster_name;
        
    else
        cluster_name = cluster_legend{2};
        cluster_names{i} = cluster_name;
    end
end
cluster_names = strrep( cluster_names(1,:),'"','');
figure;
gscatter3(pc_values(1:length(clusters), 1),...
pc_values(1:length(clusters), 2),...
pc_values(1:length(clusters),3),...
cluster_names, {'b', 'r'}, {'.', '.'},25, 'auto', 1,... 
'SouthEast');
xlabel('First Principal Component');
ylabel('Second Principal Component');
zlabel('Third Principal Component');
title('Principal Component Scatter Plot(3D) with Colored Clusters');
figure;
gscatter(pc_values(1:length(clusters), 1),... 
pc_values(1:length(clusters), 2),cluster_names', 'rkgb','+',15,'on');
xlabel('First Principal Component');
ylabel('Second Principal Component');
title('Principal Component Scatter Plot(2D) with Colored Clusters');