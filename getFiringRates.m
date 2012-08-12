function R = getFiringRates( spike_times, spike_electrodes, move_times)
    neurons = unique(spike_electrodes);
    R = zeros(length(neurons), length(move_times)+1);
    k=1;
    for i = 1 : length(spike_times)
        while (k <= length(move_times) && spike_times(i) >= move_times(k))
             k = k+1;
        end
        R(neurons == spike_electrodes(i), k) = R(neurons == spike_electrodes(i), k) + 1;
    end
    
  %  R = R / mean(diff(move_times)); %This is a real spike rate
    R = R(1:end, 1:end-1); 
end

