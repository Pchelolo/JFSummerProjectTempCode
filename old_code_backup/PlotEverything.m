function [result] = PlotEverything(NS4, NS5dat, data30Hz, NEV)
    result = {}; %in case i want to return something
    WhatToPlot = struct('FiringRate',       0, ...
                        'BehaviourData',    0, ...
                        'Autocorr',         0, ...
                        'DataCorr',         0, ...
                        'Waveforms',        0, ...
                        'GLM',              0, ...
                        'Coupling',         0, ...
                        'DecoderBayes',     0, ...
                        'STA',              0);
                    
%%Get and align the 30Hz data
   disp('Loading data 30Hz');
   neurons = [3,6,8,27]; %A set of neurons to investigate
   [spike_times30Hz, spike_electrodes30Hz, move_times30Hz, move_acc30Hz, move_gyr30Hz, move_pos] = AlignTheData(NEV.Data.Spikes, data30Hz, neurons);
   r30Hz = getFiringRates(spike_times30Hz, spike_electrodes30Hz, move_times30Hz);
   move_times30Hz = move_times30Hz / 1000; %milliseconds
   
%%plot the firing rate for each neuron and the average firing rate
if (WhatToPlot.FiringRate == 1)
    disp('Plotting firing rate for each neuron');
    fig = figure;
    set(fig,'Name','Firing rate for neurons','Color',[1 1 1]);
    for i = 1: length(neurons)
        subplot(length(neurons),1, i);
        plot(move_times30Hz, r30Hz(i, :));
        title(strcat('Firing rate for neuron', num2str(neurons(i))));
        xlabel('Time, millisecond');
        ylabel('Firing rate');
        xlim([0, max(move_times30Hz)]);
    end
    %Plot average firing rate
    disp('Plotting average firing rate');
    s = size(r30Hz);
    r_mean = zeros(1, s(2));
    for i = 1 : s(2)
        r_mean(i) = mean(r30Hz(:,i));
    end
    r_var = zeros(1, ceil(length(r_mean) / 100));
    for i = 1 : 100 : length(r_mean) - 100;
        r_var(ceil(i/100)) = var(r_mean(i:i+100));
    end
    fig = figure;
    set(fig,'Name','Average firing rate properties','Color',[1 1 1]);
    subplot(3,1,1);
    plot(move_times30Hz, r_mean);
    title('Mean firing rate for all neurons');
    xlabel('Time, millisecond');
    ylabel('Mean firing rate');
    xlim([0,max(move_times30Hz)]);
    subplot(3,1,2);
    plot(move_times30Hz(1:100:end) , r_var);
    title('Firing rate variance');
    xlabel('Time, millisecond');
    ylabel('Variance');
    xlim([0,max(move_times30Hz)]);
    subplot(3,1,3);
    for i = 1:100:length(r_mean)-100
        r_var(ceil(i/100)) = sqrt(r_var(ceil(i/100))) / r_mean(i);
    end
    plot(move_times30Hz(1:100:end) , r_var);
    title('Firing rate relative standart deviation');
    xlabel('Time, millisecond');
    ylabel('Relative standart deviation');
    xlim([0,max(move_times30Hz)]);
end

%%get slice of data
    start_slice = find(move_times30Hz > 2*10^5, 1, 'first');
    stop_slice = find(move_times30Hz > 3*10^5, 1, 'first');
    slice = start_slice : stop_slice;
    
%%Plot behavioural data    
if(WhatToPlot.BehaviourData == 1)
    disp('Plotting behaviur data');
    fig = figure;
    set(fig,'Name','Mouse behaviour data','Color',[1 1 1]);
    subplot(2,3,[1,4]);
    title('Position over time with firing rate');
    plotTrajectory3(r30Hz, move_pos.x, move_pos.y, move_times30Hz, 0);
    subplot(2,3,[2,5]);
    title('Seconds 20:30');
    plotTrajectory3(r30Hz, move_pos.x, move_pos.y, move_times30Hz, slice);
    subplot(2,3,3);
    plotAnalogData(move_acc30Hz, move_times30Hz, slice);
    title('Acceleroveter data, seconds 200:300');
    subplot(2,3,6);
    plotAnalogData(move_gyr30Hz, move_times30Hz, slice);
    title('Gyro data, seconds 200:300');
end

