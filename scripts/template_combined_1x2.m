%% Template: Combined Plot (1x2) - Line + Frequency Histogram
clear; clc; close all;

%% 1. Configuration
excel_file = 'linear-plot.xlsx';
sheet_name = 'Sheet1';

true_column = 'True_Value';
selected_column = 'FAMA';
selected_label = 'FAMA';

font_name = 'Arial';
label_fontsize = 14;
tick_fontsize = 11;
legend_fontsize = 10;

line_width_solid = 1.5;
line_width_dashed = 1.5;

num_bins = 15;
bar_width = 0.85;

color_true = [0.00, 0.45, 0.74];
color_prediction = [0.85, 0.33, 0.10];

fig_w = (21.0 * 1.5) / 2.54;
fig_h = (29.7 * 0.35) / 2.54;
fig = figure('Units', 'inches', 'Position', [1, 1, fig_w, fig_h], ...
    'PaperUnits', 'inches', 'PaperPosition', [0, 0, fig_w, fig_h], ...
    'PaperSize', [fig_w, fig_h], 'Color', 'w');

%% 2. Read and Validate Data
try
    data_table = readtable(excel_file, 'Sheet', sheet_name);
catch ME
    error('Failed to read Excel file: %s', ME.message);
end

if ~ismember(true_column, data_table.Properties.VariableNames)
    error('Column "%s" was not found.', true_column);
end
if ~ismember(selected_column, data_table.Properties.VariableNames)
    error('Column "%s" was not found.', selected_column);
end

y_true = data_table.(true_column);
y_pred = data_table.(selected_column);

valid_mask = ~isnan(y_true) & ~isnan(y_pred);
y_true = y_true(valid_mask);
y_pred = y_pred(valid_mask);
x_data = (1:numel(y_true))';

if numel(y_true) < 5
    error('Insufficient valid samples after NaN filtering.');
end

%% 3. Plot (1x2)
t = tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact'); %#ok<NASGU>

% Left: line comparison
nexttile;
hold on;
h_true = plot(x_data, y_true, '-', 'Color', color_true, ...
    'LineWidth', line_width_solid, 'DisplayName', 'True Value');
h_pred = plot(x_data, y_pred, '--', 'Color', color_prediction, ...
    'LineWidth', line_width_dashed, 'DisplayName', selected_label);
hold off;

legend([h_pred, h_true], {selected_label, 'True Value'}, ...
    'Location', 'northeast', 'FontName', font_name, 'FontSize', legend_fontsize, 'Box', 'on');

xlabel('Sample Index', 'FontName', font_name, 'FontSize', label_fontsize);
ylabel('Value', 'FontName', font_name, 'FontSize', label_fontsize);

grid on;
set(gca, 'FontName', font_name, 'FontSize', tick_fontsize, 'LineWidth', 1.0, ...
    'TickDir', 'in', 'TickLength', [0.01, 0.01], 'GridLineStyle', '--', ...
    'GridColor', [0.5, 0.5, 0.5], 'GridAlpha', 0.3, 'Box', 'on');
ytickformat('%.2f');
xlim([x_data(1), x_data(end)]);

% Right: histogram
nexttile;
h_counts = histogram(y_pred, num_bins, ...
    'FaceColor', color_prediction, 'FaceAlpha', 0.45, 'EdgeColor', 'k', ...
    'LineWidth', 0.6, 'DisplayName', selected_label);

try
    hatchfill2(h_counts, 'single', 'HatchAngle', 45, 'HatchDensity', 80, ...
        'HatchColor', color_prediction, 'HatchLineWidth', 0.5);
catch ME
    warning('hatchfill2 unavailable: %s', ME.message);
end

xlabel('Predicted Value', 'FontName', font_name, 'FontSize', label_fontsize);
ylabel('Frequency', 'FontName', font_name, 'FontSize', label_fontsize);
legend('Location', 'northeast', 'FontName', font_name, 'FontSize', legend_fontsize, 'Box', 'on');

grid on;
set(gca, 'FontName', font_name, 'FontSize', tick_fontsize, 'LineWidth', 1.0, ...
    'TickDir', 'in', 'TickLength', [0.01, 0.01], 'GridLineStyle', '--', ...
    'GridColor', [0.5, 0.5, 0.5], 'GridAlpha', 0.3, 'Box', 'on');
ytickformat('%.2f');

%% 4. Export (Optional)
% print(fig, 'combined_1x2.eps', '-depsc', '-tiff');
% print(fig, 'combined_1x2.png', '-dpng', '-r300');
% print(fig, 'combined_1x2.pdf', '-dpdf', '-vector');

%% Usage Notes
% 1. selected_column controls which model is shown in both panels.
% 2. Left panel compares true vs predicted by index.
% 3. Right panel shows predicted-value frequency distribution.
