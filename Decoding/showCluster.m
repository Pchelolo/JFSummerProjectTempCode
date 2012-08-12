function showCluster(all, likelihood, clusters, probs, time_wind)
    f = figure;
    set(f, 'Color', 'w');
   % likelihood_new = abs(likelihood);
   % likelihood_new = sort(likelihood);
    %likelihood_new = likelihood_new(end-25 : end);
   % needed = find(ismember(abs(likelihood), likelihood_new)==1);
    needed = [13];
    for j = 1 : 1
     %   subplot(2,1,j);
        cluster = all(clusters == needed(j), :);
        cluster = sum(cluster - 48, 1) / size(cluster, 1);
        matrix = [];
        cell_num = length(cluster) / time_wind;
        for i = 1 : cell_num
            matrix = [matrix ; cluster(i: cell_num : end)];
        end
       disp(matrix);
        colormap(gray);
        image(matrix*10);
        title(sprintf('Cn=%d Pr=%f L=%f', needed(j), probs(needed(j)), likelihood(needed(j))));
    end
end

