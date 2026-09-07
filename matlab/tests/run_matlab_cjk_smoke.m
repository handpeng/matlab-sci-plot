function report = run_matlab_cjk_smoke(rootDir, outputDir, candidateSha)
% Synthetic Builder smoke only. PASS does not qualify PNG/PDF glyph correctness.
if nargin < 1, rootDir = fileparts(fileparts(fileparts(mfilename('fullpath')))); end
if nargin < 2, outputDir = fullfile(tempdir,'matlab_cjk_smoke'); end
if nargin < 3, candidateSha = ''; end % Caller supplies the exact tested commit.
addpath(genpath(rootDir));
if ~exist(outputDir,'dir'), mkdir(outputDir); end
policy = mpTypographyPolicy(); candidates = cellstr(string(policy.candidates));
available = cellstr(string(listfonts));
runtime = mpResolveFont('Arial',true,available);
style = struct('typography',struct('font_name','Arial','resolved_pt',8), ...
    'geometry',struct('line_width_pt',0.8,'marker_size_pt',4.5),'axes',struct('grid','off'), ...
    'final_size',struct('width_mm',150,'height_mm',100));
base = jsondecode(fileread(fullfile(rootDir,'examples','chinese_temperature_property.json')));
base.provenance.candidate_sha = char(candidateSha);
data = struct('x',(1:6)','y',[2;3;3.5;4;5;6]);
review = smokeReview();
cases = struct('id',{},'status',{},'output_dir',{},'resolved_font',{});

% 1. Chinese axes and physical units on the governed native contract path.
cases(end+1) = exportCase('01_chinese_axes',base,style,data,runtime,{});

% 2. Only runtime legend/category labels contain CJK; axes remain English.
english = base; english.labels = struct('x','Temperature','y','Conductivity');
legendContract = english; legendContract.communication_task = 'trend';
legendContract.roles = struct('x','ordered','y','numeric');
legendData = struct('x',data.x,'y',[data.y,data.y+0.2,data.y-0.2], ...
    'group_labels',{{'实验值','预测值','基准模型'}});
cases(end+1) = exportCase('02_chinese_legend',legendContract,style,legendData,runtime,{});
category = english; category.communication_task = 'model_comparison';
category.roles = struct('metrics','numeric','model','category'); category.data_bindings = struct('metrics','synthetic');
category.labels = struct('value','Metric'); category.units = struct(); category.required_unit_roles = {};
cases(end+1) = exportCase('02_chinese_categories',category,style, ...
    struct('values',[1;2;3],'labels',{{'实验值','预测值','基准模型'}}),runtime,{});

% 3. Mixed Unicode scientific symbols; no transliteration or numeric changes.
mixed = base; mixed.labels.x = '粒径'; mixed.units.x = 'μm';
cases(end+1) = exportCase('03_mixed_symbols',mixed,style,data,runtime,{});

% 4. CJK only in panel-visible titles on an existing paired narrative.
p1 = english; p1.panel_label = '(a) 升温过程';
p2 = english; p2.panel_label = '(b) 热处理状态 A';
composite = english; composite.data_bindings = struct(); composite.communication_task = 'composite';
composite.layout = 'paired'; composite.final_size = struct('width_mm',178,'height_mm',90);
composite.panels = {p1,p2}; panelStyle = style; panelStyle.final_size = composite.final_size;
cases(end+1) = exportCase('04_chinese_panels',composite,panelStyle,struct('panels',{{data,data}}),runtime,{});

% 5. Explicit request must be both governed and actually available.
installedCandidates = candidates(ismember(candidates,available));
explicitStyle = style; explicitStyle.typography.font_name = installedCandidates{end};
explicit = mpResolveFont(explicitStyle.typography.font_name,true,available);
assert(strcmp(explicit.resolution,'requested_cjk'));
cases(end+1) = exportCase('05_explicit_candidate',base,explicitStyle,data,explicit,{});

% 6. Remove only the preferred candidate from an injected inventory. The
% fallback used for a real export must still belong to actual listfonts.
fallbackInventory = available(~strcmp(available,candidates{1}));
fallbackStyle = style; fallbackStyle.typography.font_name = candidates{1};
fallback = mpResolveFont(candidates{1},true,fallbackInventory);
assert(~strcmp(fallback.resolved_font,candidates{1}) && strcmp(fallback.resolution,'fallback_cjk'));
assert(any(strcmp(fallback.resolved_font,available)));
cases(end+1) = exportCase('06_unavailable_preferred',base,fallbackStyle,data,fallback,{fallbackInventory});

% 7. No system fonts are removed. A fake inventory must fail before export.
noFontDir = fullfile(outputDir,'07_no_governed_font');
plan = mpPlanFigure(base,rootDir,'matlab');
try
    mpRenderFigure(base,plan,style,data,noFontDir,review,{'DefinitelyNotInstalledA'});
    error('matlab_sci_plot:NegativeControlFailed','Missing-font export unexpectedly succeeded.');
catch exception
    assert(strcmp(exception.identifier,'matlab_sci_plot:CJKFontUnavailable'),exception.message);
end
assert(~isfolder(noFontDir));
cases(end+1) = struct('id','07_no_governed_font','status','PASS','output_dir','','resolved_font','');
fprintf('CJK_CASE_07_no_governed_font=PASS (FAIL_CLOSED)\n');

% 8. Interpreter-sensitive axis text is tested on actual graphics objects.
literal = base; literal.labels.x = '样品_A 温度';
interpreterCheck(style);
cases(end+1) = exportCase('08_literal_underscore',literal,style,data,runtime,{});

% Additional native visible-data surfaces: scatter groups and feature ticks.
groupData = data; groupData.group = {'实验值';'实验值';'预测值';'预测值';'基准模型';'基准模型'};
cases(end+1) = exportCase('09_scatter_groups',english,style,groupData,runtime,{});
features = category; features.communication_task = 'explainability';
features.roles = struct('importance','feature_importance'); features.data_bindings = struct('importance','synthetic');
cases(end+1) = exportCase('10_feature_names',features,style, ...
    struct('importance',[1;2;3],'feature_names',{{'温度','粒径','热处理状态'}}),runtime,{});

report = struct('status','PASS','matlab_version',version,'candidate_sha',char(candidateSha), ...
    'cases',cases,'cjk_final_qualification','NOT_PERFORMED');
fid = fopen(fullfile(outputDir,'cjk_smoke_report.json'),'w','n','UTF-8');
assert(fid ~= -1); cleanup = onCleanup(@() fclose(fid));
fprintf(fid,'%s',jsonencode(report));
fprintf('MATLAB_CJK_SMOKE=PASS (%d cases)\nCJK_FINAL_QUALIFICATION=NOT_PERFORMED\n',numel(cases));

    function entry = exportCase(id, contract, currentStyle, boundData, expected, inventoryArgs)
        contractBefore = contract; dataBefore = boundData;
        currentPlan = mpPlanFigure(contract,rootDir,'matlab');
        destination = fullfile(outputDir,id);
        result = mpRenderFigure(contract,currentPlan,currentStyle,boundData,destination,review,inventoryArgs{:});
        assert(isfile(result.png) && isfile(result.pdf) && isfile(fullfile(destination,'figure_manifest.json')));
        manifest = jsondecode(fileread(fullfile(destination,'figure_manifest.json')));
        assert(isequal(manifest.typography,expected) && isequal(result.typography,expected));
        assert(strcmp(manifest.candidate_sha,char(candidateSha)));
        assert(numel(manifest.outputs)==2 && all(arrayfun(@(item) numel(item.sha256)==64,manifest.outputs)));
        assert(isequal(contract,contractBefore) && isequal(boundData,dataBefore));
        fidContract = fopen(fullfile(destination,'figure_contract.json'),'w','n','UTF-8');
        assert(fidContract ~= -1); contractCleanup = onCleanup(@() fclose(fidContract));
        fprintf(fidContract,'%s',jsonencode(contract));
        entry = struct('id',id,'status','PASS','output_dir',destination,'resolved_font',expected.resolved_font);
        fprintf('CJK_CASE_%s=PASS (font=%s)\n',id,expected.resolved_font);
    end
end

function interpreterCheck(style)
fig = figure('Visible','off'); cleanup = onCleanup(@() close(fig)); ax = axes(fig);
plot(ax,1:3); mpApplyStyle(ax,style);
label = xlabel(ax,'样品_A','Units','pixels');
scientific = ylabel(ax,'R^2 / \mu');
explicitMath = text(ax,1,1,'温度 T_i (\mu)');
state = mpApplyTypography(fig,style);
assert(state.contains_cjk);
assert(strcmp(label.String,'样品_A') && strcmp(label.Interpreter,'none'));
assert(strcmp(scientific.String,'R^2 / \mu') && strcmp(scientific.Interpreter,'tex'));
assert(strcmp(explicitMath.String,'温度 T_i (\mu)') && strcmp(explicitMath.Interpreter,'tex'));
drawnow; actual = label.Extent;
label.Interpreter = 'tex'; drawnow; interpreted = label.Extent;
assert(abs(actual(3)-interpreted(3)) > 0.1,'Literal underscore was not distinguished from TeX markup.');
end

function review = smokeReview()
review = struct('record_type','figure_review','record_version','1.0','verdict','accept', ...
    'scientific_correctness','PASS','dimensions',struct('claim_support','PASS','statistical_transparency','PASS', ...
    'perceptual_clarity','PASS','layout_hierarchy','PASS','accessibility','PASS','style_consistency','PASS', ...
    'final_size_legibility','PASS','reproducibility','PASS'), ...
    'notes','Synthetic technical gate fixture. CJK visual and PDF glyph qualification not performed.');
end
