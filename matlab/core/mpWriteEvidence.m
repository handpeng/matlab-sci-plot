function manifest = mpWriteEvidence(contract, plan, review, outputs, outputDir)
% Bind a real MATLAB-rendered artifact to review/provenance evidence.
if nargin < 5, outputDir = pwd; end
if ~isfield(review, 'verdict') || ~strcmp(char(string(review.verdict)), 'accept') || ...
        ~isfield(review, 'scientific_correctness') || ~strcmp(char(string(review.scientific_correctness)), 'PASS')
    error('matlab_sci_plot:ReviewGate','Accepted scientific review is required before final export.');
end
if ~isfield(plan, 'contract_version') || ~strcmp(char(string(plan.contract_version)), '1.0')
    error('matlab_sci_plot:UnsupportedPlan','Unsupported Figure Plan version.');
end
versionPath = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), 'VERSION');
skillVersion = strtrim(fileread(versionPath));
manifest = struct('manifest_type','figure_evidence','manifest_version','1.0', ...
    'skill_version',skillVersion,'contract_versions',struct('figure_plan',char(string(plan.contract_version)), ...
    'figure_review',char(string(review.record_version))),'matlab_version',version, ...
    'style_profile',char(string(plan.style_id)),'selected_candidate',char(string(plan.family_id)), ...
    'review_result',review,'outputs',[]);
for i = 1:numel(outputs)
    item = struct('path',outputs{i},'sha256',mpSha256(outputs{i}));
    if isempty(manifest.outputs), manifest.outputs = item; else, manifest.outputs(end+1) = item; end %#ok<AGROW>
end
if ~exist(outputDir, 'dir'), mkdir(outputDir); end
fid = fopen(fullfile(outputDir,'figure_manifest.json'),'w'); cleanup = onCleanup(@() fclose(fid));
fprintf(fid, '%s', jsonencode(manifest));
fidReview = fopen(fullfile(outputDir,'figure_review.json'),'w'); cleanupReview = onCleanup(@() fclose(fidReview));
fprintf(fidReview, '%s', jsonencode(review));
end

function digest = mpSha256(path)
fid = fopen(path, 'r'); cleanup = onCleanup(@() fclose(fid));
bytes = fread(fid, Inf, '*uint8');
md = java.security.MessageDigest.getInstance('SHA-256');
md.update(bytes);
digest = lower(reshape(dec2hex(typecast(md.digest(),'uint8'))',1,[]));
end
