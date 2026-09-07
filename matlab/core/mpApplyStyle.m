function mpApplyStyle(ax, style)
% Apply resolved presentation state; scientific constraints are not mutable.
set(ax, 'FontName', style.typography.font_name, 'FontSize', style.typography.resolved_pt, ...
    'LineWidth', style.geometry.line_width_pt, 'TickDir', 'out', 'Box', 'off');
if strcmp(style.axes.grid, 'on'), grid(ax, 'on'); else, grid(ax, 'off'); end
end
