%% Template: Bar + Line Overlay (2x2)
clear; clc; close all;

%% 1. Configuration
excel_file = 'comparison_experiment.xlsx';
sheet_name = 'Total';
model_column = 'model';

metric_columns = {'y1', 'y2', 'y3', 'y4'};
metric_labels = {'Score Value y_1', 'Score Value y_2', 'Score Value y_3', 'Score Value y_4'};

invert_metric_sign = true;

font_name = 'Times New Roman';
label_fontsize = 14;
tick_fontsize = 11;
title_fontsize = 12;

line_width = 1.5;
bar_alpha = 0.65;

bar_colors = [
    0.90, 0.35, 0.30;
    0.25, 0.70, 0.35;
    0.25, 0.45, 0.90;
    0.30, 0.75, 0.80
];
line_color = [0.25, 0.25, 0.25];

fig = figure('Position', [100, 100, 1600, 800], 'Color', 'w');

%% 2. Read Data
try
    data_table = readtable(excel_file, 'Sheet', sheet_name, 'VariableNamingRule', 'preserve');
catch ME
    error('Failed to read Excel file: %s', ME.message);
end

if ~ismember(model_column, data_table.Properties.VariableNames)
    error('Model column "%s" was not found.', model_column);
end

x_labels = string(data_table.(model_column));
x_pos = 1:numel(x_labels);

use_tight_subplot = (exist('tight_subplot', 'file') == 2);
if use_tight_subplot
    ha = tight_subplot(2, 2, [0.10, 0.05], [0.10, 0.10], [0.10, 0.10]);
else
    tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
end

%% 3. Plot 2x2 Panels
for i = 1:4
    if use_tight_subplot
        axes(ha(i));
    else
        nexttile(i);
    end

    if i > numel(metric_columns)
        continue;
    end

    col_i = metric_columns{i};
    if ~ismember(col_i, data_table.Properties.VariableNames)
        warning('Metric column "%s" not found. Skipped.', col_i);
        continue;
    end

    y = data_table.(col_i);
    if invert_metric_sign
        y = -y;
    end

    valid_mask = ~isnan(y);
    x_plot = x_pos(valid_mask);
    y_plot = y(valid_mask);

    if isempty(y_plot)
        continue;
    end

    hold on;
    h_bar = bar(x_plot, y_plot, 0.72, ...
        'FaceColor', bar_colors(min(i, size(bar_colors, 1)), :), ...
        'EdgeColor', 'k', 'FaceAlpha', bar_alpha, 'LineWidth', 0.6, ...
        'DisplayName', 'Bar');

    % Optional hatch fill
    try
        hatchfill2(h_bar, 'single', 'HatchAngle', 45, 'HatchDensity', 70, ...
            'HatchColor', [0.2, 0.2, 0.2], 'HatchLineWidth', 0.45);
    catch ME
        warning('hatchfill2 not available in panel %d: %s', i, ME.message);
    end

    h_line = plot(x_plot, y_plot, '-o', 'Color', line_color, ...
        'LineWidth', line_width, 'MarkerSize', 5, 'MarkerFaceColor', [0.85, 0.85, 0.85], ...
        'DisplayName', 'Line');
    hold off;

    if i <= numel(metric_labels)
        ylabel(metric_labels{i}, 'FontName', font_name, 'FontSize', label_fontsize);
    else
        ylabel('Metric Value', 'FontName', font_name, 'FontSize', label_fontsize);
    end

    title(sprintf('(%c) %s', char('a' + i - 1), strrep(col_i, '_', '\_')), ...
        'FontName', font_name, 'FontSize', title_fontsize, 'FontWeight', 'normal');

    xticks(x_pos);
    xticklabels(x_labels);
    xtickangle(30);

    y_min = min(y_plot);
    y_max = max(y_plot);
    y_pad = max((y_max - y_min) * 0.1, 1e-3);
    ylim([y_min - y_pad, y_max + y_pad]);

    legend([h_bar, h_line], {'Bar', 'Line'}, ...
        'Location', 'best', 'FontName', font_name, 'FontSize', tick_fontsize - 1, 'Box', 'on');

    grid on;
    set(gca, 'FontName', font_name, 'FontSize', tick_fontsize, 'LineWidth', 1.0, ...
        'TickDir', 'in', 'TickLength', [0.01, 0.01], 'GridLineStyle', '--', ...
        'GridColor', [0.5, 0.5, 0.5], 'GridAlpha', 0.3, 'Box', 'off');
    ytickformat('%.2f');

    if use_tight_subplot
        add_top_right_border(gca);
    end
end

%% 4. Export (Optional)
% print(fig, 'bar_line_2x2.eps', '-depsc', '-tiff');
% print(fig, 'bar_line_2x2.png', '-dpng', '-r300');
% print(fig, 'bar_line_2x2.pdf', '-dpdf', '-vector');

%% Usage Notes
% 1. model_column should contain model names used for x-axis tick labels.
% 2. Set invert_metric_sign=false if your metrics should not be negated.
% 3. hatchfill2 is optional; the script still runs without it.

function add_top_right_border(ax)
pos = get(ax, 'Position');
axes('Position', pos, 'XAxisLocation', 'top', 'YAxisLocation', 'right', ...
    'Color', 'none', 'XTick', [], 'YTick', [], 'Box', 'on', 'LineWidth', 1.0);
end
