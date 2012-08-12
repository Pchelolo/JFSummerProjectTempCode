classdef Analizer
    %This class holds all the methods for data analisys.
    
    properties
        neurons = [3,6,8,27]; %A set of neurons beeing analized currently
        TIME_START = 2*10^8; %Lower time bound for analized data (mcs)
        TIME_STOP = 3*10^8; %Upper time bound for analized data (mcs)
        %30Hz data from the csv file
        spike_times30Hz;
        spike_electrodes30Hz;
        move_times30Hz;
        move_acc30Hz;
        move_gyr30Hz;
        move_pos;
        %30Hz firing rate for the set of neurons
        r30Hz;
        %Slice of the data we want to use
        slice30Hz; 
        %10kHz data from the NS4 file
        move_times;
        move_acc;
        move_gyr;
        move_pos_sliced;
        %10kHz firing rate
        r;
        %Optimal lags found by plotGLM, if not set use default
        OptLags = [  11, 22,  0, 12, 12, 34, 55];
    end
    
    methods
        %Class constructor, loads and aligns all the provided data
        %This version uses NEV file for spike loading and does NOT
        %downsample 10kHz data to 100Hz accel and gyre sampling rate.
        function this = Analizer(NS4, data30Hz, SpikeData, input_type)
            %input tipe =  1 - 'sorted' / 2 - 'unsorted'
            %Load 30Hz data
            if(strcmp(input_type, 'sorted'))
                this.move_times = (0:10000:100*length(NS4.Data(1,:))-1)';
                this.move_acc = struct('x', NS4.Data(1, 1:100:end), 'y', NS4.Data(2, 1:100:end), 'z', NS4.Data(3, 1:100:end), 'mag', arrayfun(@(x, y, z) sqrt(x^2 + y^2 + z^2), NS4.Data(1, 1:100:end),NS4.Data(2, 1:100:end),NS4.Data(3, 1:100:end)));
                this.move_gyr = struct('x', NS4.Data(4, 1:100:end), 'y', NS4.Data(5, 1:100:end), 'z', NS4.Data(6, 1:100:end), 'mag', arrayfun(@(x, y, z) sqrt(x^2 + y^2 + z^2), NS4.Data(4, 1:100:end),NS4.Data(5, 1:100:end),NS4.Data(6, 1:100:end)));
