function mpRenderExplainability(~, ~, style, data, ax)
if ~isfield(data,'feature_names') || ~isfield(data,'importance'), error('matlab_sci_plot:MissingBinding','precomputed feature names and importance are required.'); end
[importance, order] = sort(data.importance(:), 'ascend'); names = data.feature_names(order);
barh(ax, importance, 'FaceColor', [0 158 115]/255, 'EdgeColor','none');
set(ax, 'YTick', 1:numel(names), 'YTickLabel', names); xlabel(ax, 'Precomputed importance (synthetic)');
end
