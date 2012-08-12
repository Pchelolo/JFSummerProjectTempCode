function PlotDataCorrelations( move_acc, move_gyr );
    data = [move_gyr.x; move_gyr.mag; move_gyr.z; move_gyr.mag];
    names = {'Gyr_x', 'Gyr_y', 'Gyr_z', 'Gyr_m'};
    maxlag = 2000;
    fig = figure;
    set(fig,'Name','Data Correlations','Color',[1 1 1]);
    s = size(data);
    s = s(1);
    for i =1 : s
        for j = 1 : s
            if(i<=j)
                subplot(s, s, (i-1)*s + j);
                corr = xcorr(data(i,:), data(j, :), maxlag);
                plot((-maxlag : 10 : maxlag) / 10, corr(1:10:end));
                title(strcat(names{i}, '|', names{j}));
                xlabel('Time shift, millisecond');
                ylabel('Correlation');
                grid on;
            end
        end
    end
end

