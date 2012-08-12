function STA(ts, beh)
f = figure;
set(f, 'Color', 'w');

toseconds = @(x) x/33.33333;

%dat = arrayfun(@(x,y) sqrt(x^2+y^2), diff(beh(9, :)), diff(beh(10,:)));
dat = beh';
lag = 20;
ts = ceil(ts);
while ts(1) <= lag
    ts = ts(2:end);
end
while ts(end) >= length(dat) - lag
    ts = ts(1:end-1);
end
all = zeros(length(ts), 2*lag+1);
for i = 1:length(ts)
    t = ts(i);
    all(i,:) = dat(t-lag:t+lag);
end

subplot(2,1,1);
baseline = mean(all,1) - mean(mean(all(:, 1:lag), 1));
plot(toseconds(-lag:lag), baseline, 'r', ...
    toseconds(-lag:lag), baseline + 1.96*(std(all,[],1)./sqrt(length(ts))), 'b', ...
    toseconds(-lag:lag),baseline - 1.96*(std(all,[],1)./sqrt(length(ts))));

subplot(2,1,2);
dev = zeros(1, 2*lag+1);
for i = 1 : 2*lag+1;
    dev(i) = var(all(:, i));
end
plot(toseconds(-lag:lag), dev);
% subplot(3,1,3);
% hold on;
% for i = 1 : length(ts)
%     plot(-lag:lag, all(i,:) - mean(all(i,1:lag)));
% end
% hold off;
end

