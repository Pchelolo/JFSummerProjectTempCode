function Cluster( r )
    set(0,'RecursionLimit',1000)
    time_delta = 5;
    objects = [];
    r = r * 10e3;
   % disp(r);
    for i = 1 : length(r(1,:))-time_delta
       obj = [];
       for j = 1 : length(r(:,1))
           obj = [obj, r(j, i:i+time_delta-1)];
       end
       objects = [objects; obj];
    end
    %disp(objects);
    Z = linkage(objects, 'complete', 'hamming');
    [H,T] = dendrogram_my(Z);
    T = cluster(Z, 'cutoff', 1.0);
    p = [];
    q = [];
    for i = 1:max(T)
        o = objects(T == i, :);
        p = [p, length(o(:,1))];
        q = [q; i];
    end
    p = p(4:end);
    q = q(4:end, :);
    figure;
    plot(p);
    for i = find(p>140)
        disp(i);
        disp(p(i));
        disp(unique(objects(T == i, :), 'rows'));
end

