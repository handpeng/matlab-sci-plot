function report = run_matlab_contract_smoke(rootDir, outputDir)
% Structural/text smoke only; no CJK render or qualification claim.
if nargin < 1, rootDir = fileparts(fileparts(fileparts(mfilename('fullpath')))); end
if nargin < 2, outputDir = fullfile(tempdir, 'matlab_contract_smoke'); end
addpath(genpath(rootDir));
if ~exist(outputDir,'dir'), mkdir(outputDir); end
contract = mpReadJson(fullfile(rootDir,'examples','chinese_temperature_property.json'));
plan = mpPlanFigure(contract, rootDir, 'matlab');
assert(strcmp(plan.family_id, 'relationship.scatter'));
assert(strcmp(mpAxisLabel(contract,'x','X'), '温度 (°C)'));
assert(strcmp(mpAxisLabel(contract,'y','Y'), '热导率 (W/(m·K))'));
roundtrip = jsondecode(jsonencode(contract));
assert(isequal(roundtrip, contract));
assert(isempty(mpAudit(contract)));
% Independent UTF-8 bytes cover supplementary ideographs and a non-CJK emoji.
% Detection alone must not be confused with supplementary font glyph coverage.
utf8 = {[240 160 128 128], [240 176 128 128], [240 175 160 128], [240 159 152 128]};
utf16 = {[55360 56320], [55424 56320], [55422 56320], [55357 56832]};
for i = 1:numel(utf8)
    wirePath = fullfile(outputDir,sprintf('supplementary_wire_%d.json',i));
    fidWire = fopen(wirePath,'wb'); assert(fidWire ~= -1);
    fwrite(fidWire,[uint8('{"text":"') uint8(utf8{i}) uint8('"}')],'uint8'); fclose(fidWire);
    decoded = mpReadJson(wirePath);
    assert(isequal(double(decoded.text),utf16{i}));
    assert(mpContainsCJK(decoded.text) == (i < 4));
    supplementary = contract; supplementary.labels.x = ['温度 ' decoded.text];
    roundtripPath = fullfile(outputDir,sprintf('supplementary_contract_%d.json',i));
    fidSupplementary = fopen(roundtripPath,'w','n','UTF-8'); assert(fidSupplementary ~= -1);
    fprintf(fidSupplementary,'%s',jsonencode(supplementary)); fclose(fidSupplementary);
    loaded = mpReadJson(roundtripPath);
    assert(isequal(loaded,supplementary));
    assert(strcmp(mpAxisLabel(loaded,'x','X'),[supplementary.labels.x ' (°C)']));
    supplementaryPlan = mpPlanFigure(loaded,rootDir,'matlab');
    assert(strcmp(supplementaryPlan.family_id,plan.family_id));
end
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
report = struct('status','PASS','utf8_roundtrip','PASS','supplementary_utf8_roundtrip','PASS', ...
    'supplementary_codepoints',numel(utf8),'runtime_planning','PASS','matlab_version',version);
end
