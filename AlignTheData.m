function [ spike_times, spike_electrodes, move_times, move_acc, move_gyr, move_pos ] = AlignTheData( spike_struct, move_struct, neurons )
    %%  Aligns the 30Hz data with NEV based on the digital signal in the CSV
    %   file and digital signal on electrode 144 in NEV file
    %   Spike_struct - NEV.Data
    %   Move_struct - CSV.data
    %   neurons - list of neurons needed to be extracted
    %   Returns:    spike_times - in microseconds
    %               spike_electrodes - number of an electrode for an event
    %               move_times - times of behaviour sample in microseconds
    %               move_acc, move_gyr, move_pos - data at time move_times

    spike_times = spike_struct.Timestamps;
    spike_electrodes = spike_struct.Electrode;

    move_times = move_struct.tStamps;
    move_acc = move_struct.accel;
    move_gyr = move_struct.gyro;
    move_pos = struct('x' , move_struct.posSmth.x, 'y', move_struct.posSmth.y);
    
    %Aligning the data
    spike_first_ind = find(spike_electrodes == 144);
    spike_first_time = spike_times(spike_first_ind(1));
    spike_times = spike_times(spike_first_ind:end);
    spike_electrodes = spike_electrodes(spike_first_ind:end);
    spike_times = spike_times - spike_first_time;
    spike_times = spike_times * 33.333333333333333333;
    
    needed = [];
    for i = 1:length(spike_electrodes)
        if(~isempty(find(neurons == spike_electrodes(i), 1)))
            needed = [needed, i];
        end
    end
    spike_times = spike_times(needed);
    spike_electrodes = spike_electrodes(needed);

    move_first_ind = find(move_struct.dig == 1);
    move_first_time = move_times(move_first_ind(1));
    
    move_times = move_times(move_first_ind: end);
    move_acc.x = move_acc.x(move_first_ind : end);
    move_acc.y = move_acc.y(move_first_ind : end);
    move_acc.z = move_acc.z(move_first_ind : end);
    move_acc.mag = move_acc.mag(move_first_ind : end);

    move_gyr.x = move_gyr.x(move_first_ind : end);
    move_gyr.y = move_gyr.y(move_first_ind : end);
    move_gyr.z = move_gyr.z(move_first_ind : end);
    move_gyr.mag = move_gyr.mag(move_first_ind : end);
    
    move_pos.x = move_pos.x(move_first_ind : end);
    move_pos.y = move_pos.y(move_first_ind : end);
     
    move_times = move_times - move_first_time;
    move_times = move_times * 1000;

end

