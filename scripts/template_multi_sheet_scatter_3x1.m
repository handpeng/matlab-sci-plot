%% Template: Multi-Sheet Scatter (3x1)
clear; clc; close all;

%% 1. Configuration
excel_file = 'error.xlsx';
sheet_names = {'order1', 'order2', 'noorder'};
subplot_titles = {'Chained Model 1', 'Chained Model 2', 'Independent Model'};

font_name = 'Times New Roman';
label_fontsize = 13;
tick_fontsize = 10;
legend_fontsize = 9;
title_fontsize = 12;

marker_size = 50;
line_width = 1.0;

marker_types = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '*', '+', 'x'};
color_scheme = [
    0.00, 0.45, 0.74;
    0.85, 0.33, 0.10;
    0.93, 0.69, 0.13;
    0.49, 0.18, 0.56;
    0.47, 0.67, 0.19;
    0.30, 0.75, 0.93;
    0.64, 0.08, 0.18
];

fig = figure('Position', [100, 100, 1400, 1000], 'Color', 'w', ...
    'PaperPositionMode', 'auto', 'Renderer', 'painters');

%% 2. Layout
t = tiledlayout(3, 1, 'TileSpacing', 'compact', 'Padding', 'compact'); %#ok<NASGU>

%% 3. Draw Panels
for idx = 1:min(3, numel(sheet_names))
    nexttile(idx);

    try
        tbl = readtable(excel_file, 'Sheet', sheet_names{idx}, 'VariableNamingRule', 'preserve');
    catch ME
        warning('Failed to read sheet "%s": %s', sheet_names{idx}, ME.message);
        continue;
    end

    if height(tbl) < 1 || width(tbl) < 1
        warning('Sheet "%s" has insufficient data.', sheet_names{idx});
        continue;
    end

    n_samples = height(tbl);
    x = 1:n_samples;
    n_series = width(tbl);

    hold on;
    handles = gobjects(1, n_series);
    labels = cell(1, n_series);

    for s = 1:n_series
        y = tbl{:, s};
        if ~isnumeric(y)
            continue;
        end

        valid_mask = ~isnan(y);
        if nnz(valid_mask) < 2
            continue;
        end

        marker_i = marker_types{mod(s - 1, numel(marker_types)) + 1};
        color_i = color_scheme(mod(s - 1, size(color_scheme, 1)) + 1, :);

        handles(s) = scatter(x(valid_mask), y(valid_mask), marker_size, ...
            'Marker', marker_i, ...
            'MarkerEdgeColor', color_i, ...
            'MarkerFaceColor', color_i, ...
            'MarkerFaceAlpha', 0.60, ...
            'MarkerEdgeAlpha', 0.90, ...
            'LineWidth', line_width);

        labels{s} = strrep(tbl.Properties.VariableNames{s}, '_', ' ');
    end
    hold off;

    valid_handles = isgraphics(handles);
    if any(valid_handles)
        legend(handles(valid_handles), labels(valid_handles), ...
            'Location', 'bestoutside', 'FontName', font_name, ...
            'FontSize', legend_fontsize, 'Box', 'on');
    end

    xlabel('Sample Index', 'FontName', font_name, 'FontSize', label_fontsize);
    ylabel('Value', 'FontName', font_name, 'FontSize', label_fontsize);

    if idx <= numel(subplot_titles)
        title(sprintf('(%c) %s', char('a' + idx - 1), subplot_titles{idx}), ...
            'FontName', font_name, 'FontSize', title_fontsize, 'FontWeight', 'normal');
    else
        title(sprintf('(%c) %s', char('a' + idx - 1), sheet_names{idx}), ...
            'FontName', font_name, 'FontSize', title_fontsize, 'FontWeight', 'normal');
    end

    xlim([0.5, n_samples + 0.5]);

    grid on;
    grid minor;
    set(gca, 'FontName', font_name, 'FontSize', tick_fontsize, 'LineWidth', 1.0, ...
        'TickDir', 'in', 'TickLength', [0.01, 0.01], 'Box', 'on', 'Layer', 'top', ...
        'GridColor', [0.15, 0.15, 0.15], 'GridLineStyle', '-', 'GridAlpha', 0.15, ...
        'MinorGridColor', [0.1, 0.1, 0.1], 'MinorGridAlpha', 0.05, 'MinorGridLineStyle', ':');
    ytickformat('%.2f');
end

%% 4. Export (Optional)
% print(fig, 'multi_sheet_scatter_3x1.eps', '-depsc', '-tiff');
% print(fig, 'multi_sheet_scatter_3x1.png', '-dpng', '-r300');
% print(fig, 'multi_sheet_scatter_3x1.pdf', '-dpdf', '-vector');

%% Usage Notes
% 1. Each sheet is treated as one panel in a 3x1 layout.
% 2. All numeric columns in each sheet are drawn as scatter series.
% 3. Useful for multi-scenario residual or sample-level error visualization.
