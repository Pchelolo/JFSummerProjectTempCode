function STA_dat = STA_Timegaps( spike_times, time_gap, stimulus, stimulus_times )
    AV = zeros(time_gap*2);
    for s_time = spike_times
        for i = 1 : length(AV)
            AV(i) = AV(i) + spline(stimulus_times, stimulus, s_time - time_gap + i);
        end
    end
    for i = 1 : length(AV)
        AV(i) = AV(i) / length(spike_times);
    end
    STA_dat = AV(i);
end

