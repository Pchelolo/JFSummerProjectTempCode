function EntropyTest(probs)
figure;
h = [];
for i = -0.01 : 0.001: 0.01
    p = probs;
    p(17) = p(17) + i;
    p(69) = p(69) - i;
    h = [h, -sum(arrayfun(@(x) x*log(x), p))];
    
end
plot(h);
end

