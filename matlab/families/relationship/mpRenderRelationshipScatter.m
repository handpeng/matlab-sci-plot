function mpRenderRelationshipScatter(~, ~, style, data, ax)
if ~isfield(data,'x') || ~isfield(data,'y'), error('matlab_sci_plot:MissingBinding','x and y are required.'); end
valid = isfinite(data.x(:)) & isfinite(data.y(:));
scatter(ax, data.x(valid), data.y(valid), style.geometry.marker_size_pt^2, 'filled', 'MarkerFaceColor', [0 158 115]/255);
xlabel(ax, 'X'); ylabel(ax, 'Y');
end
