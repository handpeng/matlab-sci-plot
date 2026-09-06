%% Template: Line Comparison (4x1)
clear; clc; close all;

%% 1. Configuration
excel_file = 'linear-plot.xlsx';
sheet_name = 'Sheet1';
true_column = 'True_Value';

prediction_columns = {'FAMA', 'Best_Model_Prediction', 'TabPFN', 'TabNet'};
prediction_labels = {'FAMA', 'Best Model', 'TabPFN', 'TabNet'};

font_name = 'Arial';
label_fontsize = 14;
tick_fontsize = 11;
legend_fontsize = 10;
title_fontsize = 12;

line_width_solid = 1.5;
line_width_dashed = 1.5;
max_rows = 1000;

color_true = [0.00, 0.45, 0.74];
color_prediction = [0.85, 0.33, 0.10];

fig_w = 21.0 / 2.54;
fig_h = (29.7 * 0.75) / 2.54;
fig = figure('Units', 'inches', 'Position', [1, 1, fig_w, fig_h], ...
    'PaperUnits', 'inches', 'PaperPosition', [0, 0, fig_w, fig_h], ...
    'PaperSize', [fig_w, fig_h], 'Color', 'w');

%% 2. Read and Validate Data
try
    data_table = readtable(excel_file, 'Sheet', sheet_name);
catch ME
    error('Failed to read Excel file: %s', ME.message);
end

if height(data_table) > max_rows
    data_table = data_table(1:max_rows, :);
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

n_panels = min(4, numel(valid_columns));
x_data = (1:numel(y_true))';

%% 3. Plot with tiledlayout (4x1)
t = tiledlayout(4, 1, 'Padding', 'compact', 'TileSpacing', 'compact'); %#ok<NASGU>

for i = 1:n_panels
    nexttile(i);

    y_pred = data_table.(valid_columns{i});
    valid_mask = ~isnan(y_true) & ~isnan(y_pred);

    if nnz(valid_mask) < 3
        title(sprintf('(%c) %s (Insufficient Data)', char('a' + i - 1), valid_labels{i}), ...
            'FontName', font_name, 'FontSize', title_fontsize, 'FontWeight', 'normal');
        continue;
    end

    x = x_data(valid_mask);

    hold on;
    h_true = plot(x, y_true(valid_mask), '-', 'Color', color_true, ...
        'LineWidth', line_width_solid, 'DisplayName', 'True Value');
    h_pred = plot(x, y_pred(valid_mask), '--', 'Color', color_prediction, ...
        'LineWidth', line_width_dashed, 'DisplayName', valid_labels{i});
    hold off;

    legend([h_pred, h_true], {valid_labels{i}, 'True Value'}, ...
        'Location', 'northeast', 'FontName', font_name, 'FontSize', legend_fontsize, 'Box', 'on');

    ylabel('Value', 'FontName', font_name, 'FontSize', label_fontsize);
    if i == n_panels
        xlabel('Sample Index', 'FontName', font_name, 'FontSize', label_fontsize);
    end

    title(sprintf('(%c) %s', char('a' + i - 1), valid_labels{i}), ...
        'FontName', font_name, 'FontSize', title_fontsize, 'FontWeight', 'normal');

    grid on;
    set(gca, 'FontName', font_name, 'FontSize', tick_fontsize, 'LineWidth', 1.0, ...
        'TickDir', 'in', 'TickLength', [0.01, 0.01], 'GridLineStyle', '--', ...
        'GridColor', [0.5, 0.5, 0.5], 'GridAlpha', 0.3, 'Box', 'on');
    ytickformat('%.2f');
    xlim([x(1), x(end)]);
end

%% 4. Export (Optional)
% print(fig, 'line_plot_4x1.eps', '-depsc', '-tiff');
% print(fig, 'line_plot_4x1.png', '-dpng', '-r300');
% print(fig, 'line_plot_4x1.pdf', '-dpdf', '-vector');

%% Usage Notes
% 1. Set true_column and prediction_columns to your Excel header names.
% 2. Keep labels in prediction_labels aligned with prediction_columns.
% 3. The layout is fixed at 4x1 and uses SCI-friendly publication styling.
