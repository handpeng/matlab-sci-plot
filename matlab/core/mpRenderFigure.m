function result = mpRenderFigure(contract, plan, style, data, outputDir, review)
% Native MATLAB rendering boundary: plan -> tiledlayout -> family -> audit -> export.
if nargin < 5, outputDir = pwd; end
if ~strcmp(plan.backend_id, 'matlab'), error('matlab_sci_plot:BackendMismatch', 'V1 production backend is MATLAB.'); end
fig = figure('Visible','off','Color','w');
layout = mpBuildLayout(plan);
t = tiledlayout(fig, layout.rows, layout.columns, 'Padding','compact', 'TileSpacing','compact'); %#ok<NASGU>
ax = nexttile(t);
renderer = str2func(plan.renderer_entrypoint);
renderer(contract, plan, style, data, ax);
mpApplyStyle(ax, style);
findings = mpAudit(contract);
for i = 1:numel(findings)
    if strcmp(findings(i).severity, 'error'), close(fig); error('matlab_sci_plot:ScientificAudit', '%s', findings(i).message); end
end
if ~exist(outputDir, 'dir'), mkdir(outputDir); end
pngPath = fullfile(outputDir, 'figure.png');
pdfPath = fullfile(outputDir, 'figure.pdf');
if nargin < 6 || isempty(review)
    previewPath = fullfile(outputDir, 'candidate_preview.png');
    exportgraphics(fig, previewPath, 'Resolution', 300);
    result = struct('png',previewPath,'pdf','','findings',findings,'family_id',plan.family_id,'manifest',struct());
    close(fig);
    return;
end
if ~isfield(review, 'verdict') || ~strcmp(char(string(review.verdict)), 'accept') || ...
        ~isfield(review, 'scientific_correctness') || ~strcmp(char(string(review.scientific_correctness)), 'PASS')
    close(fig);
    error('matlab_sci_plot:ReviewGate','Accepted scientific review is required before final export.');
end
exportgraphics(fig, pngPath, 'Resolution', 300);
exportgraphics(fig, pdfPath, 'ContentType', 'vector');
if nargin >= 6 && ~isempty(review)
    manifest = mpWriteEvidence(contract, plan, review, {pngPath, pdfPath}, outputDir);
else
    manifest = struct();
end
result = struct('png',pngPath,'pdf',pdfPath,'findings',findings,'family_id',plan.family_id,'manifest',manifest);
close(fig);
end