%                 this.move_acc = struct('x', spline(this.move_times(1:100:end), NS4.Data(1, 1:100:end), this.move_times)', ...
%                                        'y', spline(this.move_times(1:100:end),NS4.Data(2, 1:100:end), this.move_times)', ...
%                                        'z', spline(this.move_times(1:100:end),NS4.Data(3, 1:100:end), this.move_times)', ...
%                                        'mag',spline(this.move_times(1:100:end), arrayfun(@(x, y, z) sqrt(x^2 + y^2 + z^2), NS4.Data(1, 1:100:end),NS4.Data(2, 1:100:end),NS4.Data(3, 1:100:end)), this.move_times)');
%                 this.move_gyr = struct('x', spline(this.move_times(1:100:end), NS4.Data(4, 1:100:end), this.move_times)', ...
%                                        'y', spline(this.move_times(1:100:end),NS4.Data(5, 1:100:end), this.move_times)', ...
%                                        'z', spline(this.move_times(1:100:end),NS4.Data(6, 1:100:end), this.move_times)', ...
%                                        'mag',spline(this.move_times(1:100:end), arrayfun(@(x, y, z) sqrt(x^2 + y^2 + z^2), NS4.Data(4, 1:100:end),NS4.Data(5, 1:100:end),NS4.Data(6, 1:100:end)), this.move_times)');
%                                         
                this.r = loadSortedGetRate(this.move_times);
                
                %ALIGNING NEEDED! do not know how to do it.
                this.move_pos_sliced = struct('x', spline(data30Hz.tStamps * 1000, data30Hz.posSmth.x, this.move_times)', ...
                                              'y', spline(data30Hz.tStamps * 1000, data30Hz.posSmth.y, this.move_times)');
                this.neurons = 1 : length(this.r(:, 1));
           
            else
%             disp('Loading and aligning data 30Hz');
%             [this.spike_times30Hz, this.spike_electrodes30Hz, this.move_times30Hz, this.move_acc30Hz, this.move_gyr30Hz, this.move_pos] = ...
%                     AlignTheData(SpikeData.Data.Spikes, data30Hz, this.neurons);
%             this.r30Hz = getFiringRates(this.spike_times30Hz, this.spike_electrodes30Hz, this.move_times30Hz);
%             %%get slice of data
%             start_slice = find(this.move_times30Hz > this.TIME_START, 1, 'first');
%             stop_slice = find(this.move_times30Hz >	this.TIME_STOP, 1, 'first');
%             this.slice30Hz = start_slice : stop_slice;
%              %times30Hz in milliseconds and times in microseconds
%             disp('Loading and aligning 10kHz data');
%             [spike_times, spike_electrodes, this.move_times, this.move_acc, this.move_gyr] = ...
%                     AlignTheDataWithNS4(SpikeData, NS4, 0, this.neurons);
%     
%     
%             start_time = this.move_times30Hz(this.slice30Hz(1));
%             stop_time = this.move_times30Hz(this.slice30Hz(end)); 
%     
%             this.move_pos_sliced.x = this.move_pos.x(this.slice30Hz);
%             this.move_pos_sliced.y = this.move_pos.y(this.slice30Hz);
%     
%             start_slice = find(spike_times > start_time, 1, 'first');
%             stop_slice = find(spike_times > stop_time, 1, 'first');
%             slice = start_slice : stop_slice;
%             spike_times = spike_times(slice);
%             spike_electrodes = spike_electrodes(slice);
%             
%             start_slice = find(this.move_times > start_time, 1, 'first');
%             stop_slice = find(this.move_times > stop_time, 1, 'first'   );
%             slice = start_slice : stop_slice;
%             %Slicing the move 10kHz information
%             Sname = fieldnames(this.move_acc); %Same for move_gyr
%             for ind = 1 : numel(Sname)
%                 this.move_acc.(Sname{ind}) = this.move_acc.(Sname{ind})(slice);
%                 this.move_gyr.(Sname{ind}) = this.move_gyr.(Sname{ind})(slice);
%             end
%             this.move_times = this.move_times(slice);
%             %interpolate mouse positions to 10kHz
%             this.move_pos_sliced.x = spline(this.move_times30Hz, this.move_pos.x, this.move_times)';
%             this.move_pos_sliced.y = spline(this.move_times30Hz, this.move_pos.y, this.move_times)';
%     
%             %get neuron firing rate
%             this.r = getFiringRates(spike_times, spike_electrodes, this.move_times);
            end
        end
        
        %Plot firing rates for individual neurons and average values
        function plotFiringRate(this) 
            disp('Plotting firing rate for each neuron');
            fig = figure;
            set(fig,'Name','Firing rate for neurons','Color',[1 1 1]);
            for i = 1: length(this.neurons)
                subplot(length(this.neurons),1, i);
                r_av = [];
                av_num = 40;
                for av = 1 : length(this.r(i,:)) / av_num
                    r_av = [r_av, mean(this.r(i, av:av+av_num))];
                end
                plot(this.move_times(1:av_num:end-av_num) / 1000, r_av);
                title(strcat('Firing rate for neuron', num2str(this.neurons(i))));
                xlabel('Time, millisecond');
                ylabel('Firing rate');
                xlim([0, max(this.move_times) / 1000]);
            end
            %Plot average firing rate
            disp('Plotting average firing rate');
            s = size(this.r);
            r_mean = zeros(1, s(2));
            for i = 1 : s(2)
                r_mean(i) = mean(this.r(:,i));
            end
            r_av = [];
            av_num = 40;
            for av = 1 : length(r_mean) / av_num
                 r_av = [r_av, mean(r_mean(av:av+av_num))];
            end
            r_mean = r_av;
            r_var = zeros(1, ceil(length(r_mean) / 100));
            for i = 1 : 100 : length(r_mean) - 100;
                r_var(ceil(i/100)) = var(r_mean(i:i+100));
            end
            fig = figure;
            set(fig,'Name','Average firing rate properties','Color',[1 1 1]);
            subplot(3,1,1);
            plot(this.move_times(1:av_num:end-av_num) / 1000, r_mean);
            title('Mean firing rate for all neurons');
            xlabel('Time, millisecond');
            ylabel('Mean firing rate');
            xlim([0,max(this.move_times) / 1000]);
            subplot(3,1,2);
            plot(this.move_times(1:av_num*100:end) / 1000 , r_var);
            title('Firing rate variance');
            xlabel('Time, millisecond');
            ylabel('Variance');
            xlim([0,max(this.move_times) / 1000]);
            subplot(3,1,3);
            for i = 1:100:length(r_mean)-100
                r_var(ceil(i/100)) = sqrt(r_var(ceil(i/100))) / r_mean(i);
            end
            plot(this.move_times(1:av_num*100:end) / 1000 , r_var);
            title('Firing rate relative standart deviation');
            xlabel('Time, millisecond');
            ylabel('Relative standart deviation');
            xlim([0,max(this.move_times) / 1000]);
        end
        
        %Plot behavioral data
        function plotBehavioral(this)
            disp('Plotting behaviur data');
            fig = figure;
            set(fig,'Name','Mouse behaviour data','Color',[1 1 1]);
            subplot(2,3,[1,4]);
            title('Position over time with firing rate');
            plotTrajectory3(this.r30Hz, this.move_pos.x, this.move_pos.y, this.move_times30Hz / 1000, 0);
            subplot(2,3,[2,5]);
            title('Seconds 20:30');
            plotTrajectory3(this.r30Hz, this.move_pos.x, this.move_pos.y, this.move_times30Hz / 1000, this.slice30Hz);
            subplot(2,3,3);
            plotAnalogData(this.move_acc30Hz, this.move_times30Hz / 1000, this.slice30Hz);
            title('Acceleroveter data, seconds 200:300');
            subplot(2,3,6);
            plotAnalogData(this.move_gyr30Hz, this.move_times30Hz / 1000, this.slice30Hz);
            title('Gyro data, seconds 200:300'); 
        end
        
        %Plot autocorrelations and cross correlations for neurons
        function plotNeuroCorrelations(this, neur)
            if neur==0
               neur = this.neurons; 
            end
            disp('Plotting correlations');
            maxlag = 50;
            fig = figure;
            set(fig,'Name','Crosscorrelation functions for neurons','Color',[1 1 1]);
            for i = 1 : length(neur)
                for j = 1 : length(neur)
                    if(i <= j)
                        subplot(length(neur), length(neur),(i-1)*length(neur) + j);
                        plot((-maxlag:maxlag) * 10, xcorr(this.r(i,:), this.r(j,:), maxlag));
                        title(strcat('Neuron ', num2str(neur(i)), 'Neuron ', num2str(neur(j))));
                        xlabel('Time shift, millisecond');
                    end
                end
            end 
        end
        
        %Plot autocorrelations and cross correlations for the data
        function plotDataCorrelations(this)
            data = [this.move_gyr.x; this.move_gyr.mag; this.move_gyr.z; this.move_gyr.mag];
            names = {'Gyr_x', 'Gyr_y', 'Gyr_z', 'Gyr_m'};
            maxlag = 1000;
            fig = figure;
            set(fig,'Name','Data Correlations','Color',[1 1 1]);
            s = size(data);
            s = s(1);
            for i =1 : s
                for j = 1 : s
                    if(i<=j)
                        subplot(s, s, (i-1)*s + j);
                        corr = xcorr(data(i,:), data(j, :), maxlag);
                        plot((-maxlag : 10 : maxlag) / 10, corr(1:10:end));
                        title(strcat(names{i}, '|', names{j}));
                        xlabel('Time shift, millisecond');
                        ylabel('Correlation');
                        grid on;
                    end
                end
            end
        end
        
        function plotRaster(this)
            fig = figure;
            set(fig,'Name','Raster plot','Color',[1 1 1]);
            hold on;
            for i = 1 : length(this.r(:,1))
                for j = 1 : 5 : length(this.r(1,:))
                    if this.r(i,j) > 0
                        line([j, j], [i-1, i], 'LineWidth',0.1);
                    end
                end
            end
            hold off;
            xlabel('Time, milliseconds');
            xlim([0, length(this.r(1,:))/5])
        end
        
        %Build GLM for the set of neurons
        function result = plotGLM(this)
            disp('Building GLM for each neuron');
            result = {};
            data = [this.move_acc.x; this.move_acc.y; this.move_acc.z; this.move_acc.mag; this.move_gyr.x; this.move_gyr.y; this.move_gyr.z; this.move_pos_sliced.x; this.move_pos_sliced.y];
            % data = [this.move_acc.y;this.move_acc.mag; this.move_gyr.z;];
           % data = [this.move_acc.y;this.move_acc.mag; this.move_gyr.z; this.move_acc.y.^2;];
            rSmth = MakeSmoothWithGaussian(this.r, 1);
            for i = 1:1%length(this.neurons)
                fprintf('Neuron %d\n', this.neurons(i));
                [fig, res, optimalLag] = TryGLM(data, rSmth(i, :), [-150:150]);
                result{end+1} = res;
                set(fig,'Name',sprintf('GLM for neuron %d', this.neurons(i)));
                this.OptLags(i) = optimalLag;
            end
            disp(this.OptLags); 
        end
        
        %Build GLM with coupling terms
        function result = plotGLMCoupling(this, N_to_Build, N_to_Add)
            disp('Building GLM with coupling terms');
            rSmth = MakeSmoothWithGaussian(this.r, 5);
            %rSmth = this.r;
            data = [this.move_acc.y; this.move_acc.mag; this.move_gyr.z; this.move_pos_sliced.x; this.move_pos_sliced.y];
            fprintf('Neuron %d', this.neurons(N_to_Build));
            [fig, result] = TryGLMcoupling(data, rSmth(N_to_Build, :), rSmth(N_to_Add, :), this.OptLags(N_to_Build));
            name = sprintf('GLM for neuron %d with coupling term neuron %d', this.neurons(N_to_Build), this.neurons(N_to_Add));
            set(fig,'Name', name, 'Color', [1 1 1]);
        end
        
        function plotBehaviourClassification(this)
            figure;
            hold on;
            ax = this.move_acc.x;
            ax = ax - mean(ax);
            plot(this.move_times, ax);
            
            threshold = mean(arrayfun(@(x) abs(x), ax));
            [indexes_max, peaks_max] = peakfinder(ax, (max(ax)-min(ax))/8, threshold);
            [indexes_min, peaks_min] = peakfinder(ax, (max(ax)-min(ax))/8, -threshold, -1);
            indexes = [indexes_max, indexes_min];
            peaks = [peaks_max, peaks_min];
            plot(this.move_times(indexes), peaks, 'or');
            line([min(this.move_times) max(this.move_times)], [threshold, threshold], 'Color', [0 0 0]);
            line([min(this.move_times) max(this.move_times)], [-threshold, -threshold], 'Color', [0 0 0]);
            xlim([min(this.move_times) max(this.move_times)]);
            hold off;
            %lets see class one - averaged rate
            good_ind = indexes_max(indexes_max > 50 & indexes_max < length(this.move_times) - 50) ;
            rAv = zeros(length(good_ind), 101);
            for i = 1 : length(good_ind)
               rAv(i,:) = this.r(7, good_ind(i) - 50: good_ind(i) + 50); 
            end
            mrAv = arrayfun( @(i) sum(rAv(:, i)) / length(good_ind), 1:101);
            vrAv = arrayfun( @(i) var(rAv(:, i)), 1:101);
            rvrAv = arrayfun( @(i) sqrt(vrAv(i)) / mrAv(i), 1:101);
            figure;
            subplot(3,1,1);
            plot([-500:10:500], mrAv);
            subplot(3,1,2);
            plot([-500:10:500], vrAv);
            subplot(3,1,3);
            plot([-500:10:500], rvrAv);
        end
    end
end

