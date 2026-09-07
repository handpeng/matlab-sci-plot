function layout = mpBuildLayout(plan)
% Build a semantic tiledlayout plan; renderer code consumes the resulting metadata.
valid = {'single','paired','triptych','hero_plus_diagnostics','overview_plus_small_multiples','small_multiples','legend_panel'};
if ~isfield(plan, 'layout_id') || ~any(strcmp(plan.layout_id, valid)), error('matlab_sci_plot:UnknownLayout','Unknown semantic layout.'); end
layout = struct('layout_id', plan.layout_id, 'primitive', 'tiledlayout', 'reading_order', {{}});
switch plan.layout_id
    case 'single', layout.rows = 1; layout.columns = 1; layout.reading_order = {'A'};
    case 'paired', layout.rows = 1; layout.columns = 2; layout.reading_order = {'A','B'};
    case 'triptych', layout.rows = 1; layout.columns = 3; layout.reading_order = {'A','B','C'};
    case 'hero_plus_diagnostics', layout.rows = 2; layout.columns = 2; layout.reading_order = {'A','B','C'}; layout.hero_span = [2,1];
    case 'overview_plus_small_multiples', layout.rows = 2; layout.columns = 3; layout.reading_order = {'A','B','C','D'}; layout.overview_span = [1,3];
    case 'small_multiples', layout.rows = ceil(sqrt(plan.panel_count)); layout.columns = ceil(plan.panel_count/layout.rows); layout.reading_order = arrayfun(@(i) char('A'+i-1), 1:plan.panel_count, 'UniformOutput', false);
    case 'legend_panel', layout.rows = 1; layout.columns = 2; layout.reading_order = {'A','legend'};
end
if isfield(plan, 'scale_policy'), layout.scale_policy = plan.scale_policy; else, layout.scale_policy = 'shared'; end
end
