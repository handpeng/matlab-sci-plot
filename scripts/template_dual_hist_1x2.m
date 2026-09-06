%% Template: Dual Histogram (1x2)
clear; clc; close all;

%% 1. Configuration
excel_file = 'prediction_results.xlsx';
sheet_name = 'Sheet1';

left_column = 'predicted_temp';
right_column = 'mgo_content';

left_xlabel = 'Endpoint Temperature (degC)';
right_xlabel = 'MgO Content in Slag';
shared_ylabel = 'Frequency';

font_name = 'Arial';
label_fontsize = 14;
tick_fontsize = 11;

left_color = [0.85, 0.33, 0.10];
right_color = [0.00, 0.45, 0.74];

fig_w = (21.0 * 1.2) / 2.54;
fig_h = (29.7 * 0.28) / 2.54;
fig = figure('Units', 'inches', 'Position', [1, 1, fig_w, fig_h], ...
    'PaperUnits', 'inches', 'PaperPosition', [0, 0, fig_w, fig_h], ...
    'PaperSize', [fig_w, fig_h], 'Color', 'w');

%% 2. Read and Validate Data
try
    tbl = readtable(excel_file, 'Sheet', sheet_name);
catch ME
    error('Failed to read Excel file: %s', ME.message);
end

if ~ismember(left_column, tbl.Properties.VariableNames)
    error('Column "%s" was not found.', left_column);
end
if ~ismember(right_column, tbl.Properties.VariableNames)
    error('Column "%s" was not found.', right_column);
end

x_left = tbl.(left_column);
x_right = tbl.(right_column);
x_left = x_left(~isnan(x_left));
x_right = x_right(~isnan(x_right));

if isempty(x_left) || isempty(x_right)
    error('No valid data after NaN filtering.');
end

%% 3. Plot 1x2 Histograms
t = tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact'); %#ok<NASGU>

% Left panel
nexttile;
histogram(x_left, 'FaceColor', left_color, 'FaceAlpha', 0.8, ...
    'EdgeColor', [0.25, 0.25, 0.25], 'LineWidth', 0.8);

xlabel(left_xlabel, 'FontName', font_name, 'FontSize', label_fontsize);
ylabel(shared_ylabel, 'FontName', font_name, 'FontSize', label_fontsize);
text(0.02, 0.98, '(a)', 'Units', 'normalized', 'VerticalAlignment', 'top', ...
    'FontName', font_name, 'FontSize', label_fontsize, 'FontWeight', 'bold');

add_stats_box(x_left, font_name, tick_fontsize);
apply_axis_style(gca, font_name, tick_fontsize);

% Right panel
nexttile;
histogram(x_right, 'FaceColor', right_color, 'FaceAlpha', 0.8, ...
    'EdgeColor', [0.25, 0.25, 0.25], 'LineWidth', 0.8);

xlabel(right_xlabel, 'FontName', font_name, 'FontSize', label_fontsize);
ylabel(shared_ylabel, 'FontName', font_name, 'FontSize', label_fontsize);
text(0.02, 0.98, '(b)', 'Units', 'normalized', 'VerticalAlignment', 'top', ...
    'FontName', font_name, 'FontSize', label_fontsize, 'FontWeight', 'bold');

add_stats_box(x_right, font_name, tick_fontsize);
apply_axis_style(gca, font_name, tick_fontsize);

%% 4. Export (Optional)
% print(fig, 'dual_hist_1x2.eps', '-depsc', '-tiff');
% print(fig, 'dual_hist_1x2.png', '-dpng', '-r300');
% print(fig, 'dual_hist_1x2.pdf', '-dpdf', '-vector');

%% Usage Notes
% 1. left_column and right_column define the two histogram variables.
% 2. Statistical annotations (mean, std, n) are added automatically.
% 3. Suitable for manuscript-level distribution comparison figures.

function apply_axis_style(ax, font_name, tick_fontsize)
grid on;
grid minor;
set(ax, 'GridColor', [0.85, 0.85, 0.85], 'GridLineStyle', '-', ...
    'GridAlpha', 0.6, 'MinorGridAlpha', 0.4, 'Layer', 'top', ...
    'FontName', font_name, 'FontSize', tick_fontsize, 'LineWidth', 1.0, ...
    'TickDir', 'in', 'TickLength', [0.01, 0.01], 'Box', 'on');
end

function add_stats_box(x, font_name, font_size)
text(0.98, 0.95, sprintf('Mean = %.2f\nSD = %.2f\nn = %d', mean(x), std(x), numel(x)), ...
    'Units', 'normalized', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', ...
    'BackgroundColor', 'white', 'EdgeColor', [0.5, 0.5, 0.5], ...
    'FontName', font_name, 'FontSize', font_size, 'Margin', 5, 'LineWidth', 0.8);
end
