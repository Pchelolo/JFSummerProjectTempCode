function times = SpikeSorting( Trace )
    times = 0;
    A_stop1 = 60;		% Attenuation in the first stopband = 60 dB
    F_stop1 = 250;		% Edge of the stopband = 8400 Hz
    F_pass1 = 350;	% Edge of the passband = 10800 Hz
    F_pass2 = 7950;	% Closing edge of the passband = 15600 Hz
    F_stop2 = 8050;	% Edge of the second stopband = 18000 Hz
    A_stop2 = 60;		% Attenuation in the second stopband = 60 dB
    A_pass = 1;		% Amount of ripple allowed in the passband = 1 dB
    d =fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',F_stop1, F_pass1, F_pass2, F_stop2, A_stop1, A_pass, A_stop2, 30000);
    BandPassFilt = design(d, 'equiripple');
    y = filter(BandPassFilt, Trace);

    threshold = mean(arrayfun(@(x) abs(x), y)) * 4;
    
    [indexes_max, peaks_max] = peakfinder(y, (max(y)-min(y))/8, threshold);
    [indexes_min, peaks_min] = peakfinder(y, (max(y)-min(y))/8, -threshold, -1);
    indexes = [indexes_max, indexes_min];
    peaks = [peaks_max, peaks_min];
    fig = figure;
    set(fig,'Name','Voltage trace for a neuron','Color',[1 1 1]);
    subplot(1,3,[1,2]);
    hold on;
    plot([0: length(y)-1] / 33.333, y);
    plot((indexes-1) / 33.333, peaks, 'or');
    line([0, length(y)-1] / 33.333, [threshold, threshold], 'Color', [0 0 0]);
    line([0, length(y)-1] / 33.333, [-threshold, -threshold], 'Color', [0 0 0]);
    hold off;
    xlabel('Time, milliseconds');
    ylabel('Voltage');
    title('Voltage trce for an electrode');

    
    h = histc(peaks, min(peaks): max(peaks));
    subplot(1,3,3);
    bar(min(peaks): max(peaks), h);
    xlabel('Peak amplitude');
    ylabel('Number of peaks');
    title('Peak amplitude histogram');
    
    area_min = 1000;
    area_max = 1500;
    
    times = indexes(area_min < peaks & peaks < area_max);
end

