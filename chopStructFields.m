function structure = chopStructFields( structure, slice )
  fields = fieldnames(structure);
    for i = 1 : numel(fields)
       if isstruct(structure.(fields{i}))
           structure.(fields{i}) = chopStructFields(structure.(fields{i}), slice);
       else
            if length( structure.(fields{i})) > length(slice)
                structure.(fields{i}) = structure.(fields{i}) (slice);
            end
       end
    end
end

