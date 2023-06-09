field1 = 'name';
field2 = 'pos_x';
field3 = 'pos_y';

[~,~,dat]=xlsread('VTSIL_AccelList_20190813.xlsx');
dat=[dat(:,1) dat(:,10) dat(:,11)];
filler = [];
default = 60;

for i=2:1000
    value1 = dat{i,1};
    value2 = dat{i,2};
    value3 = dat{i,3};
    s(i-1) = struct(field1, num2str(value1), field2, value2, field3, value3);
end

% figure1 = figure('Name', 'All Accels');
% for j=1:length(s)
%     dx = .1;
%     dy = .1;
%     plot(s(j).pos_x, s(j).pos_y,'ko','markerfacecolor','k', 'color','black')
%     text(s(j).pos_x + dx, s(j).pos_y, s(j).name)
%     hold on
% end
% hold off
% 
% figure2 = figure('Name', '3rd floor');
% % count = 0;
% for k=1:length(s)
%     name = s(k).name;
%     c1 = name(1);
%     if strcmp(c1, '3')
%         plot(s(k).pos_x, s(k).pos_y,'ko','markerfacecolor','k', 'color','black')
%         %text(s(k).pos_x + dx, s(k).pos_y, s(k).name)
%     end
%     hold on
% end

load("3C26_3C32_3C62.mat")

figure3 = figure("Name", "3rd Floor with 3C26 3C32 3C62");
for w=1:length(s)
    name = s(w).name;
    if strcmp(name, "3C-26")
        p = plot(s(w).pos_x, s(w).pos_y,'ko','markerfacecolor','k', 'color','blue', "MarkerSize", 60);
        text(s(w).pos_x + 10, s(w).pos_y + 10, s(w).name);
    end
    if strcmp(name, "3C-32")
        d = plot(s(w).pos_x, s(w).pos_y,'ko','markerfacecolor','k', 'color','red', "MarkerSize", 60);
        text(s(w).pos_x + 10, s(w).pos_y + 10, s(w).name);
    end
    if strcmp(name, "3C-62")
        a = plot(s(w).pos_x, s(w).pos_y,'ko','markerfacecolor','k', 'color','green', "MarkerSize", 60);
        text(s(w).pos_x + 10, s(w).pos_y + 10, s(w).name);
    end
    hold on
end

for i=1:length(ProcessedData.time(1:3686, 1))
    if i > 1
        p.MarkerSize = p.MarkerSize - abs(ProcessedData.hpass_accel(i, 1)) * 10000;
        d.MarkerSize = d.MarkerSize - abs(ProcessedData.hpass_accel(i, 2)) * 10000;
        a.MarkerSize = a.MarkerSize - abs(ProcessedData.hpass_accel(i, 3)) * 10000;
        drawnow;
    end
    pause(0.5);
    p.MarkerSize = default;
    d.MarkerSize = default;
    a.MarkerSize = default;
end

hold off




