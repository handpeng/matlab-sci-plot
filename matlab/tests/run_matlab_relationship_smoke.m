function report = run_matlab_relationship_smoke(rootDir, outputDir, candidateSha)
% Native relationship sufficiency and actual-render smoke; no qualification claim.
if nargin < 1 || strlength(string(rootDir)) == 0, rootDir = fileparts(fileparts(fileparts(mfilename('fullpath')))); end
if nargin < 2 || strlength(string(outputDir)) == 0, outputDir = fullfile(tempdir,'matlab_relationship_smoke'); end
if nargin < 3, candidateSha = ''; end
addpath(genpath(rootDir));
if ~exist(outputDir,'dir'), mkdir(outputDir); end
style = struct('typography',struct('font_name','Arial','resolved_pt',8), ...
    'geometry',struct('line_width_pt',0.8,'marker_size_pt',4.5),'axes',struct('grid','off'), ...
    'final_size',struct('width_mm',150,'height_mm',100));
review = acceptedReview();
base = struct('contract_type','figure_contract','contract_version','1.0', ...
    'purpose','native relationship smoke','claim',struct('primary','distance maps to error'), ...
    'data_bindings',struct('distance','synthetic','error','synthetic'), ...
    'roles',struct('distance','numeric','error','numeric','rho','numeric','p','numeric','n','numeric'), ...
    'communication_task','relationship','required_relationship','distance -> error', ...
    'required_data_roles',{{'distance','error'}},'pairing_requirement','paired', ...
    'relationship_representation','paired_observations','annotation_roles',{{'rho','p','n'}}, ...
    'provenance',struct('source_id','synthetic-native-relationship','candidate_sha',char(candidateSha)));
data = struct('distance',[-3;0;4;7],'error',[-2;1;5;6],'rho',-0.4,'p',0.2,'n',4);
plan = mpPlanFigure(base,rootDir,'matlab');
assert(strcmp(plan.family_id,'relationship.scatter'));
assert(strcmp(plan.relationship_bindings.distance,'distance'));
valid = mpValidateRelationshipData(base,plan,data);
assert(strcmp(valid.representation,'paired_observations'));
rendered = mpRenderFigure(base,plan,style,data,fullfile(outputDir,'scatter'),review);
assert(isfile(rendered.png) && isfile(rendered.pdf));
assert(strcmp(rendered.manifest.candidate_sha,char(candidateSha)));
expectFailure(@() mpWriteEvidence(base,plan,review,{rendered.png},fullfile(outputDir,'direct_without_data'),style.typography), ...
    'matlab_sci_plot:RelationshipGate');
assert(~isfolder(fullfile(outputDir,'direct_without_data')));

trend = base;
trend.communication_task = 'trend';
trend.roles = struct('distance','ordered','error','numeric');
trend.annotation_roles = {};
trendPlan = mpPlanFigure(trend,rootDir,'matlab');
assert(strcmp(trendPlan.family_id,'trend.line'));
trendData = struct('distance',[7,0,4,-3],'error',[6,1,5,-2]);
assert(strcmp(mpValidateRelationshipData(trend,trendPlan,trendData).representation,'paired_observations'));
trendRendered = mpRenderFigure(trend,trendPlan,style,trendData,fullfile(outputDir,'trend'),review);
assert(isfile(trendRendered.png) && isfile(trendRendered.pdf));

expectFailure(@() mpRenderFigure(base,plan,style,struct('rho',-0.4,'p',0.2,'n',4), ...
    fullfile(outputDir,'summary_only'),review),'matlab_sci_plot:INSUFFICIENT_RELATIONSHIP_DATA');
expectFailure(@() mpRenderFigure(base,plan,style,struct('distance',[1;2],'error',[3]), ...
    fullfile(outputDir,'mismatch'),review),'matlab_sci_plot:RELATIONSHIP_PAIRING_LENGTH_MISMATCH');
assert(~isfolder(fullfile(outputDir,'summary_only')) && ~isfolder(fullfile(outputDir,'mismatch')));

aggregate = base;
aggregate.pairing_requirement = 'aggregate';
aggregate.relationship_representation = 'authorized_aggregate';
aggregate.minimum_data_requirement = 1;
aggregatePlan = mpPlanFigure(aggregate,rootDir,'matlab');
aggregateRendered = mpRenderFigure(aggregate,aggregatePlan,style,struct('distance',-1.5,'error',0.25), ...
    fullfile(outputDir,'aggregate'),review);
assert(isfile(aggregateRendered.png) && isfile(aggregateRendered.pdf));

report = struct('status','PASS','candidate_sha',char(candidateSha), ...
    'scatter','PASS','trend','PASS','annotation_separation','PASS', ...
    'summary_only_fail_closed','PASS','pairing_mismatch_fail_closed','PASS', ...
    'authorized_aggregate','PASS','matlab_version',version);
fid = fopen(fullfile(outputDir,'relationship_smoke_report.json'),'w','n','UTF-8');
assert(fid ~= -1); cleanup = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s',jsonencode(report));
end

function review = acceptedReview()
dimensions = struct('claim_support','PASS','statistical_transparency','PASS','perceptual_clarity','PASS', ...
    'layout_hierarchy','PASS','accessibility','PASS','style_consistency','PASS', ...
    'final_size_legibility','PASS','reproducibility','PASS');
review = struct('record_type','figure_review','record_version','1.0','verdict','accept', ...
    'scientific_correctness','PASS','dimensions',dimensions);
end

function expectFailure(operation, identifier)
try
    operation();
catch exception
    assert(strcmp(exception.identifier,identifier),exception.message);
    return;
end
error('matlab_sci_plot:NegativeControlFailed','Expected %s.',identifier);
end
