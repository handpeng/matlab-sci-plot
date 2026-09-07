function mpRenderExplainability(~, ~, style, data, ax)
if ~isfield(data,'feature_names') || ~isfield(data,'importance'), error('matlab_sci_plot:MissingBinding','precomputed feature names and importance are required.'); end
barh(ax, data.importance, 'FaceColor', [0 158 115]/255, 'EdgeColor','none');
set(ax, 'YTick', 1:numel(data.feature_names), 'YTickLabel', data.feature_names); xlabel(ax, 'Precomputed importance');
end
