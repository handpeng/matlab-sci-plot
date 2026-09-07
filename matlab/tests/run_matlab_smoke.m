function report = run_matlab_smoke(rootDir, outputDir)
% Native MATLAB smoke path for Stage 3 qualification.
% Run from MATLAB with: addpath(genpath(ROOT)); run_matlab_smoke(ROOT, OUT)
if nargin < 1 || strlength(string(rootDir)) == 0, rootDir = fileparts(fileparts(mfilename('fullpath'))); end
if nargin < 2 || strlength(string(outputDir)) == 0, outputDir = fullfile(rootDir, 'matlab_smoke_output'); end
addpath(genpath(rootDir));
if ~exist(outputDir, 'dir'), mkdir(outputDir); end
style = struct('typography', struct('font_name','Arial','resolved_pt',8), 'geometry', struct('line_width_pt',0.8,'marker_size_pt',4.5), 'axes', struct('grid','off'));
truth = [0; 1; 2; 3]; prediction = [0.1; 0.8; 2.1; 2.7];
contracts = {
    struct('contract_type','figure_contract','contract_version','1.0','purpose','manuscript','claim',struct('primary','prediction validation'),'data_bindings',struct('truth','synthetic','prediction','synthetic'),'roles',struct('truth','truth','prediction','prediction'),'communication_task','validation','provenance',struct('source_id','matlab-smoke')),
    struct('contract_type','figure_contract','contract_version','1.0','purpose','manuscript','claim',struct('primary','relationship'),'data_bindings',struct('x','synthetic','y','synthetic'),'roles',struct('x','numeric','y','numeric'),'communication_task','relationship','provenance',struct('source_id','matlab-smoke')),
    struct('contract_type','figure_contract','contract_version','1.0','purpose','manuscript','claim',struct('primary','comparison'),'data_bindings',struct('metrics','synthetic'),'roles',struct('metrics','numeric','model','category'),'communication_task','model_comparison','provenance',struct('source_id','matlab-smoke')),
    struct('contract_type','figure_contract','contract_version','1.0','purpose','supplement','claim',struct('primary','distribution'),'data_bindings',struct('value','synthetic'),'roles',struct('value','numeric'),'communication_task','distribution','provenance',struct('source_id','matlab-smoke')),
    struct('contract_type','figure_contract','contract_version','1.0','purpose','manuscript','claim',struct('primary','trend'),'data_bindings',struct('ordered','synthetic','value','synthetic'),'roles',struct('ordered','ordered','value','numeric'),'communication_task','trend','provenance',struct('source_id','matlab-smoke'))};
reports = struct('family_id',{},'png',{},'pdf',{});
for i = 1:numel(contracts)
    plan = mpPlanFigure(contracts{i}, rootDir, 'matlab');
    data = struct('truth',truth,'prediction',prediction,'x',truth,'y',prediction, ...
        'values',prediction,'labels',{{'A','B','C'}});
    review = struct('record_type','figure_review','record_version','1.0','verdict','accept','scientific_correctness','PASS', ...
        'dimensions',struct('claim_support','PASS','statistical_transparency','PASS','perceptual_clarity','PASS','layout_hierarchy','PASS', ...
        'accessibility','PASS','style_consistency','PASS','final_size_legibility','PASS','reproducibility','PASS'));
    rendered = mpRenderFigure(contracts{i}, plan, style, data, outputDir, review);
    reports(i) = struct('family_id', rendered.family_id, 'png', rendered.png, 'pdf', rendered.pdf);
end
mpMetallurgyPattern('external_generalization');
report = struct('status','PASS','families',{ {reports.family_id} },'output_dir',outputDir,'matlab_version',version);
end
