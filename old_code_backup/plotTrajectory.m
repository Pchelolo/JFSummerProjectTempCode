function plotTrajectory( x, y )
figure;
    cm = colormap(hot(length(x)));
    hold on;
    for i = 1 :100 :length(x)-101
        mline = line(x(i:i+100), y(i:i+100));
        set(mline, 'Color', cm(i,:));
    end
    caxis([1, length(y)]);
    colorbar;
    hold off;
end

