%% Template: Ablation Scatter (2x2)
clear; clc; close all;

%% 1. Configuration
excel_file = 'ablation_experiment.xlsx';
sheet_names = {'CaO', 'SiO2', 'FeO', 'MgO'};
y_labels = {'Score Value y_1', 'Score Value y_2', 'Score Value y_3', 'Score Value y_4'};

highlight_mode = 'min'; % 'min' or 'max'

font_name = 'Times New Roman';
label_fontsize = 14;
tick_fontsize = 11;
title_fontsize = 12;

color_scatter = [0.30, 0.60, 1.00];
color_best_point = [1.00, 0.00, 0.00];
marker_size = 90;
best_marker_size = 150;

fig = figure('Position', [100, 100, 1600, 800], 'Color', 'w');

%% 2. Create Layout
use_tight_subplot = (exist('tight_subplot', 'file') == 2);
if use_tight_subplot
    ha = tight_subplot(2, 2, [0.10, 0.05], [0.10, 0.10], [0.10, 0.10]);
else
    tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
end

%% 3. Plot Panels
for i = 1:4
    if use_tight_subplot
        axes(ha(i));
    else
        nexttile(i);
    end

    if i > numel(sheet_names)
        continue;
    end

    sheet_i = sheet_names{i};

    try
        data_table = readtable(excel_file, 'Sheet', sheet_i, 'VariableNamingRule', 'preserve');
    catch ME
        warning('Failed to read sheet "%s": %s', sheet_i, ME.message);
        title(sprintf('(%c) %s (Missing)', char('a' + i - 1), sheet_i), ...
            'FontName', font_name, 'FontSize', title_fontsize, 'FontWeight', 'normal');
        continue;
    end

    if width(data_table) < 2 || height(data_table) < 1
        warning('Sheet "%s" has insufficient data.', sheet_i);
        continue;
    end

    x_raw = data_table{:, 1};
    y = data_table{:, 2};

    valid_mask = ~isnan(y);
    x_raw = x_raw(valid_mask);
    y = y(valid_mask);

    if isempty(y)
        warning('Sheet "%s" has no valid numeric values.', sheet_i);
        continue;
    end

    x_cat = categorical(string(x_raw));

    scatter(x_cat, y, marker_size, 'filled', ...
        'MarkerFaceColor', color_scatter, 'MarkerEdgeColor', [0.1, 0.1, 0.1], ...
        'LineWidth', 1.0, 'DisplayName', 'Ablation Settings');
    hold on;

    if strcmpi(highlight_mode, 'max')
        [best_y, best_idx] = max(y);
    else
        [best_y, best_idx] = min(y);
    end

    scatter(x_cat(best_idx), best_y, best_marker_size, 'filled', ...
        'MarkerFaceColor', color_best_point, 'MarkerEdgeColor', 'k', ...
        'LineWidth', 1.2, 'DisplayName', 'Best Setting');
    hold off;

    if i <= numel(y_labels)
        ylabel(y_labels{i}, 'FontName', font_name, 'FontSize', label_fontsize);
    else
        ylabel('Score Value', 'FontName', font_name, 'FontSize', label_fontsize);
    end

    title(sprintf('(%c) %s', char('a' + i - 1), sheet_i), ...
        'FontName', font_name, 'FontSize', title_fontsize, 'FontWeight', 'normal');

    legend('Location', 'best', 'FontName', font_name, 'FontSize', tick_fontsize - 1, 'Box', 'on');

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
% print(fig, 'ablation_scatter.eps', '-depsc', '-tiff');
% print(fig, 'ablation_scatter.png', '-dpng', '-r300');
% print(fig, 'ablation_scatter.pdf', '-dpdf', '-vector');

%% Usage Notes
% 1. Each sheet must contain at least two columns: setting and score.
% 2. highlight_mode controls whether min or max value is emphasized.
% 3. This template follows 2x2 panel style for ablation reporting.

function add_top_right_border(ax)
pos = get(ax, 'Position');
axes('Position', pos, 'XAxisLocation', 'top', 'YAxisLocation', 'right', ...
    'Color', 'none', 'XTick', [], 'YTick', [], 'Box', 'on', 'LineWidth', 1.0);
end
