function [PC, Score, M] = Skrew( X )
    Xdiff = diff(X);
    X = X(1:end-1, :);
    Xdiff_reshaped = reshape(Xdiff, size(Xdiff, 1)*size(Xdiff, 2), 1);
    n = size(X, 2);
    X_blk = kron(eye(n), X);
    H = zeros(n^2, n*(n-1)/2);
    for i = 1:n
        for j = 1:n
            if i < j
                H(i+(j-1)*n, (j-1)*(j-2)/2+i) = 1;
            elseif i > j
                H(i+(j-1)*n, (i-1)*(i-2)/2+j) = -1;
            end
        end
    end
    X_new = X_blk*H;
    k = (X_new'*X_new)\X_new'*Xdiff_reshaped;
    M = reshape(H*k, n,n);
    [V, D] = eig(M);
    PC = [];
    for i = 1 : size(V, 1) / 2
        PC = [PC, V(:, (i-1)*2+1)+V(:, (i-1)*2+2), imag(V(:, (i-1)*2+1)-V(:, (i-1)*2+2))];
    end
    Score = X*PC;
end

