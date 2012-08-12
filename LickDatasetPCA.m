function LickDatasetPCA(num)
%%Settings for the algorithm
    diffTime = 5; %time bin length in milliseconds
    SmthTime = 10; %time of Smothing, milliseconds
    pattWatchLength = [0:30];
    pcNum = 4;
%%Allocation and preparation
    f = figure;
    set(f,'Name','Lick Dataset Pattern Search Report','Color',[1 1 1]);
    addpath('C:\Users\loaner\Documents\JFSummerProject\Joshua code');
    addpath('C:\Users\loaner\Documents\JFSummerProject\');
    data = load('C:\Users\loaner\Documents\Data\ForPetr.mat');
    data = data.SessForPetr;

%Generating the firing rate for the data
%find the minimum and maximum timestamp for all the data
    minTime = min(arrayfun( @(x) min(x.ts), data.unit));
    maxTime = max(arrayfun( @(x) max(x.ts), data.unit));
    fprintf('Using time window %d milliseconds\n', diffTime);
    times = minTime : diffTime : maxTime + diffTime; %create the vector of timebins
    r = zeros(length(data.unit), length(times)); %Allocate the memory for the firing rate
    for cell = 1 : length(data.unit)
        cell_timestamps = data.unit(cell).ts;
        k = 1;
        for idx = 1 : length(cell_timestamps)
           while times(k) < cell_timestamps(idx)
               k = k + 1;
           end
           r(cell, k) = r(cell, k) + 1;
        end
    end
    fprintf('Max number of spikes in a bin %d\n', max(max(r)));
    fprintf('Size of the data matrix %d %d\n', size(r)); 
    
    r = zscore(MakeSmoothWithGaussian(r, SmthTime / diffTime)');
    timestamps = ceil(data.events.EL.ts/diffTime);
    av = zeros(length(pattWatchLength), size(r,2));
    for t = timestamps'
       av = av + r(pattWatchLength + t, :);
    end
    av = av / length(timestamps);
    
    [pc1, av, ~, ~] = princomp(av);
    [pc2, score, ~] = Skrew(av(:,1:pcNum));
    subplot(1,2,1);
    plot(av(:,1:pcNum));
   % subplot(1,2,2);
   % hold on; for i = 
   % plot(score(:,1), score(:,2));
    subplot(1,2,2);
    hold on;
    c= colormap(hsv(8));
    i = 1;
    for t = timestamps(10:18)'
        score = r(pattWatchLength + t, :)*pc1;
        plot(score(:, 1:pcNum)); return;
        score = score(:, 1:pcNum)*pc2;
        plot(score(:, 1), score(:,2), 'Color', c(i, :));
        i = i + 1;
    end
    hold off;
end

