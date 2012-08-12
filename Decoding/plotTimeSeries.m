function plotTimeSeries(beh, ts1)
f = figure;
set(f, 'Color', 'w');
hold on;
for i = 1 : length(ts1)
    line([ts1(i) ts1(i)], [0,1.1*max(beh)], 'Color', 'b');
end
plot(beh, 'r');
xlabel('Time');
ylabel('Accelleration');
hold off;
end

