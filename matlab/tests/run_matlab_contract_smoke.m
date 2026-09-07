function report = run_matlab_contract_smoke(rootDir, outputDir)
% Structural/text smoke only; no CJK render or qualification claim.
if nargin < 1, rootDir = fileparts(fileparts(fileparts(mfilename('fullpath')))); end
if nargin < 2, outputDir = fullfile(tempdir, 'matlab_contract_smoke'); end
addpath(genpath(rootDir));
if ~exist(outputDir,'dir'), mkdir(outputDir); end
contract = jsondecode(fileread(fullfile(rootDir,'examples','chinese_temperature_property.json')));
plan = mpPlanFigure(contract, rootDir, 'matlab');
assert(strcmp(plan.family_id, 'relationship.scatter'));
assert(strcmp(mpAxisLabel(contract,'x','X'), '温度 (°C)'));
assert(strcmp(mpAxisLabel(contract,'y','Y'), '热导率 (W/(m·K))'));
roundtrip = jsondecode(jsonencode(contract));
assert(isequal(roundtrip, contract));
assert(isempty(mpAudit(contract)));
% Export runtime fixture shapes for independent Python/JSON Schema validation.
contracts = cell(1, 6);
for i = 1:6
    contracts{i} = contract;
end
contracts{1}.panel_label = '(a)';
contracts{2}.palette_id = 'jet';
contracts{3}.category_count = 16; contracts{3}.max_categories = 12;
contracts{4}.scale_policy = 'independent';
contracts{5}.sample_size_required = true;
composite = contract;
composite.data_bindings = struct(); composite.communication_task = 'composite';
composite.layout = 'paired'; composite.final_size = struct('width_mm',178,'height_mm',90);
composite.panels = {contracts{1}, contract};
contracts{6} = composite;
compositePlan = mpPlanFigure(composite,rootDir,'matlab');
assert(numel(compositePlan.panels) == 2);
fid = fopen(fullfile(outputDir,'runtime_contracts.json'),'w','n','UTF-8');
assert(fid ~= -1); cleanup = onCleanup(@() fclose(fid));
fprintf(fid,'%s',jsonencode(contracts));
report = struct('status','PASS','utf8_roundtrip','PASS','runtime_planning','PASS','matlab_version',version);
end