%%Get data from NS4 file alined and chopped
    %times30Hz in milliseconds and times in microseconds
    disp('Loading and aligning 10kHz data');
    [spike_times, spike_electrodes, move_times, move_acc, move_gyr] = AlignTheDataWithNS4(NEV, NS4, 0, neurons);
    
    
    start_time = move_times30Hz(slice(1));
    stop_time = move_times30Hz(slice(end)); 
    
    move_pos.x = move_pos.x(slice);
    move_pos.y = move_pos.y(slice);
    move_times30Hz = move_times30Hz(slice) * 1000; %make move times 30Hz in microseconds
    
    start_slice = find(spike_times / 1000 > start_time, 1, 'first');
    stop_slice = find(spike_times / 1000 > stop_time, 1, 'first'   );
    slice = start_slice : stop_slice;
    spike_times = spike_times(slice);
    spike_electrodes = spike_electrodes(slice);
    start_slice = find(move_times / 1000 > start_time, 1, 'first');
    stop_slice = find(move_times / 1000 > stop_time, 1, 'first'   );
    slice = start_slice : stop_slice;
    move_times = move_times(slice);
    move_acc.x = move_acc.x(slice);
    move_acc.y = move_acc.y(slice);
    move_acc.z = move_acc.z(slice);
    move_acc.mag = move_acc.mag(slice);
    move_gyr.x = move_gyr.x(slice);
    move_gyr.y = move_gyr.y(slice);
    move_gyr.z = move_gyr.z(slice);
    move_gyr.mag = move_gyr.mag(slice);
    
if(WhatToPlot.Waveforms == 1)
   % NS5dat = NS5.Data(:, 6000000 : end);
    A_stop1 = 60;		% Attenuation in the first stopband = 60 dB
    F_stop1 = 250;		% Edge of the stopband = 8400 Hz
    F_pass1 = 350;	% Edge of the passband = 10800 Hz
    F_pass2 = 7950;	% Closing edge of the passband = 15600 Hz
    F_stop2 = 8050;	% Edge of the second stopband = 18000 Hz
    A_stop2 = 60;		% Attenuation in the second stopband = 60 dB
    A_pass = 1;		% Amount of ripple allowed in the passband = 1 dB
    d =fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',F_stop1, F_pass1, F_pass2, F_stop2, A_stop1, A_pass, A_stop2, 30000);
    BandPassFilt = design(d, 'equiripple');
    %For neuron number 3;
    
    figure;
    for i = 1 : length(neurons)
        times = spike_times(spike_electrodes == neurons(i));
        times = times(55:57);
        disp(times);
        for j = 1 : length(times)
           subplot(length(neurons), length(times), (i-1)*length(times) + j);
           y = filter(BandPassFilt, NS5dat(neurons(i), ceil(times(j) / 1000 * 30) - 3000 - 6000000: ceil(times(j) / 1000 * 30) + 3000 - 6000000));
           plot(-5: 0.03333: 5, y(ceil(length(y)/2)-150: ceil(length(y)/2)+150));
        end
    end
end    
    
    %interpolate mouse positions to 10kHz
    move_pos.x = spline(move_times30Hz, move_pos.x, move_times)';
    move_pos.y = spline(move_times30Hz, move_pos.y, move_times)';
    
    %get neuron firing rate
    r = getFiringRates(spike_times, spike_electrodes, move_times);
    result{end+1} = r;
    
%%Plot autocorrelations
if(WhatToPlot.Autocorr == 1)    
    disp('Plotting correlations');
    maxlag = 1000;
    fig = figure;
    set(fig,'Name','Crosscorrelation functions for neurons','Color',[1 1 1]);
    for i = 1 : length(neurons)
        for j = 1 : length(neurons)
            if(i <= j)
                subplot(length(neurons), length(neurons),(i-1)*length(neurons) + j);
                plot((-maxlag:maxlag) / 10, xcorr(r(i,:), r(j,:), maxlag));
                title(strcat('Neuron ', num2str(neurons(i)), 'Neuron ', num2str(neurons(j))));
                xlabel('Time shift, millisecond');
            end
        end
    end
end;

%%Plot data correlations
if(WhatToPlot.DataCorr == 1 )
    PlotDataCorrelations(move_acc, move_gyr);
end


