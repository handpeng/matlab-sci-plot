%% Template: Scatter + Regression + Confidence Band (3x2)
clear; clc; close all;

%% 1. Configuration
excel_file = 'data_stack5_predict.xlsx';
sheet_name = 'Sheet1';
true_column = 'y_true';

prediction_columns = {'Model_A', 'Model_B', 'Model_C', 'Model_D', 'Model_E', 'Model_F'};
prediction_labels = {'Model A', 'Model B', 'Model C', 'Model D', 'Model E', 'Model F'};

font_name = 'Times New Roman';
label_fontsize = 14;
tick_fontsize = 11;
legend_fontsize = 10;
title_fontsize = 12;

color_prediction = [0.85, 0.33, 0.10];
color_scatter = [0.30, 0.60, 1.00];
marker_size = 80;
edge_line_width = 1.0;

line_width_solid = 1.5;
line_width_dashed = 1.5;

n_rows = 3;
n_cols = 2;

fig = figure('Units', 'inches', 'Position', [0, 0, 8.27, 11.69], 'Color', 'w');

%% 2. Read and Validate Data
try
    data_table = readtable(excel_file, 'Sheet', sheet_name);
catch ME
    error('Failed to read Excel file: %s', ME.message);
end

if ~ismember(true_column, data_table.Properties.VariableNames)
    error('Column "%s" was not found.', true_column);
end

y_true = data_table.(true_column);

valid_columns = {};
valid_labels = {};
for i = 1:numel(prediction_columns)
    col_i = prediction_columns{i};
    if ismember(col_i, data_table.Properties.VariableNames)
        valid_columns{end + 1} = col_i; %#ok<AGROW>
        if i <= numel(prediction_labels)
            valid_labels{end + 1} = prediction_labels{i}; %#ok<AGROW>
        else
            valid_labels{end + 1} = col_i; %#ok<AGROW>
        end
    else
        warning('Column "%s" not found. Skipped.', col_i);
    end
end

if isempty(valid_columns)
    error('No valid prediction columns were found.');
end

n_panels = min(numel(valid_columns), n_rows * n_cols);

use_tight_subplot = (exist('tight_subplot', 'file') == 2);
if use_tight_subplot
    ha = tight_subplot(n_rows, n_cols, [0.06, 0.08], [0.08, 0.06], [0.08, 0.05]);
else
    tiledlayout(n_rows, n_cols, 'Padding', 'compact', 'TileSpacing', 'compact');
end

for i = 1:n_panels
    if use_tight_subplot
        axes(ha(i));
    else
        nexttile(i);
    end

    y_pred = data_table.(valid_columns{i});
    valid_mask = ~isnan(y_true) & ~isnan(y_pred);

    if nnz(valid_mask) < 3
        title(sprintf('(%c) %s (Insufficient Data)', char('a' + i - 1), valid_labels{i}), ...
            'FontName', font_name, 'FontSize', title_fontsize, 'FontWeight', 'normal');
        continue;
    end

    x = y_true(valid_mask);
    y = y_pred(valid_mask);
    err = abs(x - y);

    scatter(x, y, marker_size, err, 'filled', ...
        'MarkerEdgeColor', [0.2, 0.2, 0.2], 'LineWidth', edge_line_width, ...
        'DisplayName', valid_labels{i});
    hold on;

    x_min = min([x; y]);
    x_max = max([x; y]);
    x_line = linspace(x_min, x_max, 120);

    h_ref = plot(x_line, x_line, '--', 'Color', [0.2, 0.2, 0.2], ...
        'LineWidth', line_width_dashed, 'DisplayName', 'y = x');

    if exist('fitlm', 'file') == 2
        mdl = fitlm(x, y);
        [y_fit, y_ci] = predict(mdl, x_line', 'Prediction', 'curve');
        h_band = fill([x_line, fliplr(x_line)], [y_ci(:, 1)', fliplr(y_ci(:, 2)')], ...
            color_prediction, 'FaceAlpha', 0.15, 'EdgeColor', 'none', ...
            'DisplayName', '95% Confidence Band');
        h_reg = plot(x_line, y_fit, '-', 'Color', color_prediction, ...
            'LineWidth', line_width_solid, 'DisplayName', 'Regression');
        legend([h_ref, h_reg, h_band], {'y = x', 'Regression', '95% Confidence Band'}, ...
            'Location', 'northwest', 'FontName', font_name, 'FontSize', legend_fontsize, 'Box', 'on');
    else
        p = polyfit(x, y, 1);
        y_fit = polyval(p, x_line);
        h_reg = plot(x_line, y_fit, '-', 'Color', color_prediction, ...
            'LineWidth', line_width_solid, 'DisplayName', 'Regression');
        legend([h_ref, h_reg], {'y = x', 'Regression'}, ...
            'Location', 'northwest', 'FontName', font_name, 'FontSize', legend_fontsize, 'Box', 'on');
    end

    hold off;

    cb = colorbar;
    cb.Label.String = 'Absolute Error';
    cb.FontName = font_name;
    cb.FontSize = tick_fontsize;

    xlabel('True Value', 'FontName', font_name, 'FontSize', label_fontsize);
    ylabel('Predicted Value', 'FontName', font_name, 'FontSize', label_fontsize);
    title(sprintf('(%c) %s', char('a' + i - 1), valid_labels{i}), ...
        'FontName', font_name, 'FontSize', title_fontsize, 'FontWeight', 'normal');

    grid on;
    set(gca, 'FontName', font_name, 'FontSize', tick_fontsize, 'LineWidth', 1.0, ...
        'TickDir', 'in', 'TickLength', [0.01, 0.01], 'GridLineStyle', '--', ...
        'GridColor', [0.5, 0.5, 0.5], 'GridAlpha', 0.3, 'Box', 'off');

    axis([x_min, x_max, x_min, x_max]);
    axis square;
    ytickformat('%.2f');

    if use_tight_subplot
        add_top_right_border(gca);
    end
end

%% 3. Export (Optional)
% print(fig, 'scatter_regression.eps', '-depsc', '-tiff');
% print(fig, 'scatter_regression.png', '-dpng', '-r300');
% print(fig, 'scatter_regression.pdf', '-dpdf', '-vector');

%% Usage Notes
% 1. Set excel_file, sheet_name, true_column, and prediction_columns.
% 2. The figure text is all in English for SCI manuscript readiness.
% 3. If fitlm is unavailable, regression is computed with polyfit fallback.

function add_top_right_border(ax)
pos = get(ax, 'Position');
axes('Position', pos, 'XAxisLocation', 'top', 'YAxisLocation', 'right', ...
    'Color', 'none', 'XTick', [], 'YTick', [], 'Box', 'on', 'LineWidth', 1.0);
end
