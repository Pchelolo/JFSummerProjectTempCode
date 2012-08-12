function plotTrajectory3( r, x, y, tStamps, slice);
    s = size(r);
    r_mean = zeros(1, s(2));
    for i = 1 : s(2)
        r_mean(i) = mean(r(:,i));
    end
    r_mean = r_mean * 1000 / mean(r_mean);
    
    h = colormap(hsv(ceil(max(r_mean)+2)));
    if(slice ~= 0)
        r_mean = r_mean(slice);
        x = x(slice);
        y = y(slice);
        tStamps = tStamps(slice);
    end
    hold on;
    av_rate = 200;
    for i=av_rate+1:av_rate:length(r_mean) 
      line(x(i-av_rate:i), y(i-av_rate:i), tStamps(i-av_rate:i), 'Color', h(ceil((r_mean(i)+1)), :)); 
    end
    grid on;view([-35 5]); axis([100 450 50 350 tStamps(1) tStamps(length(r_mean))]); 
    xlabel('X (px)');
    ylabel('Y (px)');
    zlabel('Time, milliseconds');
    hold off;
end