%%Trying to build GLMs
if(WhatToPlot.GLM == 1)
    disp('Building GLM for each neuron');
   rSmth = MakeSmoothWithGaussian(r);
   %rSmth = r;
   OptLags = [];
    for i = 1:4
        disp(strcat('Neuron = ', num2str(neurons(i))));
        [fig, res, optimalLag] = TryGLMbackup([move_acc.y; move_acc.mag; move_gyr.z; move_pos.x; move_pos.y], rSmth(i, :));
        result{end+1} = res;
        set(fig,'Name',strcat('GLM for neuron', num2str(neurons(i))));
        OptLags = [OptLags , optimalLag];
    end
    disp(OptLags);
end   

%%Build GLMs with coupling
if(WhatToPlot.Coupling == 1)
    disp('Building GLM with coupling terms');
    if WhatToPlot.GLM == 0
        OptLags = [ 600, 550, 1800, 600];
    end
    rSmth = MakeSmoothWithGaussian(r);
    %rSmth = r;
    disp('Neuron 3');
    [fig, res] = TryGLMcoupling([move_acc.y; move_acc.mag; move_gyr.z; move_pos.x; move_pos.y], rSmth(2, :), rSmth(4, :), OptLags(1));
    result{end+1} = res;
    set(fig,'Name','GLM for neuron 3 with coupling term neuron 6', 'Color', [1 1 1]);
    disp('Neuron 27');
    [fig, res] = TryGLMcoupling([move_acc.y; move_acc.mag; move_gyr.z; move_pos.x; move_pos.y], rSmth(3, :), rSmth(1, :), OptLags(4));
    result{end+1} = res;
    set(fig,'Name','GLM for neuron 27 with coupling term neuron 6', 'Color', [1 1 1]);
end

