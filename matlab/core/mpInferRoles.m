function roles = mpInferRoles(tbl, explicit)
% Conservative role inference; explicit bindings override heuristics.
roles = struct('numeric', {{}}, 'categorical', {{}}, 'ordered', {{}}, 'identifier', {{}});
names = tbl.Properties.VariableNames;
for i = 1:numel(names)
    name = names{i};
    if isfield(explicit, name)
        role = explicit.(name);
    elseif isnumeric(tbl.(name))
        role = 'numeric';
    else
        role = 'categorical';
    end
    if ~isfield(roles, role), roles.(role) = {}; end
    roles.(role){end+1} = name;
end
end
