%This file simply plots the kurtosis value of each window.
function plots = kurtosis_plot(time, y_array, time_arr, kurtosis_data, threshold, x1, x2)

tiledlayout(2,1);

nexttile;
plot(time, y_array);
title('Filtered Accelerometer Data recorded 4/1/23', 'FontSize', 28);
xlabel('Time (s)', 'FontSize', 28);
ylabel('Acceleration (m/s^2)', 'FontSize', 28);
xlim([x1 x2])
nexttile;
% plot of above threshold rms values

splitcolorplot(time_arr, kurtosis_data', threshold, 'r-', 'b-');
yline(1)
title('Kurtosis of Events', 'FontSize', 28);
xlabel('Time (s)', 'FontSize', 28);
ylabel('Kurtosis', 'FontSize', 28);
xlim([x1 x2])

end
