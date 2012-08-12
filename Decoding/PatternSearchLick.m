function result = PatternSearchLick(move_struct, NEV)
%%Settings for the algorithm
    time_window = 10; %number of time bins in a pattern
    diffTime = 30; %time bin length in milliseconds
    cutoff = 13; %distance threshold for clustering
%%Allocation and preparation
    result = struct('r', 0, 'rates', 0, 'linkage', 0, 'all', 0,  'clusters', 0, 'probs', 0, 'probs_rnd', 0, 'likehood', 0, 'clust_num', 0, 'beh', 0);
    f = figure;
    set(f,'Name','Lick Dataset Pattern Search Report','Color',[1 1 1]);
    addpath('C:\Users\loaner\Documents\JFSummerProject\Joshua code');
    addpath('C:\Users\loaner\Documents\JFSummerProject\');
    data = load('C:\Users\loaner\Documents\Data\ForPetr.mat');
    data = data.SessForPetr;

%Generating the firing rate for the data
%find the minimum and maximum timestamp for all the data
    minTime = min(arrayfun( @(x) min(x.ts), data.unit));
    maxTime = max(arrayfun( @(x) max(x.ts), data.unit));
    fprintf('Using time window %d milliseconds\n', diffTime);
    times = minTime : diffTime : maxTime + diffTime; %create the vector of timebins
    r_str = char(repmat(48, length(data.unit), length(times))); %Allocate the memory for the firing rate
    for cell = 1 : length(data.unit)
        cell_timestamps = data.unit(cell).ts;
        k = 1;
        for idx = 1 : length(cell_timestamps)
           while times(k) < cell_timestamps(idx)
               k = k + 1;
           end
           r_str(cell, k) = r_str(cell, k) + 1;
        end
    end
    r_str = r_str([10:13, 15], :);
    fprintf('Max number of spikes in a bin %d\n', max(max(r_str)) - 48);
    fprintf('Size of the data matrix %d %d\n', size(r_str));
    result.r = r_str;

% %   

    %we are goind to try to align the data based on NEV +
    %cross-correlations
%      [spike_times, spike_electrodes, move_struct] = AlignTheDataInMoveStruct(NEV.Data.Spikes, move_struct);
%      r = loadSortedGetRate(move_struct.data.tStamps * 1000);
%      r1 = getFiringRates(spike_times, spike_electrodes, move_struct.data.tStamps*1000);
%      q = xcorr(r(2,:), r1(9,:), 1000);
%      delay = find(q == max(q), 1, 'first') - 1000;
%      disp(delay);
%        timeBinsDefault = mean(diff(move_struct.data.tStamps))*1000;
%        timeBins = timeBinsDefault;
%     % Chop the move_data so that the size was equal to r
%      r = loadSortedGetRate(min(move_struct.data.tStamps*1000):timeBins:max(move_struct.data.tStamps*1000));
%      r = r(:, floor(delay*timeBinsDefault/timeBins):end);
%      
%      move_struct.data = chopStructFields(move_struct.data, 1 : length(move_struct.data.tStamps) - delay + 1);
% 
%     r_str = char(r+48);
%     fprintf('Max number of spikes in a bin %d\n', max(max(r_str)) - 48);
%     fprintf('Size of the data matrix %d %d\n', size(r_str));
%     fprintf('Using time window %d milliseconds\n', mean(diff(move_struct.data.tStamps*1000)));
   
    result.r = r_str;
    result.beh = move_struct;

%%Find all existing patterns and compute their frequency
     fprintf('Computing real probabilities of all patterns\n');
     import java.util.*;
     rates = HashMap; %use HashMap to store patterns to same memory
     for i = 1 : size(r_str, 2) - time_window
         %Reshape the pattern matrix to a string to be able to use it as a
         %key for the hashmap
         str_pattern = reshape( r_str(:, i:i+time_window-1), 1, size(r_str, 1)*time_window );
         %Test whether we already have this pattern in a hashmap
         from_rates = rates.get(str_pattern);
         if ~isempty(from_rates)
            %if yes - update frequency
            rates.put(str_pattern, from_rates + 1);
         else
            %if no - add the pattern
            rates.put(str_pattern, 1);
         end
     end
    result.rates =  rates;
    
%%Search for clusters
    fprintf('Searching for clusters\n');
    all_patterns = rates.keySet().toArray();
    
    for_dist = zeros(length(all_patterns), length(all_patterns(1)));
    for i = 1 : length(all_patterns)
       row =  arrayfun( @(x) log(x-48+1) , all_patterns(i));
       for_dist(i, :) =  row; 
    end
    

    Y = linkage(for_dist, 'ward', 'euclidean', 'savememory', 'on'); %cluster data using a average linkage algorithm
    T = cluster(Y, 'cutoff', cutoff, 'criterion', 'distance'); 
    fprintf('Found %d clusters of %d patterns\n', max(T), length(all_patterns));
    result.linkage = Y;
    result.clusters = T;
    

%     fprintf('Estimating theoretical and real cluster probabilities\n');
%     probs = zeros(1, max(T)); %Real probabilities of each cluster
%     probs_rnd = zeros(1, max(T)); %Estimated probabilities of each cluster
%     clust_num = zeros(1, max(T)); %number of elements in each cluster
%     log_likelihood = zeros(1, max(T)); %likelihood for each cluster
%     all_patterns = char(all_patterns); %convert array of java.String to a martix of char
%     result.all = all_patterns;
%     for cluster_ind = 1 : max(T) %For each cluster
%        if mod(cluster_ind, 100) == 0
%            disp(cluster_ind / max(T));
%        end
%        cluster_addr = find(T == cluster_ind); %find indexes of all patterns in the cluster
%        clust_num(cluster_ind) = length(cluster_addr); %get the number of patterns in a cluster
%        for pattern_ind = cluster_addr' %for each pattern in a cluster
%            pattern = all_patterns(pattern_ind, :); 
%            probs(cluster_ind) = probs(cluster_ind) + rates.get(pattern) / size(r_str, 2); %sum the frequences of all patterns to obtain a cluster frequency
%            curr_prob = 1;%Probability estimate of each pattern
%            for cell = 1 : size(r_str, 1) %for each cell
%                 pattern_str_cell = pattern(cell : size(r_str, 1) : end); %get a pattern of the activity of this cell
%                 if time_window > 2
%                     cell_pattern_prob = length(strfind(r_str(cell, :), pattern_str_cell(1:end-1))) ... %and estimate a probability of obtaining current pattern from this cell
%                                         * length(strfind(r_str(cell, :), pattern_str_cell(2:end))) ...
%                                         / length(strfind(r_str(cell, :), pattern_str_cell(2:end-1))) / size(r_str, 2);
%                 elseif time_window == 1
%                     cell_pattern_prob = length(strfind(r_str(cell, :), pattern_str_cell)) / size(r_str, 2); 
%                 end
%                 curr_prob = curr_prob * cell_pattern_prob ; %And multiply for all the cells    
%            end
%            probs_rnd(cluster_ind) = probs_rnd(cluster_ind) + curr_prob; %Sum the estimates to get a cluster probability estimate    
%        end   
%        log_likelihood(cluster_ind) =  log( probs(cluster_ind) / probs_rnd(cluster_ind)); %calculate to likelihood ratio for each cluster
%     end
%     %Set the result values to return them
%     result.probs = probs;
%     result.probs_rnd = probs_rnd;
%     result.clust_num = clust_num;
%     result.likehood = log_likelihood;
    
    fprintf('Estimating theoretical and real cluster probabilities\n');
    probs = zeros(1, max(T)); %Real probabilities of each cluster
    probs_rnd = zeros(1, max(T)); %Estimated probabilities of each cluster
    clust_num = zeros(1, max(T)); %number of elements in each cluster
    log_likelihood = zeros(1, max(T)); %likelihood for each cluster
    all_patterns = char(all_patterns); %convert array of java.String to a martix of char
    result.all = all_patterns;
    mean_rates = sqrt(mean(r_str - 48, 2));
    var_rates = std(sqrt(r_str-48), 0, 2);
    for cluster_ind = 1 : max(T) %For each cluster
       if mod(cluster_ind, 100) == 0
           disp(cluster_ind / max(T));
       end
       cluster_addr = find(T == cluster_ind); %find indexes of all patterns in the cluster
       clust_num(cluster_ind) = length(cluster_addr); %get the number of patterns in a cluster
       for pattern_ind = cluster_addr' %for each pattern in a cluster
           pattern = all_patterns(pattern_ind, :); 
           probs(cluster_ind) = probs(cluster_ind) + rates.get(pattern) / size(r_str, 2); %sum the frequences of all patterns to obtain a cluster frequency
       end
       cluster_patterns = all_patterns(cluster_addr, :) - 48;
       cur_prob = 1;
       for idx = 1 : size(cluster_patterns, 2)
           mean_elem = sqrt(mean(cluster_patterns(:, idx)));
           var_elem = std(sqrt(cluster_patterns(:,idx)))+0.01;
           mean_theory = mean_rates(mod(idx-1,size(r_str, 1))+1);
           var_theory = var_rates(mod(idx-1,size(r_str, 1))+1);
           cur_prob = cur_prob * integral(@(x) min(normpdf(x, mean_elem, var_elem), normpdf(x, mean_theory, var_theory)), -100, 100);
       end
       probs_rnd(cluster_ind) = cur_prob;
       log_likelihood(cluster_ind) =  log( probs(cluster_ind) / probs_rnd(cluster_ind)); %calculate to likelihood ratio for each cluster
    end
    %Set the result values to return them
    result.probs = probs;
    result.probs_rnd = probs_rnd;
    result.clust_num = clust_num;
    result.likehood = log_likelihood;
    
%%plotting the results
    subplot(1, 2, 1);
    loglog(probs, probs_rnd, '.', probs, probs, 'r');
    ylabel('Estimated probability');
    xlabel('Real probability');
    subplot(1,2,2);
   	semilogy(log_likelihood, probs, '.');
    ylabel('Real probability');
    xlabel('Likelihood ratio');
end