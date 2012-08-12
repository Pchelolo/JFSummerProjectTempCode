function t_stamps = FindClusterTimestamps(r, cluster)
   time_window = 1;
   diffTime = 300;
    r_str = r;
     
   t_stamps = [];
   disp(cluster);

   for i = 1 : size(r_str, 2) - time_window
        if ~isempty(find(ismember(reshape( r_str(:, i:i+time_window-1), 1, size(r_str, 1)*time_window ), cluster, 'rows') == 1, 1))
            t_stamps = [t_stamps, i];
        end
   end
   t_stamps = t_stamps * diffTime;
end

