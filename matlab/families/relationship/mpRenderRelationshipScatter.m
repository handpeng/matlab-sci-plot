function mpRenderRelationshipScatter(contract, plan, style, data, ax)
[x, y] = mpRelationshipValues(plan, data);
valid = isfinite(x(:)) & isfinite(y(:));
if isfield(data, 'group')
    groups = string(data.group(:)); groupIds = unique(groups(valid), 'stable');
    colors = [0 114 178; 230 159 0; 0 158 115; 213 94 0; 204 121 167; 86 180 233; 0 0 0]/255;
    markers = {'o','s','^','d','v','>','p'}; hold(ax,'on');
    for i = 1:numel(groupIds)
        take = valid & groups == groupIds(i);
        scatter(ax, x(take), y(take), style.geometry.marker_size_pt^2, ...
            markers{mod(i-1,numel(markers))+1}, 'filled', 'MarkerFaceColor', colors(mod(i-1,size(colors,1))+1,:), ...
            'MarkerFaceAlpha',0.65,'DisplayName',char(groupIds(i)));
    end
    hold(ax,'off'); legend(ax,'Location','best','Box','off');
else
    scatter(ax, x(valid), y(valid), style.geometry.marker_size_pt^2, 'filled', ...
        'MarkerFaceColor', [0 158 115]/255, 'MarkerFaceAlpha',0.65);
end
xlabel(ax, mpAxisLabel(contract, 'x', 'X')); ylabel(ax, mpAxisLabel(contract, 'y', 'Y'));
if isfield(contract,'annotation_roles')
    annotations = {};
    roles = cellstr(string(contract.annotation_roles));
    for i = 1:numel(roles)
        if isfield(data,roles{i})
            annotations{end+1} = sprintf('%s = %s',roles{i},char(string(data.(roles{i})))); %#ok<AGROW>
        end
    end
    if ~isempty(annotations)
        text(ax,0.04,0.96,strjoin(annotations,newline),'Units','normalized', ...
            'VerticalAlignment','top','FontName',style.typography.font_name, ...
            'FontSize',style.typography.resolved_pt);
    end
end
end
