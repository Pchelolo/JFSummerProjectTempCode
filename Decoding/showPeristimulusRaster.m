function showPeristimulusRaster(ts, r)
    lag = -100:100;
    av = [];
    ts = ceil(ts);
    while ts(1) <= -lag(1)
        ts = ts(2:end);
    end
    while ts(end) >= length(r) - lag(end)
        ts = ts(1:end-1);
    end  
    for t = 1:length(ts)
        av = [av; r(ts(t)+lag)];
    end
    f = figure;
    set(f, 'Color', 'w');
    [~, perm] = sort(mean(av(:, 1:-lag(1)), 2));
    size(perm)
    image(ceil(av(perm,:) * 50 / max(max(av))));
    colormap(hot);
end

