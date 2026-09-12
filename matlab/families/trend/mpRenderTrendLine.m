function mpRenderTrendLine(contract, plan, style, data, ax)
[x, y] = mpRelationshipValues(plan, data);
x = x(:); if isvector(y), y = y(:); end
if size(y,1) ~= numel(x), error('matlab_sci_plot:MissingBinding','Each trend series must align with x.'); end
[x, order] = sort(x); y = y(order,:);
colors = [0 114 178; 230 159 0; 0 158 115; 213 94 0; 204 121 167]/255;
markers = {'o','s','^','d','v'}; lines = {'-','--','-.',':','-'}; hold(ax,'on');
for i = 1:size(y,2)
    label = sprintf('Series %d',i); if isfield(data,'group_labels'), label = char(string(data.group_labels{i})); end
    plot(ax, x, y(:,i), lines{mod(i-1,numel(lines))+1}, 'Color',colors(mod(i-1,size(colors,1))+1,:), ...
        'Marker',markers{mod(i-1,numel(markers))+1},'MarkerSize',style.geometry.marker_size_pt, ...
        'LineWidth',style.geometry.line_width_pt,'DisplayName',label);
end
hold(ax,'off');
if size(y,2) > 1, legend(ax,'Location','best','Box','off'); end
xlabel(ax, mpAxisLabel(contract, 'x', 'Ordered variable')); ylabel(ax, mpAxisLabel(contract, 'y', 'Value'));
end
