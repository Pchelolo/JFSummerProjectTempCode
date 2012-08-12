function [fig, statistics] = TryGLM( move_acc, move_gyr, rSmth )
    %TryGLM - computes and plots a GLM Summary for the Smothed firing rate
    %   move_acc - struct with accelerometer measurments, samled at 10kHZ
    %   move_gyr - struct with gyro measurments, samples at 10kKz
    %   rSmth should be a vector fo single neuron
    
    fig = figure;
%%Normalize data
    rSmth = rSmth / mean(rSmth);
    move_acc.x = move_acc.x / mean(move_acc.x);
    move_acc.y = move_acc.y / mean(move_acc.y);
    move_acc.z = move_acc.z / mean(move_acc.z);
    move_acc.mag = move_acc.mag / mean(move_acc.mag);
    
    move_gyr.x = move_gyr.x / mean(move_gyr.x);
    move_gyr.y = move_gyr.y / mean(move_gyr.y);
    move_gyr.z = move_gyr.z / mean(move_gyr.z);
    move_gyr.mag = move_gyr.mag / mean(move_gyr.mag);
%% This is a very long procedure to find a perfect lag. 
    devs = [];
    for lag = -2000:40:2000 % +- 20 milliseconds
%       vars = [move_acc.x(1001+lag:10:end-1000+lag); move_acc.y(1001+lag:10:end-1000+lag); move_acc.z(1001+lag:10:end-1000+lag); move_acc.mag(1001+lag:10:end-1000+lag); ...
%               move_gyr.x(1001+lag:10:end-1000+lag); move_gyr.y(1001+lag:10:end-1000+lag); move_gyr.z(1001+lag:10:end-1000+lag); move_gyr.mag(1001+lag:10:end-1000+lag)];
        vars = [move_acc.x(1001+lag:10:end-1000+lag); move_acc.z(1001+lag:10:end-1000+lag); move_gyr.z(1001+lag:10:end-1000+lag) ];

       [b, dev] = glmfit(vars', rSmth(1001:10:end-1000), 'poisson', 'estdisp', 'on');
       devs = [devs, dev];
    end
    devs = devs(5:end-5);
%%Plot the deviance vs time shift
    set(fig,'Name','GLM properties','Color',[1 1 1]);
    subplot(2,3,3);
    time_offset = (-1000 : 40 : 1000) / 100;
    plot(time_offset(5:end-5), devs);
    title('Deviance for a model with a particular offset');
    xlabel('Time offset, milliseconds');
    ylabel('Deviance');
    
%%Building the model on a complete dataset
    lag = -999 + find( devs == min(devs) ) * 40;
   disp(strcat('Optimal time shift=', num2str(lag)));

%    vars = [  move_acc.x(1001+lag:end-1000+lag); move_acc.y(1001+lag:end-1000+lag); move_acc.z(1001+lag:end-1000+lag); move_acc.mag(1001+lag:end-1000+lag); ...
%            move_gyr.x(1001+lag:end-1000+lag); move_gyr.y(1001+lag:end-1000+lag); move_gyr.z(1001+lag:end-1000+lag); move_gyr.mag(1001+lag:end-1000+lag)];
    vars = [ move_acc.x(1001+lag:end-1000+lag); move_acc.z(1001+lag:end-1000+lag); move_gyr.z(1001+lag:end-1000+lag)];
   [b, dev, stat] = glmfit(vars', rSmth(1001:end-1000), 'poisson', 'estdisp', 'on');
      statistics = stat;
   disp('Full data fitting');
   disp(strcat('Deviation' , num2str(dev)));
   disp('p-Values');
   disp(stat.p);
   disp('B:');
   disp(b);
   disp('ChiSq1');
   disp(chi2cdf(dev, stat.dfe));
%%Build a model on a smaller subset of data and see how it works
   L = ceil(length(rSmth)/2);
%    vars = [move_acc.x(1001+lag:end-L-1000+lag); move_acc.y(1001+lag:end-L-1000+lag); move_acc.z(1001+lag:end-1000-L+lag); move_acc.mag(1001+lag:end-L-1000+lag); ...
%            move_gyr.x(1001+lag:end-L-1000+lag); move_gyr.y(1001+lag:end-L-1000+lag); move_gyr.z(1001+lag:end-L-1000+lag);move_gyr.mag(1001+lag:end-L-1000+lag)];
   vars = [move_acc.x(1001+lag:end-L-1000+lag); move_acc.z(1001+lag:end-1000-L+lag); move_gyr.z(1001+lag:end-L-1000+lag)];
   [b, dev, stat] = glmfit(vars', rSmth(1001:end-L-1000), 'poisson', 'estdisp', 'on');
   disp('Half data fitting');
   disp(strcat('Deviation' , num2str(dev)));
   disp('ChiSq2');
   disp(chi2cdf(dev, stat.dfe)); 
   
   
 %%Model is found, plottind the results
    subplot(2, 3, [1,2]);
    rAveraged = [];
    for i = 1:500:length(rSmth)-1000+lag
        rAveraged = [rAveraged, mean(rSmth((1:500) + i))];
    end
    hold on;
    
    plot((1:500:length(rSmth)-1500+lag) / 10, rAveraged(2:end), 'b');
%     rEstimated = glmval(b, [ move_acc.x(1:10:end); move_acc.y(1:10:end); move_acc.z(1:10:end); move_acc.mag(1:10:end); ... 
%                             move_gyr.x(1:10:end); move_gyr.y(1:10:end); move_gyr.z(1:10:end); move_gyr.mag(1:10:end)]', 'log');
   rEstimated = glmval(b, [ move_acc.x(1:10:end); move_acc.z(1:10:end); move_gyr.z(1:10:end)]', 'log');
 
    plot((1:10:length(rSmth)) / 10, rEstimated(1:end), 'r');
    legend('Avaraged firing rate', 'Predicted firing rate');
    hold off;
    xlabel('Time, millis');
    ylabel('Firing rate');
    xlim([0, (length(rSmth) - 1500 + lag)/10]);
    subplot(2,3,6);
    plot(rSmth(1:10:end),rEstimated, 'b.', 'MarkerSize', 1);
    xlabel('Real Firing Rate');
    ylabel('GLM Predicted firing rate');
    title('GLM predictions compared to real firing rate');
    
    
%Try cross-validation for the model: build a model on on subset of data,
%validate on the ither subset.
    ValidationLength = 300000;
%     vars = [move_acc.x(1001+lag:end-ValidationLength-1000+lag); move_acc.y(1001+lag:end-ValidationLength-1000+lag); ...
%             move_acc.z(1001+lag:end-ValidationLength-1000+lag); move_acc.mag(1001+lag:end-ValidationLength-1000+lag); ...
%             move_gyr.x(1001+lag:end-ValidationLength-1000+lag); move_gyr.y(1001+lag:end-ValidationLength-1000+lag); ...
%             move_gyr.z(1001+lag:end-ValidationLength-1000+lag); move_gyr.mag(1001+lag:end-ValidationLength-1000+lag)];
    vars = [move_acc.x(1001+lag:end-ValidationLength-1000+lag); move_acc.z(1001+lag:end-ValidationLength-1000+lag); move_gyr.z(1001+lag:end-ValidationLength-1000+lag)];
   [b, dev, stat] = glmfit(vars', rSmth(1001:end-ValidationLength-1000), 'poisson', 'estdisp', 'on');
%%Plot for the cross-validation results
    subplot(2, 3, [4,5]);
    rAveraged = [];
    for i = length(rSmth)-1500+lag-ValidationLength : 500 : length(rSmth)-1000+lag
        rAveraged = [rAveraged, mean(rSmth((1:500) + i))];
    end
    hold on;
    plot((length(rSmth)-1500+lag-ValidationLength:500:length(rSmth)-1500+lag) / 10, rAveraged(2:end), 'b');
%     rEstimated = glmval(b, [move_acc.x(end - ValidationLength:10:end); move_acc.y(end - ValidationLength:10:end); ...
%                             move_acc.z(end - ValidationLength:10:end); move_acc.mag(end - ValidationLength:10:end); ... 
%                             move_gyr.x(end - ValidationLength:10:end); move_gyr.y(end - ValidationLength:10:end); ...
%                             move_gyr.z(end - ValidationLength:10:end); move_gyr.mag(end - ValidationLength:10:end)]', 'log');
    rEstimated = glmval(b, [move_acc.x(end - ValidationLength:10:end); move_acc.z(end - ValidationLength:10:end); move_gyr.z(end - ValidationLength:10:end)]', 'log');
    plot((length(rSmth) - ValidationLength:10:length(rSmth)) / 10, rEstimated(1:end), 'r');
    legend('Avaraged firing rate', 'Predicted firing rate');
    hold off;
    xlabel('Time, millis');
    ylabel('Firing rate');
    title('Cross-validation checking plot');
    xlim([(length(rSmth)-1500+lag-ValidationLength)/10, (length(rSmth) - 1500 + lag)/10]);
end

