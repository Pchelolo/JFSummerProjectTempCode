function res = PatternsSearch(move_struct, NEV) 
    res = 0;
    f = figure;
    set(f,'Name','Maximum Entropy Report','Color',[1 1 1]);
    addpath('C:\Users\loaner\Documents\JFSummerProject\Joshua code');
    addpath('C:\Users\loaner\Documents\JFSummerProject\');
    
    time_window = 3;
    
    %we are goind to try to align the data based on NEV +
    %cross-correlations
     [spike_times, spike_electrodes, move_struct] = AlignTheDataInMoveStruct(NEV.Data.Spikes, move_struct);
     
     max_rate = 2;
     m_rate_num = 1000;
     times = move_struct.data.tStamps * 1000;
     lag = 1000;
     
     while max_rate > 1 && m_rate_num > 10
        r = loadSortedGetRate(times);
        r1 = getFiringRates(spike_times, spike_electrodes, times);
        q = xcorr(r(end,:), r1(15,:), lag);
        delay = find(q == max(q), 1, 'first') - lag;
        r = r(:, delay : end);
        max_rate = max(max(r));
        times = min(times) : ceil(mean(diff(times)) / 2) : max(times);
        lag = lag * 2;
        m_rate_num = length(find(r == max_rate));
     end
     r(r > 1) = 1;
     
     r_str = [];
     for i = 1 : size(r, 1)
         r_str = [r_str; regexprep(mat2str(r(i,:)), '[ \[\]]', '')];
     end
     
     
     
     %%Start computing probs
     import java.util.*;
     rates = HashMap;
     for i = 1 : size(r, 2) - time_window
         pattern = r(:, i:i+time_window-1);
         str_pattern = mat2str(pattern);
         from_rates = rates.get(str_pattern);
         if length(from_rates) ~= 0
            rates.put(str_pattern, from_rates + 1);
         else
             rates.put(str_pattern, 1);
         end
     end

    %%Search for clusters and merge them
    all_patterns = rates.keySet().toArray();
    for_dist = [];
    for i = 1 : length(all_patterns)
       for_dist = [for_dist; str2num(regexprep(all_patterns(i), '[\;]', ','))]; 
    end
    
    Y = linkage(for_dist, 'average', 'hamming');
    T = cluster(Y, 'cutoff', 2);

    probs = zeros(1, max(T));
    probs_rnd = zeros(1, max(T));
    clust_num = zeros(1, max(T));
    for cluster_ind = 1 : max(T)
       pattern_cluster = [];
       clust_num(cluster_ind) = length(find(T == cluster_ind));
       if length(find(T == cluster_ind)) > 1
           q = all_patterns(T == cluster_ind);
           for i = 1 : length(q)
              patterns_cluster = [pattern_cluster; q(i)]; 
           end
       else
            patterns_cluster = all_patterns(T == cluster_ind);
       end
       for pattern_ind = 1 : size(patterns_cluster, 1)
           pattern = patterns_cluster(pattern_ind, :);
           probs(cluster_ind) = probs(cluster_ind) + rates.get(pattern) / size(r, 2);
           pattern_arr = str2num(pattern);
           curr_prob = 1;
           for cell = 1 : size(r, 1)
                pattern_str_cell = regexprep(mat2str(pattern_arr(cell,:)), '[ \[\]]', '');
                cell_pattern_prob = length(strfind(r_str(cell, :), pattern_str_cell(1:end-1))) * length(strfind(r_str(cell, :), pattern_str_cell(2:end))) ...
                                        / length(strfind(r_str(cell, :), pattern_str_cell(2:end-1)));
                curr_prob = curr_prob * (cell_pattern_prob / size(r, 2));          
           end
           probs_rnd(cluster_ind) = probs_rnd(cluster_ind) + curr_prob;
       end   
    end
    
    res = {Y, T, probs, probs_rnd, clust_num};
    loglog(probs, probs_rnd, '.', probs, probs, 'r', 'MarkerSize', 3);
    ylabel('Approximated probability');
    xlabel('Real probability');
    %legend('real', 'ideal', 'treshold');
end

function  num = toNumber(pattern)
    num = 0;
    for i = 1 : size(pattern, 1)
        for j = 1 : size(pattern, 2)
            num = num*2 + pattern(i, j);
        end
    end
    num;
end

%function distfun