function res = AnalizeProgressions( move_struct, NEV )
    addpath('C:\Users\loaner\Documents\JFSummerProject\Joshua code');
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

     X = [move_struct.data.accel.x, move_struct.data.accel.y,move_struct.data.accel.z,move_struct.data.accel.mag, ...
         move_struct.data.gyro.x, move_struct.data.gyro.y, move_struct.data.gyro.z, move_struct.data.gyro.mag,...
         move_struct.data.posSmth.x, move_struct.data.posSmth.y,]';
     
     res = {X, delay};
     return;
     X = X(:, 1:20000);
     Y = MakeSmoothWithGaussian( r(end, 1:20000), 30);
    % res = fitensemble(X', Y', 'LSBoost', 50, 'Tree');
    
    leaf = [1 5 10 20 50 100];
col = 'rgbcmy';
figure(1);
for i=1:length(leaf)
    b = TreeBagger(50,X',Y','method','r','oobpred','on','minleaf',leaf(i));
    plot(oobError(b),col(i));
    hold on;
end
xlabel('Number of Grown Trees');
ylabel('Mean Squared Error');
legend({'1' '5' '10' '20' '50' '100'},'Location','NorthEast');
hold off;
return;
    res = TreeBagger(50, X', Y', 'method','r','oobpred','on','minleaf',5);
        Y1 = res.predict(X');
        disp(size(Y1));
        subplot(2,4,[1 2 3]);
        hold on;
            plot(Y);
            plot(Y1, 'r');
        hold off;
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
    
    [b, dev, stat] = glmfit(X', Y', 'poisson', 'estdisp', 'on');
    Y2 = glmval(b, X', 'log');
    subplot(2,4,[5 6 7]);
    hold on; plot(Y);
    plot(Y2, 'r');
    hold off;
    subplot(2,4,8);
    plot(Y, Y2, '.b', 'MarkerSize', 1);
        
     sum_up = 0;
    sum_down = 0;
    for i = 1 : length(Y)
        if Y(i) ~= 0
            sum_down = sum_down + Y(i)*log(Y(i) / Mean_real);
            sum_up = sum_up + Y(i)*log(Y(i) / Y2(i)) + Y2(i) - Y(i);
        else
            sum_up  = sum_up + Y2(i);
        end
    end
    rSquared = 1 - sum_up / sum_down;
    fprintf('R squared %f \n', rSquared);
    
     return;
     progs = TNC_OpenFieldReport(move_struct, 1, [1, length(move_struct.data.accel.x)]);
     
     res = progs;
     starts = [];
     for i = 1 : size(progs.progStarts, 1)
         currStart = progs.progStarts(i,4);
         if progs.progLengths.disp(i) > 80
             starts = [starts, currStart];
         end
     end
     
     r = r(end, :);
     r = MakeSmoothWithGaussian(r, 5);
     velocity = arrayfun(@(x,y) sqrt(x^2 + y^2), diff(move_struct.data.posSmth.x), diff(move_struct.data.posSmth.y));
     figure;
     hold on;
     plot(MakeSmoothWithGaussian(velocity, 10));
     for i = 1 : length(starts)
        line([starts(i), starts(i)], [-1, 1], 'Color', 'r'); 
     end
     hold off;
     
     vars = [move_struct.data.accel.x(2:end),move_struct.data.accel.y(2:end),move_struct.data.accel.z(2:end),move_struct.data.accel.mag(2:end), ...
            move_struct.data.gyro.x(2:end), move_struct.data.gyro.y(2:end), move_struct.data.gyro.z(2:end),move_struct.data.gyro.mag(2:end),...
            ];
     TryGLM(vars', r(2:end), -10:10, move_struct.data.tStamps(starts));
     
     
     

     figure;
     hold on;
     for j = 1 : 30 : length(r)
         if r(j) > 0
            line([j, j], [1, 2], 'LineWidth',0.01);
         end
     end
      for i = 1 : length(starts)
          line([starts(i), starts(i)], [0, 2], 'LineWidth',1, 'Color', 'r');
      end
      hold off;
      

     rMean = r( (-20:80) + starts(1));
     r1 = r((-20:80) + starts(1));
     for i = 2 : length(starts)
         rMean = rMean + r((-20:80) + starts(i));
         r1 = [r1; r((-20:80) + starts(i))];
     end
     rMean = rMean / length(starts);
     vars = arrayfun(@(x,y) sqrt(x^2 + y^2), diff(mean(progs.position.x, 1)), diff(mean(progs.position.y, 1)));

    vars = vars(4:end);
    figure;
    plot(-10:10, xcorr(vars, rMean, 10));
      [b, dev, stat] = glmfit(vars', rMean(1:end-4), 'poisson', 'estdisp', 'on');
      rEstimated = glmval(b, vars', 'log');
         disp(dev);
     res = stat;
     figure;
     subplot(3,1,1);
     hold on;
     plot(rMean(2:end-3));
     plot(rEstimated , 'r');    
     hold off;

     subplot(3,1,2);
     %plot(vars(end, :)');
     plot(var(r1, 1));
     xlim([0,100]);
     subplot(3,1,3);
     hold on;
     for i = 1 : length(r1(:,1))
          for j = 1 : 5 : length(r1(1,:))
               if r1(i,j) > 0
                   line([j, j], [i-1, i], 'LineWidth',4);
               end
          end
      end
      hold off;

         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
%      return;
%      for i = 1 : length(progs.progLengths.disp)
%         if progs.progLengths.disp(i) > 80
%            currProgIndex = find(progs.progressions(:,1) == progs.progStarts(i,4)) : find(progs.progressions(:,1) == progs.progStops(i,4));
%            currTime = progs.progressions(currProgIndex, 5);
%            currDataIndex = find(move_struct.data.tStamps > currTime(1), 1, 'first') : find(move_struct.data.tStamps > currTime(end), 1, 'first');
%            currTime = move_struct.data.tStamps(currDataIndex);
%            currX = move_struct.data.posSmth.x(currDataIndex);
%            currY = move_struct.data.posSmth.y(currDataIndex);
%            currJMP = arrayfun(@(x,y) sqrt(x^2 + y^2), diff(currX), diff(currY));
%            currTime = currTime(2:end);
%            curNeuro = r(:, currDataIndex);
%            curNeuro = curNeuro(:, 2:end);
%            %fprintf('%d %d %d \n', length(currJMP), length(currTime), length(curNeuro(1,:)));
%            
%            [b, dev, stat] = glmfit([currJMP(1:end-2), currJMP(2:end-1), currJMP(3:end)], curNeuro(7,2:end-1), 'poisson', 'estdisp', 'on');
%            rEstimated = glmval(b, [currJMP(1:end-2), currJMP(2:end-1), currJMP(3:end)], 'log');
%      
%      figure;
%      hold on;
%      plot(curNeuro(3, 2:end-1));
%      plot(rEstimated, 'r');
%      res = stat;
%      hold off;
%            
%             D = D + dev;
%            allJMP = [allJMP; currJMP];
%            allTimes = [allTimes; currTime];
%            allNeuro = [allNeuro, curNeuro];
%         end
%      end
%      disp(D);
%      
%      step = arrayfun(@(x) sqrt(x), [0, diff(move_struct.data.posSmth.x').^2 + diff(move_struct.data.posSmth.y').^2]);
%      data =[move_struct.data.accel.x'; ...
%             move_struct.data.accel.y'; ...
%             move_struct.data.accel.z'; ...
%             move_struct.data.accel.mag'; ...
%             move_struct.data.gyro.x'; ...
%             move_struct.data.gyro.y'; ...
%             move_struct.data.gyro.z'; ...
%             move_struct.data.gyro.mag'; ...
%             move_struct.data.posSmth.x'; ...
%             move_struct.data.posSmth.y'; ...
%             step];
%      rSmth = MakeSmoothWithGaussian(r, 5);
%      TryGLM(data, rSmth(7,:), -10:10);
%     
     %progs = TNC_OpenFieldReport(move_struct, 1, [1, length(move_struct.data.accel.x)]);
      %  res = progs;
end

