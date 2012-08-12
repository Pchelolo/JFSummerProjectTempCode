function plotAnalogData( data_struct,  time, slice )
    time = time(slice) / 100;
    data_struct.x = data_struct.x(slice);
    data_struct.y = data_struct.y(slice);
    data_struct.z = data_struct.z(slice);
    data_struct.mag = data_struct.mag(slice);
    hold on;
    dif = max([max(data_struct.x) max(data_struct.y) max(data_struct.z) max(data_struct.mag)]);
    plot(time(1:10:end), data_struct.x(1:10:end)  - mean(data_struct.x));
    plot(time(1:10:end), data_struct.y(1:10:end) + dif  - mean(data_struct.y));
    plot(time(1:10:end), data_struct.z(1:10:end) + dif*2  - mean(data_struct.z));
    plot(time(1:10:end), data_struct.mag(1:10:end) + dif*3 - mean(data_struct.mag), 'r');
    plot(time(1:10:end), dif*3);
    plot(time(1:10:end), dif*2);
    plot(time(1:10:end), dif);
    plot(time(1:10:end), 0);
    hold off;
    xlabel('Time, milliseconds');
    xlim([min(time), max(time)]);
    
end

