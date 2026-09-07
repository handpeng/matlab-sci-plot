function mpRenderComparisonMetricPanels(~, ~, style, data, ax)
if ~isfield(data,'values') || ~isfield(data,'labels'), error('matlab_sci_plot:MissingBinding','values and labels are required.'); end
bar(ax, data.values, 'FaceColor', [0 114 178]/255, 'EdgeColor','none');
set(ax, 'XTick', 1:numel(data.values), 'XTickLabel', data.labels); ylabel(ax, 'Metric');
if min(data.values) < 0, yline(ax, 0, '-', 'Color', [0.2 0.2 0.2], 'LineWidth', style.geometry.line_width_pt); end
end
