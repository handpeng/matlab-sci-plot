function report = mpInspectData(input)
% Inspect a table-like input without changing values.
if istable(input)
    report = struct('n_rows', height(input), 'variable_names', {input.Properties.VariableNames});
else
    error('matlab_sci_plot:UnsupportedInput', 'Expected a MATLAB table for V1 inspection.');
end
end
