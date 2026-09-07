function label = mpAxisLabel(contract, role, fallback)
% Resolve a semantic axis label and optional physical unit from the contract.
label = fallback;
if isfield(contract, 'labels') && isstruct(contract.labels) && isfield(contract.labels, role)
    label = char(string(contract.labels.(role)));
end
if isfield(contract, 'units') && isstruct(contract.units) && isfield(contract.units, role)
    unit = char(string(contract.units.(role)));
    if strlength(string(unit)) > 0
        label = sprintf('%s (%s)', label, unit);
    end
end
end
