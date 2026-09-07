function manifest = mpWriteEvidence(contract, plan, review, outputs, outputDir, runtimeTypography)
% Bind a real MATLAB-rendered artifact to review/provenance evidence.
if nargin < 5, outputDir = pwd; end
if ~mpReviewAccepted(review)
    error('matlab_sci_plot:ReviewGate','Every governed review dimension must PASS before evidence can be written.');
end
if ~isfield(plan, 'contract_version') || ~strcmp(char(string(plan.contract_version)), '1.0')
    error('matlab_sci_plot:UnsupportedPlan','Unsupported Figure Plan version.');
end
if nargin >= 6
    % Check internal policy consistency; this does not establish glyph coverage.
    try
        expected = mpResolveFont(runtimeTypography.requested_font, runtimeTypography.contains_cjk, {runtimeTypography.resolved_font});
        if ~isequal(orderfields(runtimeTypography),orderfields(expected))
            error('matlab_sci_plot:InvalidTypographyEvidence','Typography state is inconsistent.');
        end
    catch exception
        error('matlab_sci_plot:InvalidTypographyEvidence','Invalid runtime typography state: %s', exception.message);
    end
end
versionPath = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), 'VERSION');
skillVersion = strtrim(fileread(versionPath));
candidateSha = '';
sourceData = struct();
if isfield(contract, 'provenance') && isstruct(contract.provenance)
    sourceData = contract.provenance;
    if isfield(contract.provenance, 'candidate_sha'), candidateSha = char(string(contract.provenance.candidate_sha)); end
end
timestamp = char(datetime('now','TimeZone','UTC','Format',"yyyy-MM-dd'T'HH:mm:ssXXX"));
manifest = struct('manifest_type','figure_evidence','manifest_version','1.0', ...
    'skill_version',skillVersion,'contract_versions',struct('figure_plan',char(string(plan.contract_version)), ...
    'figure_review',char(string(review.record_version))),'matlab_version',version, ...
    'candidate_sha',candidateSha,'qualification_timestamp',timestamp,'renderer_identity',{rendererIdentity(plan)}, ...
    'family_id',char(string(plan.family_id)),'source_data',sourceData, ...
    'style_profile',char(string(plan.style_id)),'selected_candidate',char(string(plan.family_id)), ...
    'review_result',review,'outputs',[]);
if isfield(plan, 'final_size'), manifest.final_dimensions = plan.final_size; end
if nargin >= 6, manifest.typography = runtimeTypography; end
for i = 1:numel(outputs)
    item = struct('path',outputs{i},'sha256',mpSha256(outputs{i}));
    if isempty(manifest.outputs), manifest.outputs = item; else, manifest.outputs(end+1) = item; end %#ok<AGROW>
end
if ~exist(outputDir, 'dir'), mkdir(outputDir); end
fid = fopen(fullfile(outputDir,'figure_manifest.json'),'w','n','UTF-8');
if fid == -1, error('matlab_sci_plot:EvidenceWriteFailed','Cannot open manifest output.'); end
cleanup = onCleanup(@() fclose(fid));
fprintf(fid, '%s', jsonencode(manifest));
fidReview = fopen(fullfile(outputDir,'figure_review.json'),'w','n','UTF-8');
if fidReview == -1, error('matlab_sci_plot:EvidenceWriteFailed','Cannot open review output.'); end
cleanupReview = onCleanup(@() fclose(fidReview));
fprintf(fidReview, '%s', jsonencode(review));
end

function identities = rendererIdentity(plan)
if isfield(plan, 'panels') && ~isempty(plan.panels)
    if iscell(plan.panels), panels = plan.panels; else, panels = arrayfun(@(item) item, plan.panels, 'UniformOutput', false); end
    identities = cellfun(@(item) char(string(item.renderer_entrypoint)), panels, 'UniformOutput', false);
else
    identities = {char(string(plan.renderer_entrypoint))};
end
end

function digest = mpSha256(path)
fid = fopen(path, 'r'); cleanup = onCleanup(@() fclose(fid));
bytes = fread(fid, Inf, '*uint8');
md = java.security.MessageDigest.getInstance('SHA-256');
md.update(bytes);
digest = lower(reshape(dec2hex(typecast(md.digest(),'uint8'))',1,[]));
end
