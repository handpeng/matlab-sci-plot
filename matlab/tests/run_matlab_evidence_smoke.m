function report = run_matlab_evidence_smoke(rootDir, outputDir)
% Validate runtime-to-evidence binding; not PDF glyph qualification.
if nargin < 1, rootDir = fileparts(fileparts(fileparts(mfilename('fullpath')))); end
if nargin < 2, outputDir = fullfile(tempdir,'matlab_evidence_smoke'); end
addpath(genpath(rootDir));
contract = mpReadJson(fullfile(rootDir,'examples','chinese_temperature_property.json'));
contract.provenance.candidate_sha = 'synthetic-evidence-smoke';
contract.provenance.source_id = ['合成数据-evidence-smoke-' char([55360 56320])];
plan = mpPlanFigure(contract,rootDir,'matlab');
style = struct('typography',struct('font_name','Arial','resolved_pt',8), ...
    'geometry',struct('line_width_pt',0.8,'marker_size_pt',4.5),'axes',struct('grid','off'));
data = struct('x',(1:3)','y',(2:4)');
review = struct('record_type','figure_review','record_version','1.0','verdict','accept', ...
    'scientific_correctness','PASS','dimensions',struct('claim_support','PASS','statistical_transparency','PASS', ...
    'perceptual_clarity','PASS','layout_hierarchy','PASS','accessibility','PASS','style_consistency','PASS', ...
    'final_size_legibility','PASS','reproducibility','PASS'));
rendered = mpRenderFigure(contract,plan,style,data,fullfile(outputDir,'cjk'),review);
manifest = rendered.manifest;
assert(isequal(manifest.typography,rendered.typography));
assert(isequal(manifest.typography,mpResolveFont('Arial',true)));
assert(strcmp(manifest.candidate_sha,contract.provenance.candidate_sha));
assert(isfile(rendered.png) && isfile(rendered.pdf));
disk = mpReadJson(fullfile(outputDir,'cjk','figure_manifest.json'));
assert(isequal(disk.typography,manifest.typography));
assert(strcmp(disk.source_data.source_id,contract.provenance.source_id));
for i = 1:numel(manifest.outputs), assert(numel(manifest.outputs(i).sha256)==64); end
% Original five-argument evidence calls remain supported without invented state.
legacy = mpWriteEvidence(contract,plan,review,{rendered.png,rendered.pdf},fullfile(outputDir,'legacy'));
assert(~isfield(legacy,'typography'));
bad = manifest.typography; bad.resolved_font = 'Arial';
try
    mpWriteEvidence(contract,plan,review,{rendered.png},fullfile(outputDir,'invalid'),bad);
    error('matlab_sci_plot:NegativeControlFailed','Malformed evidence was accepted.');
catch exception
    assert(strcmp(exception.identifier,'matlab_sci_plot:InvalidTypographyEvidence'),exception.message);
end
assert(~isfolder(fullfile(outputDir,'invalid')));
report = struct('status','PASS','runtime_binding','PASS','utf8_evidence','PASS', ...
    'legacy_call','PASS','malformed_fail_closed','PASS','resolved_font',manifest.typography.resolved_font,'matlab_version',version);
end
