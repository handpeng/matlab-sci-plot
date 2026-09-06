%% Template: Error Histogram + Scatter Regression (4x2)
clear; clc; close all;

%% 1. Configuration
data_files = {'predictor_CaO.xlsx', 'predictor_SiO2.xlsx', 'predictor_FeO.xlsx', 'predictor_MgO.xlsx'};
component_names = {'CaO', 'SiO2', 'FeO', 'MgO'};
component_colors = [
    0.20, 0.60, 0.20;
    0.80, 0.80, 0.20;
    0.80, 0.40, 0.40;
    0.40, 0.80, 0.40
];

true_column = 'y_true';
pred_column = 'Proposed';

font_name = 'Times New Roman';
label_fontsize = 12;
tick_fontsize = 10;
legend_fontsize = 9;
title_fontsize = 11;

hist_bins = 30;
line_width = 1.5;

fig = figure('Units', 'inches', 'Position', [0, 0, 9, 11.69], 'Color', 'w');

%% 2. Layout
use_tight_subplot = (exist('tight_subplot', 'file') == 2);
if use_tight_subplot
    ha = tight_subplot(4, 2, [0.06, 0.08], [0.10, 0.08], [0.10, 0.08]);
else
    tiledlayout(4, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
end

%% 3. Plot Each Component
for i = 1:4
    if i > numel(data_files)
        break;
    end

    comp_name = component_names{min(i, numel(component_names))};
    comp_color = component_colors(min(i, size(component_colors, 1)), :);

    try
        tbl = readtable(data_files{i}, 'VariableNamingRule', 'preserve');
    catch ME
        warning('Failed to read %s: %s', data_files{i}, ME.message);
        continue;
    end

    if ~ismember(true_column, tbl.Properties.VariableNames) || ~ismember(pred_column, tbl.Properties.VariableNames)
        warning('File %s is missing required columns.', data_files{i});
        continue;
    end

    y_true = tbl.(true_column);
    y_pred = tbl.(pred_column);

    valid_mask = ~isnan(y_true) & ~isnan(y_pred);
    y_true = y_true(valid_mask);
    y_pred = y_pred(valid_mask);

    if numel(y_true) < 5
        warning('File %s has insufficient valid data.', data_files{i});
        continue;
    end

    abs_err = abs(y_true - y_pred);

    % Left: histogram
    panel_hist = 2 * i - 1;
    if use_tight_subplot
        axes(ha(panel_hist));
    else
        nexttile(panel_hist);
    end

    histogram(abs_err, hist_bins, 'Normalization', 'probability', ...
        'FaceColor', comp_color, 'EdgeColor', 'k', 'LineWidth', 1.0, ...
        'DisplayName', comp_name);

    xlabel('Absolute Error', 'FontName', font_name, 'FontSize', label_fontsize);
    ylabel('Probability', 'FontName', font_name, 'FontSize', label_fontsize);
    title(sprintf('(%c) %s Error Distribution', char('a' + panel_hist - 1), comp_name), ...
        'FontName', font_name, 'FontSize', title_fontsize, 'FontWeight', 'normal');
    legend('Location', 'best', 'FontName', font_name, 'FontSize', legend_fontsize, 'Box', 'on');

    grid on;
    set(gca, 'FontName', font_name, 'FontSize', tick_fontsize, 'LineWidth', 1.0, ...
        'TickDir', 'in', 'TickLength', [0.01, 0.01], 'GridLineStyle', '--', ...
        'GridColor', [0.5, 0.5, 0.5], 'GridAlpha', 0.3, 'Box', 'off');
    ytickformat('%.2f');

    if use_tight_subplot
        add_top_right_border(gca);
    end

    % Right: scatter + regression
    panel_scatter = 2 * i;
    if use_tight_subplot
        axes(ha(panel_scatter));
    else
        nexttile(panel_scatter);
    end

    scatter(y_true, y_pred, 36, 'filled', ...
        'MarkerFaceColor', comp_color, 'MarkerEdgeColor', [0.1, 0.1, 0.1], ...
        'LineWidth', 0.8, 'DisplayName', comp_name);
    hold on;

    x_line = linspace(min(y_true), max(y_true), 100);
    h_ref = plot(x_line, x_line, '--', 'Color', [0.25, 0.25, 0.25], ...
        'LineWidth', 1.2, 'DisplayName', 'y = x');

    if exist('fitlm', 'file') == 2
        mdl = fitlm(y_true, y_pred);
        [y_fit, y_ci] = predict(mdl, x_line', 'Prediction', 'curve');
        h_band = fill([x_line, fliplr(x_line)], [y_ci(:, 1)', fliplr(y_ci(:, 2)')], ...
            comp_color, 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'DisplayName', '95% Confidence Band');
        h_reg = plot(x_line, y_fit, '-', 'Color', [0.1, 0.1, 0.1], ...
            'LineWidth', line_width, 'DisplayName', 'Regression');
        legend([h_ref, h_reg, h_band], {'y = x', 'Regression', '95% Confidence Band'}, ...
            'Location', 'northwest', 'FontName', font_name, 'FontSize', legend_fontsize, 'Box', 'on');
    else
        p = polyfit(y_true, y_pred, 1);
        y_fit = polyval(p, x_line);
        h_reg = plot(x_line, y_fit, '-', 'Color', [0.1, 0.1, 0.1], ...
            'LineWidth', line_width, 'DisplayName', 'Regression');
        legend([h_ref, h_reg], {'y = x', 'Regression'}, ...
            'Location', 'northwest', 'FontName', font_name, 'FontSize', legend_fontsize, 'Box', 'on');
    end

    hold off;

    xlabel('True Value', 'FontName', font_name, 'FontSize', label_fontsize);
    ylabel('Predicted Value', 'FontName', font_name, 'FontSize', label_fontsize);
    title(sprintf('(%c) %s True vs Predicted', char('a' + panel_scatter - 1), comp_name), ...
        'FontName', font_name, 'FontSize', title_fontsize, 'FontWeight', 'normal');

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
% print(fig, 'error_hist_scatter.eps', '-depsc', '-tiff');
% print(fig, 'error_hist_scatter.png', '-dpng', '-r300');
% print(fig, 'error_hist_scatter.pdf', '-dpdf', '-vector');

%% Usage Notes
% 1. Each file should include true_column and pred_column.
% 2. Left panel: absolute error histogram. Right panel: regression scatter.
% 3. For journal consistency, all labels and legends remain in English.

function add_top_right_border(ax)
pos = get(ax, 'Position');
axes('Position', pos, 'XAxisLocation', 'top', 'YAxisLocation', 'right', ...
    'Color', 'none', 'XTick', [], 'YTick', [], 'Box', 'on', 'LineWidth', 1.0);
end
