function report = mpValidateRelationshipData(contract, plan, data)
% Validate explicit relationship observations before any figure is created.
report = struct('status','PASS','representation','');
if ~isfield(contract,'required_relationship'), return; end
if ~isstruct(data)
    failRelationship('INSUFFICIENT_RELATIONSHIP_DATA','Relationship data must be a struct of bound observations.');
end
[relationshipId, xRole, yRole, valid] = relationshipIdentity(contract.required_relationship);
if ~valid
    failRelationship('UNKNOWN_RELATIONSHIP_SEMANTICS','The required relationship identity is not governed.');
end
requiredRoles = cellstr(string(contract.required_data_roles));
bindings = resolveBindings(contract, plan, requiredRoles);
if ~isfield(data,bindings.(xRole)) || ~isfield(data,bindings.(yRole))
    failRelationship('INSUFFICIENT_RELATIONSHIP_DATA',sprintf('Required %s -> %s observations are absent.',xRole,yRole));
end
minimum = relationshipMinimum(contract);
pairing = char(string(contract.pairing_requirement));
if strcmp(pairing,'paired')
    x = data.(bindings.(xRole));
    y = data.(bindings.(yRole));
    requireVector(x,xRole);
    requireVector(y,yRole);
    if numel(x) ~= numel(y)
        failRelationship('RELATIONSHIP_PAIRING_LENGTH_MISMATCH',sprintf('%s=%d %s=%d',xRole,numel(x),yRole,numel(y)));
    end
    if numel(x) < minimum
        failRelationship('INSUFFICIENT_RELATIONSHIP_DATA',sprintf('observations=%d minimum=%d',numel(x),minimum));
    end
    requireFinite(x,xRole);
    requireFinite(y,yRole);
    report.representation = 'paired_observations';
    report.relationship = relationshipId;
    report.x_role = xRole;
    report.y_role = yRole;
    report.bindings = bindings;
    return;
end
if ~strcmp(pairing,'aggregate') || ~strcmp(char(string(contract.relationship_representation)),'authorized_aggregate')
    failRelationship('RELATIONSHIP_REPRESENTATION_NOT_AUTHORIZED','The relationship representation is not explicitly authorized.');
end
if ~strcmp(char(string(plan.family_id)),'relationship.scatter')
    failRelationship('INCOMPATIBLE_RELATIONSHIP_FAMILY',char(string(plan.family_id)));
end
if minimum > 1
    failRelationship('INSUFFICIENT_RELATIONSHIP_DATA','Authorized aggregate has fewer observations than declared minimum.');
end
x = data.(bindings.(xRole));
y = data.(bindings.(yRole));
requireScalar(x,xRole);
requireScalar(y,yRole);
requireFinite(x,xRole);
requireFinite(y,yRole);
report.representation = 'authorized_aggregate';
report.relationship = relationshipId;
report.x_role = xRole;
report.y_role = yRole;
report.bindings = bindings;
end

function bindings = resolveBindings(contract, plan, requiredRoles)
bindings = struct();
if isfield(plan,'relationship_bindings') && isstruct(plan.relationship_bindings)
    explicit = plan.relationship_bindings;
    for i = 1:numel(requiredRoles)
        role = requiredRoles{i};
        if ~isfield(explicit,role)
            failRelationship('MISSING_RELATIONSHIP_ROLE',role);
        end
        bindings.(role) = char(string(explicit.(role)));
    end
    return;
end
if ~isfield(contract,'roles') || ~isstruct(contract.roles)
    failRelationship('MISSING_RELATIONSHIP_ROLE','roles');
end
fields = fieldnames(contract.roles);
values = cellstr(string(struct2cell(contract.roles)));
for i = 1:numel(requiredRoles)
    role = requiredRoles{i};
    matches = {};
    if isfield(contract.roles,role), matches{end+1} = role; end %#ok<AGROW>
    matches = [matches; fields(strcmp(values,role))]; %#ok<AGROW>
    matches = unique(matches,'stable');
    if isempty(matches)
        failRelationship('MISSING_RELATIONSHIP_ROLE',role);
    elseif numel(matches) > 1
        failRelationship('AMBIGUOUS_RELATIONSHIP_ROLE',role);
    end
    bindings.(role) = matches{1};
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

function minimum = relationshipMinimum(contract)
minimum = 1;
if ~isfield(contract,'minimum_data_requirement'), return; end
value = contract.minimum_data_requirement;
if isnumeric(value) && isscalar(value), minimum = value; return; end
if isstruct(value) && isfield(value,'observations') && isnumeric(value.observations) && isscalar(value.observations)
    minimum = value.observations;
end
end

function requireVector(value, role)
if ~isnumeric(value) || ~isvector(value)
    failRelationship('INSUFFICIENT_RELATIONSHIP_DATA',sprintf('%s must be a numeric observation vector.',role));
end
end

function requireScalar(value, role)
if ~isnumeric(value) || ~isscalar(value)
    failRelationship('INSUFFICIENT_RELATIONSHIP_DATA',sprintf('aggregate %s must be one numeric value.',role));
end
end

function requireFinite(value, role)
if ~isreal(value) || any(~isfinite(value(:)))
    failRelationship('INSUFFICIENT_RELATIONSHIP_DATA',sprintf('%s contains non-finite or non-real values.',role));
end
end

function failRelationship(code, message)
error(['matlab_sci_plot:' code],'%s',message);
end
