function plotGLM(data, Y)
            disp('Building GLM for each neuron');
            result = {};
            rSmth =  MakeSmoothWithGaussian(abs(Y),10);
            for i = 1:1
                [fig, res, optimalLag] = TryGLM(data, rSmth(i, :), [-150:150]);
                result{end+1} = res;
            end
end

