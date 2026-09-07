function mpRenderDistributionHistogram(contract, ~, style, data, ax)
if ~isfield(data,'values'), error('matlab_sci_plot:MissingBinding','values are required.'); end
values = data.values(isfinite(data.values));
args = {'FaceColor',[86 180 233]/255,'EdgeColor','none'};
if isfield(data,'bin_count'), histogram(ax, values, data.bin_count, args{:}); else, histogram(ax, values, args{:}); end
hold(ax,'on'); xline(ax,0,'--','Color',[0.25 0.25 0.25],'LineWidth',style.geometry.line_width_pt); hold(ax,'off');
xlabel(ax, mpAxisLabel(contract, 'value', 'Value')); ylabel(ax, 'Count');
text(ax,0.96,0.94,sprintf('n = %d',numel(values)),'Units','normalized','HorizontalAlignment','right','VerticalAlignment','top','FontSize',style.typography.resolved_pt);
if isfield(style.axes,'grid') && strcmp(style.axes.grid,'on'), grid(ax,'on'); end
end