% %%Build a Bayesian Decoder
% if(WhatToPlot.DecoderBayes == 1)
%     %%Set default parameters, so that not to rebuild model every time
%     if(WhatToPlot.GLM == 0)
%         betta6 = 1.0e-04 * [ 0.3722, 0.9548, 0.4759 ];
%         OptTimeShifts = [550, 550, 1550, 600];
%     end
%     if(WhatToPlot.Coupling == 0)
%         betta3 = [  0.000050012990564, 0.000182746797359, -0.000024697271535, -0.053232746486747, 0.043144538182915, -0.071218276000674, ...
%                     0.004753081095081, -0.008846126858589, -0.050593209064264, -0.004323378979501, -0.044241446553462 ];
%         shift3 = [-1900, -1850, -1800, -1750, -1700, -1650, -1250, -1200];
%         
%         betta8 = [  -0.000057554097043, -0.000043352282845, 0.000055380328716, -0.033725809072050, 0.077954911440558, ...
%                     -0.041577440484061, 0.081322403536235, 0.012165522203592, 0.030348377848390];
%         shift8 = [ -1500, -1450,  -950,  -900,  -850,  -300];
%     end
%     
%     rSmth = MakeSmoothWithGaussian( r );
%     
%     %%Estimate for neuron 6
%     lag = OptTimeShifts(2);
%     Acc_y = move_acc.y(2001 + lag : end - 2000 + lag);
%     Acc_mag = move_acc.mag(2001 + lag : end - 2000 + lag);
%     Gyr_z = move_gyr.z(2001 + lag : end - 2000 + lag);
%     rEstimated6 = glmval(betta6', [Acc_y; Acc_mag; Gyr_z]', 'log', 'constant', 'off');
%     
%     %%Estimate for neuron 3
%     lag = OptTimeShifts(1);
%     vars = [ move_acc.y(2001 + lag : end - 2000 + lag); move_acc.mag(2001 + lag : end - 2000 + lag); move_gyr.z(2001 + lag : end - 2000 + lag)];
%     for Couple_lag = shift3
%        vars = [vars ; rSmth(2, 2001 + Couple_lag : end - 2000 + Couple_lag)]; 
%     end
%     rEstimated3 = glmval(betta3', vars', 'log', 'constant', 'off');
%     
%     %%Estimate for neuron 8
%     lag = OptTimeShifts(3);
%     vars = [ move_acc.y(2001 + lag : end - 2000 + lag); move_acc.mag(2001 + lag : end - 2000 + lag); move_gyr.z(2001 + lag : end - 2000 + lag)];
%     for Couple_lag = shift8
%        vars = [vars ; rSmth(2, 2001 + Couple_lag : end - 2000 + Couple_lag)]; 
%     end
%     rEstimated8 = glmval(betta8', vars', 'log', 'constant', 'off');
%     
%     xEstimated = [move_acc.y(2000); move_acc.mag(2000); move_gyr.z(2000)];
%     V = [1 , 0, 0 ; 0, 1, 0; 0, 0, 1];
%     for i = 2001 : 3000
%        V = V + betta3(1 : 3)' * rEstimated3(i) * betta3(1 : 3) + betta6(1 : 3)' * rEstimated6(i) * betta6(1 : 3) + betta8(1 : 3)' * rEstimated8(i) * betta8(1 : 3);
%       xEstimated = [xEstimated, xEstimated(:, end) +  V \ (betta3(1:3)' * (rSmth(1, 2001 + i) - rEstimated3(i)) + betta6(1:3)' * (rSmth(2, 2001 + i) - rEstimated6(i)) + betta8(1:3)' * (rSmth(3, 2001 + i) - rEstimated8(i)))];
%     end
%     hold on;
%     plot(xEstimated(2, :));
%     plot(move_acc.mag(2001:3000));
%     hold off;
% end

% %%Build the decoder
% if(WhatToPlot.Decoder == 1)
%     TimeLags = [601, 551, 1301];
%     Shift63 = 1250;
%     Shift68 = 950;
%     
%     Shift63_data = TimeLags(1) + Shift63;
%     Shift68_data = TimeLags(3) + Shift68;
%     rSmth = MakeSmoothWithGaussian(r);
%     rSmth(1, : ) = rSmth(1, :) / mean( rSmth(1, :) ); 
%     rSmth(2, : ) = rSmth(2, :) / mean( rSmth(2, :) );
%     rSmth(3, : ) = rSmth(3, :) / mean( rSmth(3, :) );
%     gamma3 = -0.1848;
%     gamma8 =  0.1231;
%     
%     data = [];
%     bettainv = inv([0.0019, 0.1290, 0.0423; 0.0020, 0.0682, -0.0768;  -0.0036, -0.0297, -0.0881]);
%     for i = 10000 : 1000000
%         data = [data, bettainv * [log(rSmth(1, i-TimeLags(1))) + gamma3*rSmth(2, i - Shift63_data) ; ...
%                                   log(rSmth(2, i-TimeLags(2))) ; ...
%                                   log(rSmth(3, i-TimeLags(3))) + gamma8*rSmth(2, i - Shift68_data)] ];
%     end
%     
%     
%     figure;
%     subplot(3,1,1);
%     hold on;
%     plot(data(1, :), 'b');
%     plot(move_acc.x(10000 : 1000000) / mean(move_acc.x), 'r');
%     hold off;
%     
%       subplot(3,1,2);
%     hold on;
%     plot(data(2, :), 'b');
%     plot(move_acc.mag(10000 : 1000000) / mean(move_acc.mag), 'r');
%     hold off;
%     
%       subplot(3,1,3);
%     hold on;
%     plot(data(3, :), 'b');
%     plot(move_gyr.z(10000 : 1000000) / mean(move_gyr.z), 'r');
%     hold off;
%     result = data;
% end

% if(WhatToPlot.STA == 1)
%     disp('Running STA analysis');
%     sta = STA(spike_times, spike_electrodes, move_acc.mag, move_times, 200);
%     fig = figure;
%     set(fig,'Name','STA Analysis','Color',[1 1 1]);
%     %getting random STA
%     dif = diff(spike_times) * 4 / 100; 
%     rand_times = [];
%     rand_elect = [];
%     q = 0;
%     while (q < max(spike_times))
%        q = q + ceil(rand(1,1)*dif);
%        rand_elect = [rand_elect, ceil(rand(1,1)*100)];
%        rand_times = [rand_times, q];
%     end
%     sta_rand = sta(rand_times, rand_elect, move_acc.mag, move_times, 200);
%     for i = 1 : 4
%        subplot(2,2,i);
%        hold on;
%        for p = 1 : 100
%            plot(( -200:200 ) / 10, sta_rand(p,:));
%        end
%        plot(( -200:200 ) / 10, sta(i,:));
%        hold off
%        title(strcat('Neuron', num2str(neurons(i))));
%     end
% end

end

