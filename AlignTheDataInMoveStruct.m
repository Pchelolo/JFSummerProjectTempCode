function [ spike_times, spike_electrodes, move_struct ] = AlignTheDataInMoveStruct( spike_struct, move_struct )
    spike_times = spike_struct.Timestamps;
    spike_electrodes = spike_struct.Electrode;
    
    %Aligning the data
    spike_first_ind = find(spike_electrodes == 144, 1, 'first');
    spike_first_time = spike_times(spike_first_ind);
    spike_times = spike_times(spike_first_ind:end);
    spike_electrodes = spike_electrodes(spike_first_ind:end);
    spike_times = spike_times - spike_first_time;
    spike_times = spike_times * 100 / 3;
    
    move_first_ind = find(move_struct.data.dig == 1, 1, 'first');
    move_first_time = move_struct.data.tStamps(move_first_ind);
    
    move_struct.data = chopStructFields(move_struct.data, move_first_ind : length(move_struct.data.tStamps));
    move_struct.data.tStamps = move_struct.data.tStamps - move_first_time;
end

