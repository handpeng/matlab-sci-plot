function report = run_matlab_typography_smoke(rootDir, outputDir)
% Capability smoke tests, not glyph, PDF or cross-platform qualification.
if nargin < 1, rootDir = fileparts(fileparts(fileparts(mfilename('fullpath')))); end
if nargin < 2, outputDir = fullfile(tempdir,'matlab_typography_smoke'); end
addpath(genpath(rootDir));
policy = mpTypographyPolicy(); candidates = cellstr(string(policy.candidates));
for sampleText = ["温度","热导率","实验值 A","粒径 (μm)"]
    assert(mpContainsCJK(sampleText));
end
for sampleText = ["Temperature","W/(m·K)","° C μ","R^2 = -3"]
    assert(~mpContainsCJK(sampleText));
end
assert(~mpContainsCJK([NaN, 19968]));
for i = 1:size(policy.unicode_ranges,1)
    assert(mpContainsCJK(codepoint(policy.unicode_ranges(i,1))));
    assert(mpContainsCJK(codepoint(policy.unicode_ranges(i,2))));
end
assert(mpContainsCJK(codepoint(hex2dec('20000'))));
assert(~mpContainsCJK(codepoint(hex2dec('1F600'))));
english = mpResolveFont('Arbitrary English Font',false,{});
assert(strcmp(english.resolved_font,'Arbitrary English Font'));
requested = mpResolveFont(candidates{end},true,candidates);
assert(strcmp(requested.resolved_font,candidates{end}) && strcmp(requested.resolution,'requested_cjk'));
fallback = mpResolveFont(candidates{1},true,flipud(candidates(2:end)));
assert(strcmp(fallback.resolved_font,candidates{2}));
arbitrary = mpResolveFont('Arial',true,[{'Arial'}; candidates(2:end)]);
assert(strcmp(arbitrary.resolved_font,candidates{2}));
expectUnavailable(@() mpResolveFont('Arial',true,{'Arial','DefinitelyNotInstalledA'}));
expectUnavailable(@() mpResolveFont(candidates{1},true,{}));

available = listfonts;
runtime = mpResolveFont('Arial',true,available);
discovered = mpResolveFont('Arial',true);
assert(isequal(discovered,runtime));
style = struct('typography',struct('font_name','Arial','resolved_pt',8), ...
    'geometry',struct('line_width_pt',0.8,'marker_size_pt',4.5),'axes',struct('grid','off'));
fig = figure('Visible','off'); cleanup = onCleanup(@() close(fig));
t = tiledlayout(fig,1,2); ax = nexttile(t);
plot(ax,1:3,[1 2 3],'DisplayName','实验值'); legend(ax,'show');
xlabel(ax,'温度 (°C)'); ylabel(ax,'热导率 (W/(m·K))'); title(ax,'(a) 实验');
text(ax,1,1,'样品 A'); mpApplyStyle(ax,style);
ax2 = nexttile(t); plot(ax2,1:3); set(ax2,'XTick',1:3,'XTickLabel',{'一','二','三'});
title(t,'面板叙事'); drawnow;
sizes = get(findall(fig,'-property','FontSize'),'FontSize');
state = mpApplyTypography(fig,style);
assert(isequal(state,runtime));
objects = findall(fig,'-property','FontName');
for i = 1:numel(objects), assert(strcmp(objects(i).FontName,state.resolved_font)); end
assert(isequal(sizes,get(findall(fig,'-property','FontSize'),'FontSize')));

englishFig = figure('Visible','off'); englishCleanup = onCleanup(@() close(englishFig));
englishAx = axes(englishFig); plot(englishAx,1:3,'DisplayName','Observed');
xlabel(englishAx,'Temperature (°C)'); ylabel(englishAx,'R^2 / \mu'); legend(englishAx,'show');
text(englishAx,1,1,'隐藏文字','Visible','off'); mpApplyStyle(englishAx,style); drawnow;
names = get(findall(englishFig,'-property','FontName'),'FontName');
englishState = mpApplyTypography(englishFig,style,{});
assert(~englishState.contains_cjk && strcmp(englishState.resolved_font,'Arial'));
assert(isequal(names,get(findall(englishFig,'-property','FontName'),'FontName')));

contract = mpReadJson(fullfile(rootDir,'examples','chinese_temperature_property.json'));
plan = mpPlanFigure(contract,rootDir,'matlab'); data = struct('x',(1:3)','y',(2:4)');
before = numel(findall(groot,'Type','figure'));
% Both preview and accepted final export must fail before creating artifacts.
expectUnavailable(@() mpRenderFigure(contract,plan,style,data,fullfile(outputDir,'no_font_preview'),[],{}));
review = struct('record_type','figure_review','record_version','1.0','verdict','accept', ...
    'scientific_correctness','PASS','dimensions',struct('claim_support','PASS','statistical_transparency','PASS', ...
    'perceptual_clarity','PASS','layout_hierarchy','PASS','accessibility','PASS','style_consistency','PASS', ...
    'final_size_legibility','PASS','reproducibility','PASS'));
expectUnavailable(@() mpRenderFigure(contract,plan,style,data,fullfile(outputDir,'no_font_final'),review,{}));
assert(~isfolder(fullfile(outputDir,'no_font_preview')) && ~isfolder(fullfile(outputDir,'no_font_final')));
assert(numel(findall(groot,'Type','figure')) == before);
report = struct('status','PASS','font_discovery','PASS','fail_closed','PASS', ...
    'hierarchy_application','PASS','resolved_font',runtime.resolved_font,'matlab_version',version);
end

function value = codepoint(point)
if point <= 65535, value = char(point); return; end
point = point - 65536;
value = char([55296+floor(point/1024), 56320+mod(point,1024)]);
end

function expectUnavailable(operation)
try
    operation();
catch exception
    assert(strcmp(exception.identifier,'matlab_sci_plot:CJKFontUnavailable'),exception.message);
    return;
end
error('matlab_sci_plot:NegativeControlFailed','No-font control did not fail closed.');
end
