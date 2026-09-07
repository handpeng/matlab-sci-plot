function plan = mpPlanFigure(contract, rootDir, backend)
% Convert a validated semantic Figure Contract into a renderer-independent plan.
if nargin < 2 || strlength(string(rootDir)) == 0
    rootDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
end
if nargin < 3, backend = 'matlab'; end
required = {'contract_type','contract_version','purpose','claim','data_bindings','provenance'};
for i = 1:numel(required)
    if ~isfield(contract, required{i}), error('matlab_sci_plot:InvalidContract', 'Missing contract field: %s', required{i}); end
end
if ~strcmp(contract.contract_type, 'figure_contract') || ~strcmp(contract.contract_version, '1.0')
    error('matlab_sci_plot:UnsupportedContract', 'Figure Contract must use supported version 1.0.');
end
failOnAuditErrors(mpAudit(contract));
if isfield(contract, 'panels') && ~isempty(contract.panels)
    panelContracts = normalizeItems(contract.panels);
    panelPlans = cell(1, numel(panelContracts));
    for i = 1:numel(panelContracts)
        panelPlans{i} = mpPlanFigure(panelContracts{i}, rootDir, backend);
    end
    layoutId = 'small_multiples';
    if isfield(contract, 'layout'), layoutId = char(string(contract.layout)); end
    styleId = 'publication.general';
    if isfield(contract, 'target_profile'), styleId = char(string(contract.target_profile)); end
    plan = struct('contract_type','figure_plan','contract_version','1.0', ...
        'family_id','composite.panel_narrative','layout_id',layoutId,'backend_id',backend, ...
        'style_id',styleId,'candidate_rank',1,'compatibility_reason','panel contracts independently planned', ...
        'panel_count',numel(panelPlans),'scale_policy','shared','renderer_entrypoint','', ...
        'panels',{panelPlans});
    if isfield(contract, 'scale_policy'), plan.scale_policy = char(string(contract.scale_policy)); end
    if isfield(contract, 'final_size'), plan.final_size = contract.final_size; end
    return;
end
roles = {};
if isfield(contract, 'roles')
    names = fieldnames(contract.roles);
    for i = 1:numel(names), roles{end+1} = char(string(contract.roles.(names{i}))); end %#ok<AGROW>
end
task = 'validation';
if isfield(contract, 'communication_task'), task = char(string(contract.communication_task)); end
registry = mpFamilyRegistry(rootDir);
scores = [];
for i = 1:numel(registry)
    tasks = cellstr(string(registry(i).communication_tasks));
    requiredRoles = cellstr(string(registry(i).data_roles_required));
    hasNativeRenderer = ~strcmp(registry(i).matlab_renderer, 'mpRenderUnsupportedFamily');
    compatible = any(strcmp(tasks, task)) && strcmp(registry(i).renderer_backend, backend) && ...
        hasNativeRenderer && all(ismember(requiredRoles, roles));
    if compatible, scores(end+1) = i; end %#ok<AGROW>
end
if isempty(scores), error('matlab_sci_plot:NoCompatibleFamily', 'No family is compatible with task and roles.'); end
family = registry(scores(1));
manifest = jsondecode(fileread(fullfile(rootDir, 'manifests', 'families', [family.id '.json'])));
layouts = cellstr(string(manifest.recommended_layout_primitives));
layoutId = 'single';
if isfield(contract, 'layout')
    layoutId = char(string(contract.layout));
elseif isfield(contract, 'panel_count') && contract.panel_count > 1
    layoutId = layouts{1};
end
plan = struct('contract_type','figure_plan','contract_version','1.0', ...
    'family_id',char(string(family.id)),'layout_id',layoutId,'backend_id',backend, ...
    'style_id','publication.general','candidate_rank',1,'compatibility_reason','manifest roles/task/backend compatible', ...
    'panel_count',1,'scale_policy','shared','renderer_entrypoint',char(string(family.matlab_renderer)));
if isfield(contract, 'target_profile'), plan.style_id = char(string(contract.target_profile)); end
if isfield(contract, 'panel_count'), plan.panel_count = contract.panel_count; end
if isfield(contract, 'scale_policy'), plan.scale_policy = char(string(contract.scale_policy)); end
if isfield(contract, 'final_size'), plan.final_size = contract.final_size; end
end

function items = normalizeItems(value)
if iscell(value)
    items = value;
else
    items = arrayfun(@(item) item, value, 'UniformOutput', false);
end
end

function failOnAuditErrors(findings)
for i = 1:numel(findings)
    if strcmp(findings(i).severity, 'error')
        error('matlab_sci_plot:ScientificAudit', '%s: %s', findings(i).code, findings(i).message);
    end
end
end
