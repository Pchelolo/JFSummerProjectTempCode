function res = FindPatterns(move_struct, NEV)
    f = figure;
    set(f,'Name','Random Forest','Color',[1 1 1]);
    addpath('C:\Users\loaner\Documents\JFSummerProject\Joshua code');
    addpath('C:\Users\loaner\Documents\JFSummerProject\');
    %we are goind to try to align the data based on NEV +
    %cross-correlations
     [spike_times, spike_electrodes, move_struct] = AlignTheDataInMoveStruct(NEV.Data.Spikes, move_struct);
     r = loadSortedGetRate(move_struct.data.tStamps * 1000);
     r1 = getFiringRates(spike_times, spike_electrodes, move_struct.data.tStamps*1000);
     q = xcorr(r(end,:), r1(15,:), 1000);
     delay = find(q == max(q), 1, 'first') - 1000;
     disp(delay);
     
     r = r(:, delay : end);
     
     %Chop the move_data so that the size was equal to r
     move_struct.data = chopStructFields(move_struct.data, 1 : length(move_struct.data.tStamps) - delay + 1);

     Y_all = [move_struct.data.accel.x, move_struct.data.accel.y,move_struct.data.accel.z,move_struct.data.accel.mag, ...
         move_struct.data.gyro.x, move_struct.data.gyro.y, move_struct.data.gyro.z, move_struct.data.gyro.mag,...
         move_struct.data.posSmth.x, move_struct.data.posSmth.y,]';
     Y = Y_all(4, 10:5000)';
     X = [];
     
     
     for lag = 1:10
        X = [X ; r(:, lag:5000-10+lag)];
     end
     X = X';
  
     res = TreeBagger(50, X, Y, 'method','r','oobpred','on', 'oobvarimp', 'on','minleaf',5);
     
       subplot(2,4,5);
    plot(kfoldLost(res, 'mode','cumulative'));
     
       Y = Y_all(4, 5010:10000)';
     X = [];
     
     
     for lag = 1:10
        X = [X ; r(:, lag+5000:10000-10+lag)];
     end
     X = X';
     
        Y1 = res.predict(X);
        
        disp(size(Y1));
        subplot(2,4,[1 2 3]);
        hold on;
            plot(Y);
            plot(Y1, 'r');
        hold off;
       return;
        subplot(2,4,4);
        plot(Y, Y1, '.b', 'MarkerSize', 1);
         Mean_real = mean( Y );
    sum_up = 0;
    sum_down = 0;
    for i = 1 : length(Y)
        if Y(i) ~= 0
            sum_down = sum_down + Y(i)*log(Y(i) / Mean_real);
            sum_up = sum_up + Y(i)*log(Y(i) / Y1(i)) + Y1(i) - Y(i);
        else
            sum_up  = sum_up + Y1(i);
        end
    end
    rSquared = 1 - sum_up / sum_down;
    fprintf('R squared %f \n', rSquared);
    
  
    xlabel('Number of trees');
    ylabel('Test error');
    subplot(2,4,6)
    error = res.OOBPermutedVarDeltaError
    bar(error);
    xlabel('Feature Number');
    ylabel('Out-Of-Bag Feature Importance');
    idxvar = find(error > 0.2);
    disp(idxvar);
   
    X = X(:, idxvar);
    res = TreeBagger(50, X, Y, 'method','r','oobpred','on', 'oobvarimp', 'on','minleaf',5);
     
    Y1 = res.predict(X);
    disp(size(Y1));
    subplot(2,4, 8);
     plot(oobError(res, 'mode','cumulative'));
     
       subplot(2,4,7);
       error = arrayfun(@(x) ceil(x*100), error);
       error = error - min(error);
       
       m = [];
       for j = 0 : 9
            m = [m; error((1:8) + j*8)];
       end
       
       colormap(hot);
       image(m);
end

