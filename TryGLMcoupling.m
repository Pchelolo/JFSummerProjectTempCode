function [fig, statistics, couple_lags] = TryGLMcoupling( vars, rSmth, rOther, OptimalTimeShift )
    %TryGLM - computes and plots a GLM Summary for the Smothed firing rate
    %   move_acc - struct with accelerometer measurments, samled at 10kHZ
    %   move_gyr - struct with gyro measurments, samples at 10kKz
    %   rSmth should be a vector fo single neuron
    
    toMLs = @(x) 10 * x; %function to get time in millisecnds from index
    
    fig = figure;
    %%Normalize data
    rSmth = rSmth / mean(rSmth);
    rOther = rOther / mean(mean(rOther));

    %Align the move data paramethers with an optimal time shift
    vars = vars(:, 2001 + OptimalTimeShift : end - 2000 + OptimalTimeShift);
    %Chop the rSmth
    rSmth = rSmth(2001 : end - 2000);
    couple_lags = -50 : -1;
    TimeShift_Dev = zeros(length(rOther(:,1)), length(couple_lags));
    r1 = rOther; %Save a copy of an original rate for the coupling neuron
%%Find the optimal delay between 2 neurons 
    for i = 1 : length(r1(:,1))
        for r_lag = couple_lags
            rOther = r1(i, 2001 + r_lag : end - 2000 + r_lag);
            varsR = [vars; rOther];
            [b, dev, stat] = glmfit(varsR', rSmth, 'poisson', 'estdisp', 'on', 'constant', 'off');
            TimeShift_Dev(i, r_lag - min(couple_lags) + 1) = dev;
        end 
    end

    %TimeShift_Dev = TimeShift_Dev(:, 3:end-3);
    %couple_lags = couple_lags(3:end-3);
    subplot(2,3,3);
    plot(toMLs( couple_lags ), TimeShift_Dev);
    xlabel('Delay, milliseconnds');
    ylabel('Model deviance');
    legend(arrayfun(@(x) num2str(x), 1:length(r1(:,1)))', 'Location', 'SouthWest');
    title('Model deviance vs the delay between neurons');
    
    CouplingLag = [];
    for i = 1 : length(r1(:, 1))
        threshold = (mean(TimeShift_Dev(i,:)) + min(TimeShift_Dev(i,:)))/2 ;
        sorted = sort(TimeShift_Dev(i,:));
        CouplingLag = [CouplingLag; min(couple_lags) + find(ismember(TimeShift_Dev(i, :), sorted(1:5))) * mean(diff(couple_lags))];
    end
    disp('Time Shift beetween Neurons (in 0.1 millisecond)=');
    disp(CouplingLag);
    disp(strcat('Time Shift for the Neuron (in 0.1 millisecond)=', num2str(OptimalTimeShift)));
    couple_lags = CouplingLag;
    
%%Delays are found, check the model
    rOther = [];
    for i = 1 : length(CouplingLag(:,1))
        for shift = CouplingLag(i, :)
            rOther = [rOther; r1(i, 2001 + shift : end - 2000 + shift)];
        end
    end
    
    vars = [vars; rOther];
    [b, dev, stat] = glmfit(vars', rSmth, 'poisson', 'estdisp', 'on', 'constant', 'off');
    statistics = stat;
    disp('Full data fitting');
    disp(strcat('Deviation' , num2str(dev)));
    disp('p-Values');
    disp(stat.p);
    disp('B:');
    disp(b);
    disp('ChiSq1');
    disp(chi2cdf(dev, stat.dfe));
    
%%Estimate the results
    rEstimated = glmval(b, vars', 'log', 'constant', 'off');
    
%%Find the R squared
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
    disp('R squared');
    disp(rSquared);
    
    subplot(2, 3, [1,2]);
    rAveraged = [];
    rEstAv = [];
    av_len = 5;
    for i = 1:av_len:length(rSmth) - av_len
        rAveraged = [rAveraged, mean(rSmth((1:av_len) + i))];
        rEstAv = [rEstAv, mean(rEstimated((1:av_len)+i))];
    end
    disp(size(rSmth));
    disp(size(rAveraged));
    hold on;
    plot(toMLs((1:av_len:length(rSmth)-av_len)), rAveraged, 'b');
    plot(toMLs((1:av_len:length(rSmth)-av_len)), rEstAv, 'r');
    hold off;
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

%%Build the cross-validation model
    ValidationLength = ceil(length(rSmth) / 4);
    [b, dev, stat] = glmfit(vars(:, 1:end-ValidationLength)', rSmth(1:end-ValidationLength), 'poisson', 'estdisp', 'on', 'constant', 'off');

%%Plot for the cross-validation results
    subplot(2, 3, [4,5]);
    rAveraged = [];
    
    
    for i = length(rSmth)-ValidationLength : 500 : length(rSmth) - 500
        rAveraged = [rAveraged, mean(rSmth((1:500) + i))];
    end
    hold on;
    plot((length(rSmth)-ValidationLength:500:length(rSmth) - 500) / 10, rAveraged(1:end), 'b');
    rEstimated = glmval(b, vars(:, end - ValidationLength:end)', 'log', 'constant', 'off');
    plot((length(rSmth) - ValidationLength:10:length(rSmth)) / 10, rEstimated(1:10:end), 'r');
    legend('Avaraged firing rate', 'Predicted firing rate');
    hold off;
    xlabel('Time, millis');
    ylabel('Firing rate');
    title('Cross-validation checking plot');
    xlim([(length(rSmth)-ValidationLength)/10, length(rSmth)/10]);
    ylim([0,2]);
end

