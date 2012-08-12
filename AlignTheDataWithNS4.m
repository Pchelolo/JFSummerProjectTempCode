function [ spike_times, spike_electrodes, move_times, move_acc, move_gyr ] = AlignTheDataWithNS4( NEV, NS4,  slice, neurons )
    spikes_start_micros = str2num(NEV.MetaTags.DateTime(end-2:end)) * 1000;
    data_start_micros = NS4.MetaTags.CreateDateTime(end) * 1000;
    
    %suppose data time is larger, add generality later
    time_delta = data_start_micros - spikes_start_micros; 
    
    spike_times = NEV.Data.Spikes.Timestamps * 33.3333 ; %now spike time in microseconds
    first_spike = find(spike_times >= time_delta, 1, 'first');
    spike_times = spike_times(first_spike: end) - time_delta;
    spike_electrodes = NEV.Data.Spikes.Electrode(first_spike: end);
    
    %time_delta = ceil(spike_times(first_spike) / 1000 * 30);
    %NS5dat = NS5.Data(:, time_delta : end);
    
    move_acc = struct('x', NS4.Data(1, 1:end), 'y', NS4.Data(2, 1:end), 'z', NS4.Data(3, 1:end), 'mag', arrayfun(@(x, y, z) sqrt(x^2 + y^2 + z^2), NS4.Data(1, 1:end),NS4.Data(2, 1:end),NS4.Data(3, 1:end)));
    move_gyr = struct('x', NS4.Data(4, 1:end), 'y', NS4.Data(5, 1:end), 'z', NS4.Data(6, 1:end), 'mag', arrayfun(@(x, y, z) sqrt(x^2 + y^2 + z^2), NS4.Data(4, 1:end),NS4.Data(5, 1:end),NS4.Data(6, 1:end)));
    move_times = (0:100:100*length(move_acc.x)-1)';%in microseconds
    
    %chop the data by move_time
    last_spike = find(spike_times > move_times(end), 1, 'last');
    spike_electrodes = spike_electrodes(1:last_spike);
    spike_times = spike_times(1:last_spike);
    
    %chop for 16 electrodes
    new_s_t = [];
    new_s_e = [];
    for i = 1:length(spike_times)
        if(~isempty(find( spike_electrodes(i) == neurons, 1)))
            new_s_t = [new_s_t ; spike_times(i)];
            new_s_e = [new_s_e ; spike_electrodes(i)];
        end
    end
    spike_times = new_s_t;
    spike_electrodes = new_s_e;
    
    if(slice ~= 0)
       spike_times_start = find(spike_times >= move_times(slice), 1, 'first');
       spike_times = spike_times(spike_times_start : end);
       spike_electrodes = spike_electrodes(spike_times_start : end);
       
       move_times = move_times(slice : end);
       move_acc.x = move_acc.x(slice : end);
       move_acc.y = move_acc.y(slice : end);
       move_acc.z = move_acc.z(slice : end);
       move_acc.mag = move_acc.mag(slice : end);
       
       move_gyr.x = move_gyr.x(slice : end);
       move_gyr.y = move_gyr.y(slice : end);
       move_gyr.z = move_gyr.z(slice : end);
       move_gyr.mag = move_gyr.mag(slice : end);
  
    end
end

