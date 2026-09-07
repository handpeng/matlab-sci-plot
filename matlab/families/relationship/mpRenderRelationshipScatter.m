function mpRenderRelationshipScatter(contract, ~, style, data, ax)
if ~isfield(data,'x') || ~isfield(data,'y'), error('matlab_sci_plot:MissingBinding','x and y are required.'); end
valid = isfinite(data.x(:)) & isfinite(data.y(:));
if isfield(data, 'group')
    groups = string(data.group(:)); groupIds = unique(groups(valid), 'stable');
    colors = [0 114 178; 230 159 0; 0 158 115; 213 94 0; 204 121 167; 86 180 233; 0 0 0]/255;
    markers = {'o','s','^','d','v','>','p'}; hold(ax,'on');
    for i = 1:numel(groupIds)
        take = valid & groups == groupIds(i);
        scatter(ax, data.x(take), data.y(take), style.geometry.marker_size_pt^2, ...
            markers{mod(i-1,numel(markers))+1}, 'filled', 'MarkerFaceColor', colors(mod(i-1,size(colors,1))+1,:), ...
            'MarkerFaceAlpha',0.65,'DisplayName',char(groupIds(i)));
    end
    hold(ax,'off'); legend(ax,'Location','best','Box','off');
else
    scatter(ax, data.x(valid), data.y(valid), style.geometry.marker_size_pt^2, 'filled', ...
        'MarkerFaceColor', [0 158 115]/255, 'MarkerFaceAlpha',0.65);
end
xlabel(ax, mpAxisLabel(contract, 'x', 'X')); ylabel(ax, mpAxisLabel(contract, 'y', 'Y'));
end
