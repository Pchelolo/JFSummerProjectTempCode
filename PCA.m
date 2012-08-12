function reult = PCA(move_struct, NEV)
    result = 0;
    figure;

     [spike_times, spike_electrodes, move_struct] = AlignTheDataInMoveStruct(NEV.Data.Spikes, move_struct);
     r = loadSortedGetRate(move_struct.data.tStamps * 1000);
     r1 = getFiringRates(spike_times, spike_electrodes, move_struct.data.tStamps*1000);
     q = xcorr(r(2,:), r1(9,:), 1000);
     delay = find(q == max(q), 1, 'first') - 1000;
     disp(delay);
     r = r(:, delay:end);
     move_struct.data = chopStructFields(move_struct.data, 1 : length(move_struct.data.tStamps) - delay + 1);
     fprintf('Max number of spikes in a bin %d\n', max(max(r)));
     fprintf('Size of the data matrix %d %d\n', size(r));
     fprintf('Using time window %f milliseconds\n', mean(diff(move_struct.data.tStamps)));
     result.r = r;
     result.move_dat = move_struct;
     
     Y = MakeSmoothWithGaussian( r(2, :), 10);
     X = [ move_struct.data.accel.x, move_struct.data.accel.y,move_struct.data.accel.z,move_struct.data.accel.mag, ...
            move_struct.data.gyro.x, move_struct.data.gyro.y, move_struct.data.gyro.z, move_struct.data.gyro.mag,...
            move_struct.data.posSmth.x, move_struct.data.posSmth.y]';
     Y = zscore(Y(1:30000))';
     X = zscore(MakeSmoothWithGaussian( X(:, 1:30000), 10)';
     
     
     
end

