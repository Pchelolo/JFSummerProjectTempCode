function crossCorrelations( r )
    maxlag = 1000;
    fig = figure;
    set(fig,'Name','GLM properties','Color',[1 1 1]);
    neurons = [20];
    disp(floor(sqrt(length(neurons))));
    for i= neurons
        subplot(ceil(sqrt(length(neurons))), floor(sqrt(length(neurons))),i - min(neurons) + 1);
        plot((-maxlag:maxlag) / 10, xcorr(r(i,:), r(i,:), maxlag));
        title(strcat('Neuron ', num2str(i)));
    end
end

