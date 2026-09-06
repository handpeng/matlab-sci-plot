%% Template: Feature Importance (1x4 Horizontal Bar)
clear; clc; close all;

%% 1. Configuration
excel_file = 'feature_importance.xlsx';
sheet_name = 'Sheet1';
feature_column = 'Var1';

target_columns = {'CaO', 'SiO2', 'FeO', 'MgO'};
y_labels = {'Feature Importance of y_1', 'Feature Importance of y_2', ...
            'Feature Importance of y_3', 'Feature Importance of y_4'};

font_name = 'Times New Roman';
label_fontsize = 14;
tick_fontsize = 11;
title_fontsize = 12;

bar_colors = [
    0.90, 0.30, 0.30;
    0.25, 0.70, 0.35;
    0.25, 0.45, 0.90;
    0.30, 0.75, 0.80
];

fig_w = (21.0 * 1.65) / 2.54;
fig_h = (29.7 * 0.35) / 2.54;
fig = figure('Units', 'inches', 'Position', [1, 1, fig_w, fig_h], ...
    'PaperUnits', 'inches', 'PaperPosition', [0, 0, fig_w, fig_h], ...
    'PaperSize', [fig_w, fig_h], 'Color', 'w');

%% 2. Read and Validate Data
try
    data_table = readtable(excel_file, 'Sheet', sheet_name, 'VariableNamingRule', 'preserve');
catch ME
    error('Failed to read Excel file: %s', ME.message);
end

if ~ismember(feature_column, data_table.Properties.VariableNames)
    error('Feature column "%s" was not found.', feature_column);
end

feature_names = string(data_table.(feature_column));

n_panels = min(4, numel(target_columns));
t = tiledlayout(1, 4, 'Padding', 'compact', 'TileSpacing', 'compact'); %#ok<NASGU>

%% 3. Plot Panels
for i = 1:n_panels
    nexttile(i);

    col_i = target_columns{i};
    if ~ismember(col_i, data_table.Properties.VariableNames)
        warning('Column "%s" not found. Skipped.', col_i);
        continue;
    end

    y = data_table.(col_i);
    valid_mask = ~isnan(y);
    y = y(valid_mask);
    features_i = feature_names(valid_mask);

    if isempty(y)
        continue;
    end

    barh(y, 'FaceColor', bar_colors(min(i, size(bar_colors, 1)), :), ...
        'EdgeColor', 'k', 'LineWidth', 0.6);

    set(gca, 'YDir', 'reverse');
    yticks(1:numel(features_i));
    yticklabels(strrep(features_i, '_', '\_'));

    xlabel('Importance Score', 'FontName', font_name, 'FontSize', label_fontsize);
    if i <= numel(y_labels)
        ylabel(y_labels{i}, 'FontName', font_name, 'FontSize', label_fontsize);
    else
        ylabel('Feature Importance', 'FontName', font_name, 'FontSize', label_fontsize);
    end

    title(sprintf('(%c) %s', char('a' + i - 1), strrep(col_i, '_', '\_')), ...
        'FontName', font_name, 'FontSize', title_fontsize, 'FontWeight', 'normal');

    grid on;
    set(gca, 'FontName', font_name, 'FontSize', tick_fontsize, 'LineWidth', 1.0, ...
        'TickDir', 'in', 'TickLength', [0.01, 0.01], 'GridLineStyle', '--', ...
        'GridColor', [0.5, 0.5, 0.5], 'GridAlpha', 0.3, 'Box', 'off');
    xtickformat('%.2f');

    add_top_right_border(gca);
end

%% 4. Export (Optional)
% print(fig, 'feature_importance_barh.eps', '-depsc', '-tiff');
% print(fig, 'feature_importance_barh.png', '-dpng', '-r300');
% print(fig, 'feature_importance_barh.pdf', '-dpdf', '-vector');

%% Usage Notes
% 1. feature_column should contain feature names.
% 2. target_columns are plotted as four horizontal-bar panels.
% 3. This template is suitable for feature attribution summaries.

function add_top_right_border(ax)
pos = get(ax, 'Position');
axes('Position', pos, 'XAxisLocation', 'top', 'YAxisLocation', 'right', ...
    'Color', 'none', 'XTick', [], 'YTick', [], 'Box', 'on', 'LineWidth', 1.0);
end
