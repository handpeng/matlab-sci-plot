%% Template: Box (from Summary Stats) + Mean Error Bar (1x2)
clear; clc; close all;

%% 1. Configuration
excel_file = 'chain_model_total_loss.xlsx';
sheet_name = 'Sheet1';

model_column = 'model';
mean_col = 'Mean';
std_col = 'Std';
min_col = 'min';
q25_col = 'X_25';
median_col = 'Median';
q75_col = 'X_75';
max_col = 'Max';

proposed_index = 1;

font_name = 'Times New Roman';
label_fontsize = 13;
tick_fontsize = 10;
title_fontsize = 12;

color_proposed_box = [0.80, 0.20, 0.20];
color_chained_box = [0.20, 0.40, 0.70];
color_proposed_bar = [0.20, 0.60, 0.30];
color_chained_bar = [0.50, 0.60, 0.65];
color_refline = [1.00, 0.00, 0.00];

fig_w = (21.0 * 1.35) / 2.54;
fig_h = (29.7 * 0.35) / 2.54;
fig = figure('Units', 'inches', 'Position', [1, 1, fig_w, fig_h], ...
    'PaperUnits', 'inches', 'PaperPosition', [0, 0, fig_w, fig_h], ...
    'PaperSize', [fig_w, fig_h], 'Color', 'w');

%% 2. Read and Validate
try
    tbl = readtable(excel_file, 'Sheet', sheet_name, 'VariableNamingRule', 'preserve');
catch ME
    error('Failed to read Excel file: %s', ME.message);
end

required_cols = {model_column, mean_col, std_col, min_col, q25_col, median_col, q75_col, max_col};
for i = 1:numel(required_cols)
    if ~ismember(required_cols{i}, tbl.Properties.VariableNames)
        error('Required column "%s" was not found.', required_cols{i});
    end
end

model_names = string(tbl.(model_column));
means_data = tbl.(mean_col);
stds = tbl.(std_col);
mins = tbl.(min_col);
q25 = tbl.(q25_col);
medians = tbl.(median_col);
q75 = tbl.(q75_col);
maxs = tbl.(max_col);

valid_mask = isfinite(means_data) & isfinite(stds) & isfinite(mins) & isfinite(q25) ...
    & isfinite(medians) & isfinite(q75) & isfinite(maxs);

model_names = model_names(valid_mask);
means_data = means_data(valid_mask);
stds = stds(valid_mask);
mins = mins(valid_mask);
q25 = q25(valid_mask);
medians = medians(valid_mask);
q75 = q75(valid_mask);
maxs = maxs(valid_mask);

n_models = numel(model_names);
if n_models < 2
    error('Insufficient valid model rows after filtering.');
end

x = 1:n_models;

%% 3. 1x2 Layout
t = tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact'); %#ok<NASGU>

% (a) Box-like panel from summary stats
nexttile;
hold on;
for i = 1:n_models
    if i == proposed_index
        c = color_proposed_box;
        lw = 1.8;
    else
        c = color_chained_box;
        lw = 1.2;
    end

    rectangle('Position', [i - 0.3, q25(i), 0.6, q75(i) - q25(i)], ...
        'FaceColor', c, 'EdgeColor', 'k', 'LineWidth', lw);
    plot([i - 0.3, i + 0.3], [medians(i), medians(i)], 'k-', 'LineWidth', 2.0);
    plot([i, i], [mins(i), q25(i)], 'k-', 'LineWidth', 1.0);
    plot([i, i], [q75(i), maxs(i)], 'k-', 'LineWidth', 1.0);
    plot([i - 0.15, i + 0.15], [mins(i), mins(i)], 'k-', 'LineWidth', 1.0);
    plot([i - 0.15, i + 0.15], [maxs(i), maxs(i)], 'k-', 'LineWidth', 1.0);
end
hold off;

xticks(x);
xticklabels(model_names);
xtickangle(50);
ylabel('Loss Distribution', 'FontName', font_name, 'FontSize', label_fontsize);
title('(a) Summary Box Distribution', 'FontName', font_name, 'FontSize', title_fontsize, 'FontWeight', 'normal');

ylim([min(mins) - 0.08 * range(maxs), max(maxs) + 0.10 * range(maxs)]);
apply_axis_style(gca, font_name, tick_fontsize);

% (b) Mean +- std panel
nexttile;
hold on;
b = bar(x, means_data, 'FaceColor', 'flat', 'EdgeColor', 'k', 'LineWidth', 0.8, 'FaceAlpha', 0.8);
colors = repmat(color_chained_bar, n_models, 1);
if proposed_index <= n_models
    colors(proposed_index, :) = color_proposed_bar;
end
b.CData = colors;

errorbar(x, means_data, stds, 'k.', 'LineWidth', 1.5, 'CapSize', 8);

for i = 1:n_models
    text(x(i), means_data(i) + stds(i) + max(means_data) * 0.03, sprintf('%.3f', means_data(i)), ...
        'HorizontalAlignment', 'center', 'FontName', font_name, 'FontSize', tick_fontsize - 1);
end

if proposed_index <= n_models
    yline(means_data(proposed_index), '--', 'LineWidth', 1.8, 'Color', color_refline, 'Alpha', 0.7);
end
hold off;

xticks(x);
xticklabels(model_names);
xtickangle(50);
ylabel('Mean Loss +- Std', 'FontName', font_name, 'FontSize', label_fontsize);
title('(b) Mean Comparison', 'FontName', font_name, 'FontSize', title_fontsize, 'FontWeight', 'normal');

ylim([0, max(means_data + stds) * 1.2]);
apply_axis_style(gca, font_name, tick_fontsize);

%% 4. Export (Optional)
% print(fig, 'box_bar_error_1x2.eps', '-depsc', '-tiff');
% print(fig, 'box_bar_error_1x2.png', '-dpng', '-r300');
% print(fig, 'box_bar_error_1x2.pdf', '-dpdf', '-vector');

%% Usage Notes
% 1. Input table must contain summary statistics columns (min/q25/median/q75/max).
% 2. Left panel draws custom box shapes from summary values.
% 3. Right panel compares mean with standard-deviation error bars.

function apply_axis_style(ax, font_name, tick_fontsize)
grid on;
set(ax, 'FontName', font_name, 'FontSize', tick_fontsize, 'LineWidth', 1.0, ...
    'TickDir', 'in', 'TickLength', [0.01, 0.01], 'GridLineStyle', '--', ...
    'GridColor', [0.5, 0.5, 0.5], 'GridAlpha', 0.3, 'Box', 'on');
ytickformat('%.2f');
end
