function findings = mpAudit(contract)
% Scientific audit entry point; governed integrity failures fail closed.
findings = struct('code', {}, 'severity', {}, 'message', {});
findings = [findings, auditRelationship(contract)]; %#ok<AGROW>
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

function findings = auditRelationship(contract)
findings = struct('code', {}, 'severity', {}, 'message', {});
semanticFields = {'required_data_roles','pairing_requirement','relationship_representation', ...
    'minimum_data_requirement','allowed_transformations','annotation_roles'};
hasRelationship = isfield(contract,'required_relationship');
if ~hasRelationship
    for i = 1:numel(semanticFields)
        if isfield(contract,semanticFields{i})
            findings(end+1) = relationshipFinding('RELATIONSHIP_SEMANTICS_REQUIRE_REQUIRED_RELATIONSHIP', ...
                'Relationship semantic fields require required_relationship.'); %#ok<AGROW>
            return;
        end
    end
    return;
end
[relationshipId, xRole, yRole, validIdentity] = relationshipIdentity(contract.required_relationship);
if ~validIdentity
    findings(end+1) = relationshipFinding('UNKNOWN_RELATIONSHIP_SEMANTICS', 'The required relationship identity is not governed.'); %#ok<AGROW>
    return;
end
if ~isfield(contract,'required_data_roles') || isempty(contract.required_data_roles)
    findings(end+1) = relationshipFinding('RELATIONSHIP_REQUIRED_DATA_ROLES_MISSING', 'Required relationship roles are missing.'); %#ok<AGROW>
    return;
end
requiredRoles = cellstr(string(contract.required_data_roles));
if ~all(ismember({xRole,yRole},requiredRoles))
    findings(end+1) = relationshipFinding('RELATIONSHIP_REQUIRED_DATA_ROLES_MISSING', ...
        sprintf('Relationship %s requires %s and %s roles.',relationshipId,xRole,yRole)); %#ok<AGROW>
end
if ~isfield(contract,'roles') || ~isstruct(contract.roles)
    findings(end+1) = relationshipFinding('RELATIONSHIP_ROLE_BINDING_MISSING', 'Required relationship roles are not bound.'); %#ok<AGROW>
else
    bindingNames = fieldnames(contract.roles);
    bindingValues = cellstr(string(struct2cell(contract.roles)));
    tokens = [bindingNames; bindingValues];
    if ~all(ismember(requiredRoles,tokens))
        findings(end+1) = relationshipFinding('RELATIONSHIP_ROLE_BINDING_MISSING', 'A required relationship role has no provider binding.'); %#ok<AGROW>
    end
end
if ~isfield(contract,'pairing_requirement') || ~any(strcmp(char(string(contract.pairing_requirement)),{'paired','aggregate'}))
    findings(end+1) = relationshipFinding('RELATIONSHIP_PAIRING_REQUIREMENT_MISSING', 'Pairing requirement is missing or unsupported.'); %#ok<AGROW>
else
    pairing = char(string(contract.pairing_requirement));
    expected = 'paired_observations';
    if strcmp(pairing,'aggregate'), expected = 'authorized_aggregate'; end
    if ~isfield(contract,'relationship_representation') || ~strcmp(char(string(contract.relationship_representation)),expected)
        findings(end+1) = relationshipFinding('RELATIONSHIP_REPRESENTATION_NOT_AUTHORIZED', 'Relationship representation does not match its pairing declaration.'); %#ok<AGROW>
    end
end
if isfield(contract,'minimum_data_requirement')
    minimum = relationshipMinimum(contract.minimum_data_requirement);
    if isempty(minimum) || minimum < 1
        findings(end+1) = relationshipFinding('RELATIONSHIP_MINIMUM_DATA_INVALID', 'Minimum relationship observations must be positive.'); %#ok<AGROW>
    end
end
if isfield(contract,'allowed_transformations')
    transformations = cellstr(string(contract.allowed_transformations));
    if any(~ismember(transformations,{'none','identity'}))
        findings(end+1) = relationshipFinding('UNAUTHORIZED_RELATIONSHIP_TRANSFORMATION', 'The relationship renderer supports no non-identity transformation.'); %#ok<AGROW>
    end
end
if isfield(contract,'annotation_roles')
    annotations = cellstr(string(contract.annotation_roles));
    if any(ismember(annotations,requiredRoles))
        findings(end+1) = relationshipFinding('RELATIONSHIP_ANNOTATION_ROLE_OVERLAP', 'Annotation roles cannot be required relationship roles.'); %#ok<AGROW>
    end
end
end

function [identifier, xRole, yRole, valid] = relationshipIdentity(value)
identifier = ''; xRole = ''; yRole = ''; valid = false;
if isstruct(value)
    if ~isfield(value,'id'), return; end
    identifier = char(string(value.id));
    if isfield(value,'x_role'), xRole = char(string(value.x_role)); end
    if isfield(value,'y_role'), yRole = char(string(value.y_role)); end
else
    identifier = lower(strtrim(char(string(value))));
end
if any(strcmp(identifier,{'distance -> error','distance->error','distance_to_error'}))
    identifier = 'distance_to_error'; xRole = 'distance'; yRole = 'error'; valid = true;
end
if isstruct(value) && (~strcmp(xRole,'distance') || ~strcmp(yRole,'error')), valid = false; end
end

function minimum = relationshipMinimum(value)
minimum = [];
if isnumeric(value) && isscalar(value), minimum = value; return; end
if isstruct(value) && isfield(value,'observations') && isnumeric(value.observations) && isscalar(value.observations)
    minimum = value.observations;
end
end

function finding = relationshipFinding(code, message)
finding = struct('code',code,'severity','error','message',message);
end
