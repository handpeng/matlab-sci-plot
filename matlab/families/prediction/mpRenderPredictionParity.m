function mpRenderPredictionParity(contract, ~, style, data, ax)
% Native parity renderer; no fitted regression or interval is invented.
if ~isfield(data,'truth') || ~isfield(data,'prediction'), error('matlab_sci_plot:MissingBinding','truth and prediction are required.'); end
x = data.truth(:); y = data.prediction(:); valid = isfinite(x) & isfinite(y);
if ~any(valid), error('matlab_sci_plot:NoCompleteSamples','No common complete samples are available.'); end
scatter(ax, x(valid), y(valid), style.geometry.marker_size_pt^2, 'filled', 'MarkerFaceColor', [0 114 178]/255); hold(ax,'on');
limits = [min([x(valid); y(valid)]), max([x(valid); y(valid)])]; span = max(diff(limits), eps); limits = limits + [-1 1]*0.04*span;
plot(ax, limits, limits, '--', 'Color', [0.2 0.2 0.2], 'LineWidth', style.geometry.line_width_pt); hold(ax,'off');
xlim(ax, limits); ylim(ax, limits); axis(ax, 'square');
xlabel(ax, mpAxisLabel(contract, 'truth', 'Observed')); ylabel(ax, mpAxisLabel(contract, 'prediction', 'Predicted'));
if isfield(data, 'metrics'), metrics = data.metrics; else, metrics = mpDescriptiveMetrics(x, y); end
summary = sprintf('R^2 = %.3f\nMAE = %.2f\nRMSE = %.2f\nn = %d', metrics.r2, metrics.mae, metrics.rmse, metrics.n_common);
text(ax, 0.04, 0.96, summary, 'Units','normalized','VerticalAlignment','top','FontName',style.typography.font_name,'FontSize',style.typography.resolved_pt);
if isfield(contract,'uncertainty') && ~isempty(contract.uncertainty), errorbar(ax, x(valid), y(valid), data.uncertainty(valid), 'LineStyle','none'); end
end
