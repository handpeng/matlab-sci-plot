function mpRenderDistributionHistogram(~, ~, style, data, ax)
if ~isfield(data,'values'), error('matlab_sci_plot:MissingBinding','values are required.'); end
histogram(ax, data.values, 'FaceColor', [86 180 233]/255, 'EdgeColor','none');
xlabel(ax, 'Value'); ylabel(ax, 'Count');
if isfield(style.axes,'grid') && strcmp(style.axes.grid,'on'), grid(ax,'on'); end
end
