function PlotWithSpikeSorting( NS4, NS5, data30Hz )
    spike_times = SpikeSorting(NS5.Data) * 100 / 3;
    move_acc = struct('x', NS4.Data(1, 1:100:end), 'y', NS4.Data(2, 1:100:end), 'z', NS4.Data(3, 1:100:end), 'mag', arrayfun(@(x, y, z) sqrt(x^2 + y^2 + z^2), NS4.Data(1, 1:100:end),NS4.Data(2, 1:100:end),NS4.Data(3, 1:100:end)));
    move_gyr = struct('x', NS4.Data(4, 1:100:end), 'y', NS4.Data(5, 1:100:end), 'z', NS4.Data(6, 1:100:end), 'mag', arrayfun(@(x, y, z) sqrt(x^2 + y^2 + z^2), NS4.Data(4, 1:100:end),NS4.Data(5, 1:100:end),NS4.Data(6, 1:100:end)));
    move_times = (0:10000:10000*length(move_acc.x)-1)';%in microseconds
    disp(spike_times(end));
    disp(move_times(end));
    r = getFiringRates(spike_times, ones(1, length(spike_times)), move_times);
    r = MakeSmoothWithGaussian(r, 5);
    [fig, res, optimalLag] = TryGLM([move_acc.y; move_acc.mag; move_gyr.z;], r);
    set(fig,'Name',sprintf('GLM with spike sorting for neuron %d', 8));
    dat = move_gyr.z;
    p = polyfit(r, dat, 1);
    figure;
    hold on;
    plot(r, dat, '.r', 'MarkerSize', 1);
    plot(r, polyval(p, r), 'b');
    hold off;
    figure;
    hold on;
       plot(dat(1:10000));
       plot(polyval(p, r(1:10000)), 'r');
    hold off;
end

