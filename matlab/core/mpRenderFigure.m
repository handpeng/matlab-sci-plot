function result = mpRenderFigure(contract, plan, style, data, outputDir, review)
% Native MATLAB rendering boundary: plan -> tiledlayout -> family -> audit -> export.
if nargin < 5, outputDir = pwd; end
if ~strcmp(plan.backend_id, 'matlab'), error('matlab_sci_plot:BackendMismatch', 'V1 production backend is MATLAB.'); end
fig = createFigure(style);
layout = mpBuildLayout(plan);
t = tiledlayout(fig, layout.rows, layout.columns, 'Padding','compact', 'TileSpacing','compact');
findings = mpAudit(contract);
if isfield(plan, 'panels') && ~isempty(plan.panels)
    panelPlans = normalizeItems(plan.panels);
    panelContracts = normalizeItems(contract.panels);
    if ~isfield(data, 'panels'), close(fig); error('matlab_sci_plot:MissingBinding', 'Composite rendering requires data.panels.'); end
    panelData = normalizeItems(data.panels);
    if numel(panelPlans) ~= numel(panelContracts) || numel(panelPlans) ~= numel(panelData)
        close(fig); error('matlab_sci_plot:PanelMismatch', 'Panel plan, contract, and data counts must match.');
    end
    for i = 1:numel(panelPlans)
        ax = nextPanelTile(t, layout, i, numel(panelPlans));
        renderer = str2func(panelPlans{i}.renderer_entrypoint);
        renderer(panelContracts{i}, panelPlans{i}, style, panelData{i}, ax);
        mpApplyStyle(ax, style);
        if isfield(panelContracts{i}, 'panel_label')
            title(ax, char(string(panelContracts{i}.panel_label)), 'FontWeight', 'normal');
        end
        findings = [findings, mpAudit(panelContracts{i})]; %#ok<AGROW>
    end
else
    ax = nexttile(t);
    renderer = str2func(plan.renderer_entrypoint);
    renderer(contract, plan, style, data, ax);
    mpApplyStyle(ax, style);
end
for i = 1:numel(findings)
    if strcmp(findings(i).severity, 'error'), close(fig); error('matlab_sci_plot:ScientificAudit', '%s: %s', findings(i).code, findings(i).message); end
end
if ~exist(outputDir, 'dir'), mkdir(outputDir); end
pngPath = fullfile(outputDir, 'figure.png');
pdfPath = fullfile(outputDir, 'figure.pdf');
if nargin < 6 || isempty(review)
    previewPath = fullfile(outputDir, 'candidate_preview.png');
    mpExport(fig, string(previewPath), Format="png", Resolution=300);
    result = struct('png',previewPath,'pdf','','findings',findings,'family_id',plan.family_id,'manifest',struct());
    close(fig);
    return;
end
if ~mpReviewAccepted(review)
    close(fig);
    error('matlab_sci_plot:ReviewGate','Every governed review dimension must PASS before final export.');
end
mpExport(fig, string(pngPath), Format="png", Resolution=300);
mpExport(fig, string(pdfPath), Format="pdf");
if nargin >= 6 && ~isempty(review)
    manifest = mpWriteEvidence(contract, plan, review, {pngPath, pdfPath}, outputDir);
else
    manifest = struct();
end
result = struct('png',pngPath,'pdf',pdfPath,'findings',findings,'family_id',plan.family_id,'manifest',manifest);
close(fig);
end

function fig = createFigure(style)
if isfield(style, 'final_size') && isfield(style.final_size, 'width_mm') && isfield(style.final_size, 'height_mm')
    fig = figure('Visible','off','Color','w','Units','centimeters', ...
        'Position',[1 1 style.final_size.width_mm/10 style.final_size.height_mm/10]);
else
    fig = figure('Visible','off','Color','w');
end
end

function items = normalizeItems(value)
if iscell(value), items = value; else, items = arrayfun(@(item) item, value, 'UniformOutput', false); end
end

function ax = nextPanelTile(t, layout, index, count)
if strcmp(layout.layout_id, 'hero_plus_diagnostics') && count == 3
    if index == 1, ax = nexttile(t, 1, [2 1]); elseif index == 2, ax = nexttile(t, 2); else, ax = nexttile(t, 4); end
else
    ax = nexttile(t);
end
end
