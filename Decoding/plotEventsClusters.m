function plotEventsClusters(r, all, clusters, clust_probs, event_times)
    figure;
    subplot(3,5,[1:5]);
    hold on;
    for i = event_times
        line([i i], [1 2], 'Color', 'b');
    end
    ts_s = sort(clust_probs);
    needed = unique(clusters(ismember(clust_probs(clusters), ts_s(end-4:end))));
    size(needed)
    c = colormap(hsv(length(needed)));
    all_ts = {};
    for clust = 1 : length(needed)
         ts = FindClusterTimestamps(r, all(clusters == needed(clust), :));
         all_ts{end+1} = ts;
         plot(ts, ones(length(ts)) * clust_probs(needed(clust)) /max(clust_probs)/ 2, '.', 'Color', c(clust, :));
    end
    ylim([0, 2]);
    hold off;
    delta= 10;
    timestamps = 0 : delta : max(event_times)+delta;
    disp(max(timestamps));
    %disp(max()
    r1 = zeros(1, length(timestamps));
    k = 1;
    for idx = 1 : length(event_times)
       while timestamps(k) < event_times(idx)
          k = k + 1;
       end
       r1(k) = r1(k) + 1;
    end
    for i = 1 : length(all_ts)
        y = all_ts{i};
        timestamps = 0 : delta : max(y) + delta;
        r2 = zeros(1, length(timestamps));
        k = 1;
        for idx = 1 : length(y)
            while timestamps(k) < y(idx)
                k = k + 1;
            end
            r2(k) = r2(k) + 1;
        end
        subplot(3, 5, 5+i);
    cluster = all(clusters == needed(i), :);
    time_wind = 5;
    cluster = sum(cluster - 48, 1) / size(cluster, 1);
    matrix = [];
    cell_num = length(cluster) / time_wind;
    for j = 1 : cell_num
        matrix = [matrix ; cluster(j: cell_num : end)];
    end
    caxis([0, max(max(matrix))*100]);
    colormap(hot);
    image(matrix*100);
    
        subplot(3,5,10+i);
        plot(-200:200, xcorr(r2, r1, 200));
        
    end
end

