function av = peristimulusAverage(ts, r, lag)
    av = zeros(1, length(lag));
    for i = 1:length(ts)
        av = av + r(lag+ts(i));
    end
    av = av / length(ts);
end

