function [fig, statistics] = TryGLMAll( vars, rSmth, time_lags )
    %TryGLM - computes and plots a GLM Summary for the Smothed firing rate
    %   move_acc - struct with accelerometer measurments, samled at 10kHZ
    %   move_gyr - struct with gyro measurments, samples at 10kKz
    %   rSmth should be a vector fo single neuron
    
    fig = figure;
%%Normalize data
    rSmth = rSmth / mean(rSmth);
    
%% This is a very long procedure to find a perfect lag. 
    devs = [];
    for lag = time_lags % +- 20 milliseconds
       vars_chopped = vars(:, 2001+lag:10:end-2000+lag);
       [b, dev] = glmfit(vars_chopped', rSmth(2001:10:end-2000), 'poisson', 'estdisp', 'on', 'constant', 'off');
       devs = [devs, dev];
    end
    devs = devs(5:end-5);
%%Plot the deviance vs time shift
    set(fig,'Name','GLM properties','Color',[1 1 1]);
    subplot(2,3,3);
    time_offset = time_lags * 10;
    plot(time_offset(5:end-5), devs);
    title('Deviance for a model with a particular offset');
    xlabel('Time offset, milliseconds');
    ylabel('Deviance');
    
%%Building the model on a complete dataset
    rSmth = rSmth(2001 : end - 2000);
    new_vars = [];
    for l = time_lags
        new_vars = [new_vars; vars(:,(2001 + l : end - 2000 + l))]; 
    end
    vars = new_vars;
    [b, dev, stat] = glmfit(vars', rSmth, 'poisson', 'estdisp', 'on', 'constant', 'off');
    statistics = stat;
   
    fprintf('Full data fitting. \nDeviation %dp-values\n', dev);
    disp(stat.p);
    disp('B:');
    disp(b);
    fprintf('ChiSq: %f', chi2cdf(dev, stat.dfe));

   
 %%Model is found, plottind the results
    subplot(2, 3, [1,2]);
    averagingLength = ceil(length(rSmth) / 500);
    rAveraged = [];
    for i = 1:averagingLength:length(rSmth) -averagingLength
        rAveraged = [rAveraged, mean(rSmth((1:averagingLength) + i))];
    end
    hold on;
    
    
    plot((1:averagingLength:length(rSmth)-averagingLength) / 10, rAveraged, 'b');
    rEstimated = glmval(b, vars', 'log', 'constant', 'off');
    %Evaluate Rsquared
    Mean_real = mean( rSmth );
    sum_up = 0;
    sum_down = 0;
    for i = 1 : length(rSmth)
        if rSmth(i) ~= 0
            sum_down = sum_down + rSmth(i)*log(rSmth(i) / Mean_real);
            sum_up = sum_up + rSmth(i)*log(rSmth(i) / rEstimated(i)) + rEstimated(i) - rSmth(i);
        else
            sum_up  = sum_up + rEstimated(i);
        end
    end
    rSquared = 1 - sum_up / sum_down;
    fprintf('R squared %f', rSquared);
    
    plot((1:10:length(rSmth)) / 10, rEstimated(1:10:end), 'r');
    legend('Avaraged firing rate', 'Predicted firing rate');
    hold off;
    xlabel('Time, millis');
    ylabel('Firing rate');
    xlim([0, (length(rSmth))/10]);
    subplot(2,3,6);
    plot(rSmth(1:10:end),rEstimated(1:10:end), 'b.', 'MarkerSize', 1);
    xlabel('Real Firing Rate');
    ylabel('GLM Predicted firing rate');
    title('GLM predictions compared to real firing rate');
    
%%Build a model on a smaller subset of data and see how it works
   L = ceil(length(rSmth)/2);
   [b1, dev, stat] = glmfit(vars(:, 1:L)', rSmth(1:L), 'poisson', 'estdisp', 'on', 'constant', 'off');
   fprintf('Half data fitting.\nDeviation %d \nChiSq %f\n', dev,chi2cdf(dev, stat.dfe));
    
%Try cross-validation for the model: build a model on on subset of data,
%validate on the ither subset.
    ValidationLength = ceil(length(rSmth) / 4);
    [b, dev, stat] = glmfit(vars(:, 1:end-ValidationLength)', rSmth(1:end-ValidationLength), 'poisson', 'estdisp', 'on', 'constant', 'off');
%%Plot for the cross-validation results
    subplot(2, 3, [4,5]);
    
    rAveraged = [];
    for i = length(rSmth)-ValidationLength : averagingLength : length(rSmth) - averagingLength
        rAveraged = [rAveraged, mean(rSmth((1:averagingLength) + i))];
    end
    hold on;
    plot((length(rSmth)-ValidationLength:averagingLength:length(rSmth) - averagingLength) / 10, rAveraged(1:end), 'b');
    rEstimated = glmval(b, vars(:, end-ValidationLength : end)', 'log', 'constant', 'off');
    plot((length(rSmth) - ValidationLength:10:length(rSmth)) / 10, rEstimated(1:10:end), 'r');
    legend('Avaraged firing rate', 'Predicted firing rate');
    hold off;
    xlabel('Time, millis');
    ylabel('Firing rate');
    title('Cross-validation checking plot');
    xlim([(length(rSmth)-ValidationLength)/10, length(rSmth)/10]);
    ylim([0,2]);
end

