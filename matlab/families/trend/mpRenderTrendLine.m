function mpRenderTrendLine(~, ~, style, data, ax)
if ~isfield(data,'x') || ~isfield(data,'y'), error('matlab_sci_plot:MissingBinding','x and y are required.'); end
valid = isfinite(data.x(:)) & isfinite(data.y(:)); [x, order] = sort(data.x(valid)); y = data.y(valid); y = y(order);
plot(ax, x, y, '-', 'Color', [0 114 178]/255, 'LineWidth', style.geometry.line_width_pt);
xlabel(ax, 'Ordered Variable'); ylabel(ax, 'Value');
end
