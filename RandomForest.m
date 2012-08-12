function result = RandomForest(move_struct, NEV)
    result = struct('r', 0, 'move_dat', 0, 'Y', 0, 'Y1', 0);
    figure;
    tic
    %we are goind to try to align the data based on NEV +
    %cross-correlations
     [spike_times, spike_electrodes, move_struct] = AlignTheDataInMoveStruct(NEV.Data.Spikes, move_struct);
     r = loadSortedGetRate(move_struct.data.tStamps * 1000);
     r1 = getFiringRates(spike_times, spike_electrodes, move_struct.data.tStamps*1000);
     q = xcorr(r(2,:), r1(9,:), 1000);
     delay = find(q == max(q), 1, 'first') - 1000;
     disp(delay);
     r = r(:, delay:end);
     %move_struct.data = chopStructFields(move_struct.data, 1 : length(move_struct.data.tStamps) - delay + 1);
     fprintf('Max number of spikes in a bin %d\n', max(max(r)));
     fprintf('Size of the data matrix %d %d\n', size(r));
     fprintf('Using time window %f milliseconds\n', mean(diff(move_struct.data.tStamps)));
     result.r = r;
     result.move_dat = move_struct;
     return;
     
    % [pc, score, latent, tsquare] = princomp(r');
    % cumsum(latent)./sum(latent)
     
     
     Y = MakeSmoothWithGaussian( r(6,1:end), 10);
     X = [ move_struct.data.accel.x, move_struct.data.accel.y,move_struct.data.accel.z,move_struct.data.accel.mag, ...
           move_struct.data.gyro.x, move_struct.data.gyro.y, move_struct.data.gyro.z, move_struct.data.gyro.mag,...
           move_struct.data.posSmth.x, move_struct.data.posSmth.y];
     X = MakeSmoothWithGaussian(X', 10);

%     leaf = [1 5 10 20 50 100];
%     col = 'rgbcmy';
%     figure(1);
%     hold on;
%     for i=1:length(leaf)
%         b = TreeBagger(50,X',Y','method','r','oobpred','on','minleaf',leaf(i));
%         plot(oobError(b),col(i));
%     end
%     xlabel('Number of Grown Trees');
%     ylabel('Mean Squared Error');
%     legend({'1' '5' '10' '20' '50' '100'},'Location','NorthEast');
%     hold off;
     

    res = TreeBagger(100, X(:, 1:20000)', Y(1:20000)', 'method','r','oobpred','on','minleaf',5);
    Y1 = res.predict(X(:,20000:end)');
%     res = TreeBagger(100, X(:, 1:20000)', Y(10001:30000)', 'method','r','oobpred','on','minleaf',5);
%     Y2 = res.predict(X(:,20000:end)');
    subplot(3,1,1);
    hold on;
       plot((20101:length(Y)-100)/33.3333, Y(20101:end-100));
       plot(((101:length(Y1)-100)+20000)/33.3333, Y1(101:end-100),  'r');
%        plot(((1:length(Y1))+20000)/33.3333, Y2, 'g');
    hold off; 
    xlim([min(((1:length(Y1))+20000)/33.3333), max(((1:length(Y1))+20000)/33.3333)]);
%     Y = Y(20000:end)';
%     subplot(2,1,2);
%     sqerr = MakeSmoothWithGaussian(arrayfun(@(x, y) (x-y)^2, Y, Y1), 50);
%     plot(((1:length(Y1))+20000)/33.3333, sqerr);

    Y = Y(20000:end)';
    subplot(3,1,2);
    corr = arrayfun(@(t) max(xcorr(Y(t-100:t+100)-mean(Y(t-100:t+100)), Y1(t-100:t+100)-mean(Y1(t-100:t+100)), 20))/mean(Y(t-100:t+100))/mean(Y1(t-100:t+100)), 101:length(Y)-100);
    plot(((101:length(Y)-100)+20000)/33.3333, corr);
    xlim([min(((1:length(Y1))+20000)/33.3333), max(((1:length(Y1))+20000)/33.3333)]);
    result.Y = Y;
    result.Y1 = Y1;
    subplot(3,1,3);
    plot(((101:length( move_struct.data.accel.mag(20101:end-100))-101)+20000)/33.3333, move_struct.data.accel.mag(20101:end-100));
     xlim([min(((1:length(Y1))+20000)/33.3333), max(((1:length(Y1))+20000)/33.3333)]);
     toc
end

