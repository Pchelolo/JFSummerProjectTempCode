function sta = STA( spike_times, spike_electrodes, data, data_times, len )
    neurons = unique(spike_electrodes);
    sta = zeros(length(neurons), len*2+1);
    for i = 1 : length(spike_times)
       data_ind = find(data_times >= spike_times(i));
       if(~isempty(data_ind))
        data_ind = data_ind(1);
         if(data_ind + len < length(data) && data_ind - len > 0 )
             sta(neurons == spike_electrodes(i), :) = sta(neurons == spike_electrodes(i), :) + data(data_ind-len : data_ind+len);
         end
       end
    end
    for e = 1 : length(neurons)
        sta(e, 1:end) = sta(e, 1:end) / length(find(spike_electrodes == neurons(e)));
    end
end

