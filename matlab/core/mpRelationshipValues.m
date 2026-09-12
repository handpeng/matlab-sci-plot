function [x, y] = mpRelationshipValues(plan, data)
% Resolve governed relationship bindings without renaming or transforming values.
xField = 'x'; yField = 'y';
if isfield(plan,'relationship_bindings') && isstruct(plan.relationship_bindings)
    if isfield(plan.relationship_bindings,'distance'), xField = char(string(plan.relationship_bindings.distance)); end
    if isfield(plan.relationship_bindings,'error'), yField = char(string(plan.relationship_bindings.error)); end
end
if ~isfield(data,xField) || ~isfield(data,yField)
    error('matlab_sci_plot:INSUFFICIENT_RELATIONSHIP_DATA','Required relationship fields are absent from bound data.');
end
x = data.(xField);
y = data.(yField);
end
