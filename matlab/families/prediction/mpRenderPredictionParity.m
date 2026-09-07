function mpRenderPredictionParity(contract, ~, style, data, ax)
% Native parity renderer; no fitted regression or interval is invented.
if ~isfield(data,'truth') || ~isfield(data,'prediction'), error('matlab_sci_plot:MissingBinding','truth and prediction are required.'); end
x = data.truth(:); y = data.prediction(:); valid = isfinite(x) & isfinite(y);
scatter(ax, x(valid), y(valid), style.geometry.marker_size_pt^2, 'filled', 'MarkerFaceColor', [0 114 178]/255); hold(ax,'on');
limits = [min([x(valid); y(valid)]), max([x(valid); y(valid)])]; plot(ax, limits, limits, '--', 'Color', [0.2 0.2 0.2], 'LineWidth', style.geometry.line_width_pt); hold(ax,'off');
xlabel(ax, 'Observed'); ylabel(ax, 'Predicted');
if isfield(contract,'uncertainty') && ~isempty(contract.uncertainty), errorbar(ax, x(valid), y(valid), data.uncertainty(valid), 'LineStyle','none'); end
end
