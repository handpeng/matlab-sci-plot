%% Template: Grouped Bar (3x1, Three Sheets)
clear; clc; close all;

%% 1. Configuration
excel_file = 'avg_loss.xlsx';
sheet_names = {'order1', 'order2', 'noorder'};
subplot_titles = {'Chained Model 1', 'Chained Model 2', 'Independent Model'};

% Expected structure per sheet: first column is group label, remaining columns are numeric series
series_names = {'Basicity', 'Temperature', 'Total'};
y_label = 'Error Value';

font_name = 'Arial';
label_fontsize = 13;
tick_fontsize = 10;
title_fontsize = 12;
legend_fontsize = 9;

use_hatchfill = false;

academic_colors = [
    0.20, 0.40, 0.60;
    0.85, 0.37, 0.01;
    0.00, 0.50, 0.30
];

fig_w = 8.0;
fig_h = 10.0;
fig = figure('Units', 'inches', 'Position', [1, 1, fig_w, fig_h], ...
    'PaperUnits', 'inches', 'PaperPosition', [0, 0, fig_w, fig_h], ...
    'PaperSize', [fig_w, fig_h], 'Color', 'w');

%% 2. Layout
n_rows = 3;
t = tiledlayout(n_rows, 1, 'TileSpacing', 'compact', 'Padding', 'compact'); %#ok<NASGU>

%% 3. Draw Each Sheet
for s = 1:n_rows
    nexttile(s);

    if s > numel(sheet_names)
        continue;
    end

    sheet_i = sheet_names{s};

    try
        tbl = readtable(excel_file, 'Sheet', sheet_i, 'VariableNamingRule', 'preserve');
    catch ME
        warning('Failed to read sheet "%s": %s', sheet_i, ME.message);
        continue;
    end

    if width(tbl) < 2 || height(tbl) < 1
        warning('Sheet "%s" has insufficient data.', sheet_i);
        continue;
    end

    group_labels = string(tbl{:, 1});
    data_matrix = table2array(tbl(:, 2:end));

    if isempty(data_matrix)
        continue;
    end

    b = bar(data_matrix, 'grouped');
    hold on;

    for k = 1:numel(b)
        color_k = academic_colors(mod(k - 1, size(academic_colors, 1)) + 1, :);
        b(k).FaceColor = color_k;
        b(k).EdgeColor = [0.20, 0.20, 0.20];
        b(k).LineWidth = 0.8;

        if use_hatchfill
            try
                hatchfill2(b(k), 'single', 'HatchAngle', 45 + (k - 1) * 20, ...
                    'HatchDensity', 70, 'HatchColor', color_k, 'HatchLineWidth', 0.45);
            catch ME
                warning('hatchfill2 unavailable for series %d: %s', k, ME.message);
            end
        end
    end

    xticks(1:numel(group_labels));
    xticklabels(group_labels);
    xtickangle(25);

    ylabel(y_label, 'FontName', font_name, 'FontSize', label_fontsize);

    if s <= numel(subplot_titles)
        title(sprintf('(%c) %s', char('a' + s - 1), subplot_titles{s}), ...
            'FontName', font_name, 'FontSize', title_fontsize, 'FontWeight', 'normal');
    else
        title(sprintf('(%c) %s', char('a' + s - 1), sheet_i), ...
            'FontName', font_name, 'FontSize', title_fontsize, 'FontWeight', 'normal');
    end

    if s == 1
        n_series = size(data_matrix, 2);
        legend_text = series_names;
        if numel(series_names) ~= n_series
            legend_text = arrayfun(@(i) sprintf('Series %d', i), 1:n_series, 'UniformOutput', false);
        end
        legend(legend_text, 'Location', 'northwest', 'Box', 'off', ...
            'FontName', font_name, 'FontSize', legend_fontsize);
    end

    % Numeric labels
    for i = 1:size(data_matrix, 1)
        for j = 1:size(data_matrix, 2)
            val = data_matrix(i, j);
            if ~isfinite(val)
                continue;
            end
            x_j = b(j).XEndPoints(i);
            y_j = b(j).YEndPoints(i);
            text(x_j, y_j, sprintf('%.3f', val), 'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'bottom', 'FontName', font_name, 'FontSize', tick_fontsize - 1);
        end
    end

    hold off;

    grid on;
    set(gca, 'FontName', font_name, 'FontSize', tick_fontsize, 'LineWidth', 1.0, ...
        'TickDir', 'in', 'TickLength', [0.01, 0.01], 'GridLineStyle', ':', ...
        'GridColor', [0.6, 0.6, 0.6], 'GridAlpha', 0.3, 'Box', 'on');
    ytickformat('%.2f');
end

%% 4. Export (Optional)
% print(fig, 'grouped_bar_3x1.eps', '-depsc', '-tiff');
% print(fig, 'grouped_bar_3x1.png', '-dpng', '-r300');
% print(fig, 'grouped_bar_3x1.pdf', '-dpdf', '-vector');

%% Usage Notes
% 1. First column in each sheet should be category labels.
% 2. Remaining columns are plotted as grouped bars in each panel.
% 3. Set use_hatchfill=true to apply hatch textures (optional dependency).
