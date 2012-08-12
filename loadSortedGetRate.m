function r = loadSortedGetRate( move_times )
    %r = loadSortedGetRate( move_times )
    %Loads proper neuron firing times and create a firing rate structure
    %move_times - in microseconds
    
    %modeify this to add new files
    basepath = 'C:\Users\loaner\Documents\Data\Sorted\';
    neurons = [   
               struct('elec', 7,  'class' , [125]), ... %yellow, pink, black                          %1
               struct('elec', 9,  'class' , [107, 160, 235]), ... %yellow, pink, black                          %2
               struct('elec', 9,  'class' , [248, 229, 119]), ... %blue, green, red                             %3
               struct('elec', 11, 'class' , [895]), ... %red                                                    %4
               struct('elec', 11, 'class' , [896]), ... %green                                                  %5
               struct('elec', 13, 'class' , [625, 627, 277, 276]), ... %red, yellow, black waveform                  %6
               struct('elec', 15, 'class' , [153, 146, 130, 117, 68, 14]), ... %all of them are the same class  %7
              ];
    elec_prev = 0;
    r = zeros(length(neurons), length(move_times)+1);
    neuron_ind = 0;
    for n = neurons
        neuron_ind = neuron_ind + 1;
        if n.elec ~= elec_prev
            elec_prev = n.elec;
            filename = strcat(basepath, 'A', num2str(n.elec), '_sorted_new.mat');
            vars = {'newTimestampsNegative', 'assignedNegative'};
            S = load(filename, vars{ : });
        end
        timestamps = S.newTimestampsNegative(ismember(S.assignedNegative,n.class));
        timestamps = timestamps / 30 * 24; %24kHz was hardcoded in the osort. 
        k = 1;
        for i = 1 : length(timestamps)
            while (k <= length(move_times) && timestamps(i) >= move_times(k))
             k = k+1;
            end
            r(neuron_ind, k) = r(neuron_ind, k) + 1; 
        end
    end
    
  %  r = r / mean(diff(move_times)); %This is a real spike rate
    r = r(1:end, 1:end-1);
end