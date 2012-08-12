function result = paramethersPriority( tree_struct )
    result = struct('oob', 0, 'crossval', 0, 'fit', 0);
    corr_threshold = 1;
    
    result.oob = tree_struct.tree.OOBPermutedVarDeltaError;
    
    base_error_cross = sum((tree_struct.Y - tree_struct.Y1).^2);
    fit_idx = find(tree_struct.corr > corr_threshold);
    base_error_fit = sum((tree_struct.Y(fit_idx+100) - tree_struct.Y1(fit_idx+100)).^2);
    
    cross_val_error = zeros(1, size(tree_struct.X, 2));
    fit_error = zeros(1, size(tree_struct.X, 2));
    for param = 1 : size(tree_struct.X, 2)
        disp(param);
        X_perm = tree_struct.X(20000:end, :);
        X_perm(:,param) = X_perm(randperm(size(X_perm, 1)), param);
        Y1 = tree_struct.tree.predict(X_perm);
        cross_val_error(param) = sum((tree_struct.Y - Y1).^2) - base_error_cross;
        fit_error(param) = sum((tree_struct.Y(fit_idx+100) - Y1(fit_idx+100)).^2) - base_error_fit;
    end
    result.crossval = cross_val_error;
    result.fit = fit_error;
end

