function [fig, statistics, lag] = TryGLM( vars, rSmth, time_lags )
    %TryGLM - computes and plots a GLM Summary for the Smothed firing rate
    %   move_acc - struct with accelerometer measurments, samled at 10kHZ
    %   move_gyr - struct with gyro measurments, samples at 10kKz
    %   rSmth should be a vector fo single neuron
    
    toMillis = @(x) x*100/3;
    fig = figure;
%%Normalize data
    rSmth = rSmth / mean(rSmth);
    
%% This is a very long procedure to find a perfect lag. 
    devs = [];
    for lag = time_lags 
       vars_chopped = vars(:, 2001+lag:1:end-2000+lag);
       [b, dev] = glmfit(vars_chopped', rSmth(2001:1:end-2000), 'poisson', 'estdisp', 'on');
       devs = [devs, dev];
    end
    devs = devs(5:end-5);
%%Plot the deviance vs time shift
    set(fig,'Name','GLM properties','Color',[1 1 1]);
    subplot(2,3,3);
    plot(toMillis(time_lags(5:end-5)), devs);
    title('Deviance for a model with a particular offset');
    xlabel('Time offset, milliseconds');
    ylabel('Deviance');
    
%%Building the model on a complete dataset
    lag = min(time_lags) + (find( devs == min(devs(ceil(length(devs)/2):end))) + 4) * mean(diff(time_lags));
    fprintf('Optimal time shift %d \n', lag);
    rSmth = rSmth(2001 : end - 2000);

    vars = vars(:,(2001 + lag : end - 2000 + lag));
    [b, dev, stat] = glmfit(vars', rSmth, 'poisson', 'estdisp', 'on');
    statistics = stat;
   
    fprintf('Full data fitting. \nDeviation %dp-values\n', dev);
    disp(stat.p);
    disp('B:');
    disp(b);
    fprintf('ChiSq: %f', chi2cdf(dev, stat.dfe));

   
 %%Model is found, plottind the results
    subplot(2, 3, [1,2]);
   % averagingLength = ceil(length(rSmth) / 500);
   averagingLength = 5;
    rAveraged = [];
    for i = 1:averagingLength:length(rSmth) -averagingLength
        rAveraged = [rAveraged, mean(rSmth((1:averagingLength) + i))];
    end
    hold on;
    

    plot(toMillis(2001:averagingLength:length(rSmth)+2000-averagingLength), rAveraged, 'b');
    rEstimated = glmval(b, vars', 'log');
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
    
    plot(toMillis((2001:1:length(rSmth)+2000)), rEstimated(1:1:end), 'r');

    legend('Avaraged firing rate', 'Predicted firing rate');
    hold off;
    xlabel('Time, millis');
    ylabel('Firing rate');
    xlim([toMillis(2001), toMillis(length(rSmth))]);
    subplot(2,3,6);
    plot(rSmth(1:10:end),rEstimated(1:10:end), 'b.', 'MarkerSize', 1);
    xlim([0, max(rSmth)]);
    ylim([0, max(rEstimated)]);
    xlabel('Real Firing Rate');
    ylabel('GLM Predicted firing rate');
    title('GLM predictions compared to real firing rate');
    
%%Build a model on a smaller subset of data and see how it works
   L = ceil(length(rSmth)/2);
   [b1, dev, stat] = glmfit(vars(:, 1:L)', rSmth(1:L), 'poisson', 'estdisp', 'on');
   fprintf('Half data fitting.\nDeviation %d \nChiSq %f\n', dev,chi2cdf(dev, stat.dfe));
    
%Try cross-validation for the model: build a model on on subset of data,
%validate on the ither subset.
    ValidationLength = ceil(length(rSmth) / 4);
    [b, dev, stat] = glmfit(vars(:, 1:end-ValidationLength)', rSmth(1:end-ValidationLength), 'poisson', 'estdisp', 'on');
%%Plot for the cross-validation results
    subplot(2, 3, [4,5]);
    
    rAveraged = [];
    for i = length(rSmth)-ValidationLength : averagingLength : length(rSmth) - averagingLength
        rAveraged = [rAveraged, mean(rSmth((1:averagingLength) + i))];
    end
    hold on;
    plot(toMillis(length(rSmth)-ValidationLength:averagingLength:length(rSmth) - averagingLength), rAveraged(1:end), 'b');
    rEstimated = glmval(b, vars(:, end-ValidationLength : end)', 'log');
    plot(toMillis(length(rSmth) - ValidationLength:10:length(rSmth)), rEstimated(1:10:end), 'r');
    legend('Avaraged firing rate', 'Predicted firing rate');
    hold off;
    xlabel('Time, millis');
    ylabel('Firing rate');
    title('Cross-validation checking plot');
    xlim([toMillis(length(rSmth)-ValidationLength), toMillis(length(rSmth))]);
    ylim([0,2]);
end

