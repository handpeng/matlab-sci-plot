function findings = mpAudit(contract)
% Scientific audit entry point; governed integrity failures fail closed.
findings = struct('code', {}, 'severity', {}, 'message', {});
uncertaintyRequested = isfield(contract, 'uncertainty_requested') && contract.uncertainty_requested;
if isfield(contract, 'requested_layers') && isstruct(contract.requested_layers) && ...
        isfield(contract.requested_layers, 'uncertainty')
    uncertaintyRequested = uncertaintyRequested || contract.requested_layers.uncertainty;
end
if uncertaintyRequested && (~isfield(contract, 'uncertainty') || isempty(contract.uncertainty))
    findings = addFinding(findings, 'UNCERTAINTY_UNDECLARED', 'Uncertainty semantics are required.');
end
if isfield(contract, 'uncertainty_label') && strcmpi(char(string(contract.uncertainty_label)), '95% Band') && ...
        (~isfield(contract, 'uncertainty') || isempty(contract.uncertainty))
    findings = addFinding(findings, 'AMBIGUOUS_INTERVAL', 'A generic 95% Band is not a defined uncertainty interval.');
end
if isfield(contract, 'dual_y_axis') && contract.dual_y_axis && ...
        (~isfield(contract, 'dual_y_axis_justification') || strlength(string(contract.dual_y_axis_justification)) == 0)
    findings = addFinding(findings, 'DUAL_AXIS_UNJUSTIFIED', 'Dual y-axis requires semantic justification.');
end
if isfield(contract, 'palette_id') && any(strcmpi(char(string(contract.palette_id)), {'jet','rainbow'}))
    findings = addFinding(findings, 'QUANTITATIVE_RAINBOW_FORBIDDEN', 'jet/rainbow is forbidden for quantitative encoding.');
end
if isfield(contract, 'scale_policy') && strcmp(char(string(contract.scale_policy)), 'independent') && ...
        (~isfield(contract, 'scale_disclosure') || strlength(string(contract.scale_disclosure)) == 0)
    findings = addFinding(findings, 'INDEPENDENT_SCALE_UNDISCLOSED', 'Independent scales require explicit disclosure.');
end
if isfield(contract, 'comparison_policy') && strcmp(char(string(contract.comparison_policy)), 'model_specific') && ...
        ~isfield(contract, 'n_by_model')
    findings = addFinding(findings, 'COMMON_SAMPLE_UNDISCLOSED', 'Model-specific samples require n disclosure for every model.');
end
if isfield(contract, 'category_count')
    maxCategories = 12;
    if isfield(contract, 'max_categories'), maxCategories = contract.max_categories; end
    if contract.category_count > maxCategories
        findings = addFinding(findings, 'CATEGORICAL_OVERPOPULATION', 'Too many categories for the requested direct encoding; regroup or use small multiples.');
    end
end
if isfield(contract, 'encoding') && any(strcmp(char(string(contract.encoding)), {'bar','area'})) && ...
        (~isfield(contract, 'zero_baseline') || ~contract.zero_baseline)
    findings = addFinding(findings, 'BAR_ZERO_BASELINE', 'Bar/area magnitude encoding requires a zero baseline.');
end
if isfield(contract, 'axis_limits') && isstruct(contract.axis_limits) && ...
        isfield(contract.axis_limits, 'y') && isfield(contract, 'zero_baseline') && contract.zero_baseline
    limits = contract.axis_limits.y;
    if ~isempty(limits) && limits(1) > 0
        findings = addFinding(findings, 'MISLEADING_TRUNCATED_AXIS', 'A required zero baseline is excluded by the y-axis limits.');
    end
end
if isfield(contract, 'sample_size_required') && contract.sample_size_required && ~hasSampleSize(contract)
    findings = addFinding(findings, 'SAMPLE_SIZE_UNDISCLOSED', 'Sample size is required but was not disclosed.');
end
if isfield(contract, 'grouping_required') && contract.grouping_required && ...
        (~isfield(contract, 'data_bindings') || ~isfield(contract.data_bindings, 'group'))
    findings = addFinding(findings, 'GROUPING_INCONSISTENT', 'The requested grouped encoding has no group binding.');
end
if isfield(contract, 'required_unit_roles')
    roles = cellstr(string(contract.required_unit_roles));
    for i = 1:numel(roles)
        if ~isfield(contract, 'units') || ~isstruct(contract.units) || ...
                ~isfield(contract.units, roles{i}) || strlength(string(contract.units.(roles{i}))) == 0
            findings = addFinding(findings, 'UNIT_UNDECLARED', sprintf('Physical unit is required for role: %s', roles{i}));
        end
    end
end
end

function findings = addFinding(findings, code, message)
findings(end+1) = struct('code',code,'severity','error','message',message);
end

function present = hasSampleSize(contract)
present = isfield(contract, 'n') || isfield(contract, 'n_common') || isfield(contract, 'n_by_model');
if ~present && isfield(contract, 'claim') && isstruct(contract.claim)
    present = isfield(contract.claim, 'n') || isfield(contract.claim, 'n_common') || isfield(contract.claim, 'n_by_model');
end
end
