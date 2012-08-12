function result = plotLikehood_Events(r, all, clusters, likehood, probs)
    result = struct('likelihood', 0, 'cluster', 0, 'probs', 0);
    time_window = 3;
    f = figure;
    set(f, 'Color', 'w');
    likehood_time = zeros(1, size(r,2));
    cluster_time = zeros(1, size(r,2));
    prob_time = zeros(1, size(r,2));
    for i = 1 : size(r, 2) - time_window
       str_pattern = reshape( r(:, i:i+time_window-1), 1, size(r, 1)*time_window );
       [~, idx] = ismember(str_pattern, all, 'rows');
       if mod(i, 1000) == 0
           disp(i/size(r,2));
       end
       likehood_time(i) = likehood(clusters(idx));
       cluster_time(i) = clusters(idx);
       prob_time(i) = probs(clusters(idx));
    end
    subplot(2, 1, 1);
    plot((1:length(likehood_time)) * 10, likehood_time, 'b');
    xlabel('Time');
    ylabel('Likelihood ratio');
    xlim([0, length(likehood_time) * 10]);
    subplot(2, 1, 2);
    plot((1:length(likehood_time)) * 10, likehood_time, 'b');
    xlim([0, length(likehood_time) * 10]);
    xlabel('Time');
    ylabel('Likelihood ratio');
    result.likelihood = likehood_time;
    result.cluster = cluster_time;
    result.probs = prob_time;
end

