%% Template: Line + Local Zoom (3x5)
clear; clc; close all;

%% 1. Configuration
excel_file = 'linear-plot.xlsx';
sheet_name = 'Sheet1';
true_column = 'True_Value';

prediction_columns = {'FAMA', 'WeightedEnsemble_L3', 'TabTransformer'};
prediction_labels = {'FAMA', 'MA Model', 'FA Model'};

font_name = 'Arial';
label_fontsize = 12;
tick_fontsize = 10;
legend_fontsize = 9;
title_fontsize = 11;

line_width_solid = 1.5;
line_width_dashed = 1.5;
max_rows = 1000;

color_true = [0.00, 0.45, 0.74];
color_prediction = [0.85, 0.33, 0.10];
zoom_patch_color = [0.70, 0.70, 0.70];
zoom_true_colors = [0.00, 0.55, 0.80; 0.50, 0.22, 0.70];
zoom_pred_colors = [0.85, 0.20, 0.10; 0.95, 0.60, 0.05];

num_zoom_windows = 2;
zoom_window_len = 60;
zoom_smooth_span = 15;
zoom_margin_ratio = 0.08;

fig_w = (21.0 * 1.4) / 2.54;
fig_h = (29.7 * 0.58) / 2.54;
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

n_rows = min(3, numel(valid_columns));
x_data = (1:numel(y_true))';

pred_matrix = nan(numel(y_true), n_rows);
for i = 1:n_rows
    pred_matrix(:, i) = data_table.(valid_columns{i});
end

zoom_windows = select_zoom_windows(y_true, pred_matrix, num_zoom_windows, zoom_window_len, zoom_smooth_span);

%% 3. Plot with tiledlayout (3x5)
t = tiledlayout(3, 5, 'Padding', 'compact', 'TileSpacing', 'compact'); %#ok<NASGU>

for i = 1:n_rows
    row_base = (i - 1) * 5 + 1;
    y_pred = pred_matrix(:, i);
    valid_mask = ~isnan(y_true) & ~isnan(y_pred);

    if nnz(valid_mask) < 5
        continue;
    end

    % Main panel across 3 columns
    nexttile(row_base, [1, 3]);
    x = x_data(valid_mask);
    yt = y_true(valid_mask);
    yp = y_pred(valid_mask);

    hold on;
    h_true = plot(x, yt, '-', 'Color', color_true, 'LineWidth', line_width_solid, 'DisplayName', 'True Value');
    h_pred = plot(x, yp, '--', 'Color', color_prediction, 'LineWidth', line_width_dashed, 'DisplayName', valid_labels{i});

    y_limits = ylim;
    y_span = max(eps, y_limits(2) - y_limits(1));
    for z = 1:size(zoom_windows, 1)
        x_start = zoom_windows(z, 1);
        x_end = zoom_windows(z, 2);
        patch([x_start, x_end, x_end, x_start], [y_limits(1), y_limits(1), y_limits(2), y_limits(2)], ...
            zoom_patch_color, 'FaceAlpha', 0.12, 'EdgeColor', [0.4, 0.4, 0.4], ...
            'LineStyle', '--', 'LineWidth', 0.8, 'HandleVisibility', 'off');
        text(x_start + 1, y_limits(2) - 0.06 * y_span, sprintf('Z%d', z), ...
            'FontName', font_name, 'FontSize', tick_fontsize, 'FontWeight', 'bold', ...
            'Color', [0.25, 0.25, 0.25], 'VerticalAlignment', 'top');
    end
    hold off;

    legend([h_pred, h_true], {valid_labels{i}, 'True Value'}, ...
        'Location', 'northeast', 'FontName', font_name, 'FontSize', legend_fontsize, 'Box', 'on');

    ylabel('Value', 'FontName', font_name, 'FontSize', label_fontsize);
    if i == n_rows
        xlabel('Sample Index', 'FontName', font_name, 'FontSize', label_fontsize);
    end
    title(sprintf('(%c) %s', char('a' + i - 1), valid_labels{i}), ...
        'FontName', font_name, 'FontSize', title_fontsize, 'FontWeight', 'normal');

    grid on;
    set(gca, 'FontName', font_name, 'FontSize', tick_fontsize, 'LineWidth', 1.0, ...
        'TickDir', 'in', 'TickLength', [0.01, 0.01], 'GridLineStyle', '--', ...
        'GridColor', [0.5, 0.5, 0.5], 'GridAlpha', 0.3, 'Box', 'on');
    xlim([x(1), x(end)]);
    ytickformat('%.2f');

    % Two zoom panels
    for z = 1:2
        nexttile(row_base + 2 + z);
        idx = zoom_windows(z, 1):zoom_windows(z, 2);
        idx = idx(idx >= 1 & idx <= numel(x_data));
        idx = idx(~isnan(y_true(idx)) & ~isnan(y_pred(idx)));

        if numel(idx) < 3
            continue;
        end

        x_local = x_data(idx);
        y_true_local = y_true(idx);
        y_pred_local = y_pred(idx);

        hold on;
        plot(x_local, y_true_local, '-', 'Color', zoom_true_colors(z, :), ...
            'LineWidth', line_width_solid + 0.2, 'DisplayName', 'True Value');

        marker_step = max(1, floor(numel(x_local) / 16));
        plot(x_local, y_pred_local, '--o', 'Color', zoom_pred_colors(z, :), ...
            'LineWidth', line_width_dashed, 'MarkerSize', 3, ...
            'MarkerIndices', 1:marker_step:numel(x_local), 'MarkerFaceColor', 'w', ...
            'DisplayName', valid_labels{i});
        hold off;

        if i == 1
            title(sprintf('Z%d [%d, %d]', z, zoom_windows(z, 1), zoom_windows(z, 2)), ...
                'FontName', font_name, 'FontSize', tick_fontsize + 1, 'FontWeight', 'normal');
        else
            title(sprintf('Z%d', z), 'FontName', font_name, 'FontSize', tick_fontsize + 1, 'FontWeight', 'normal');
        end

        y_local = [y_true_local; y_pred_local];
        y_min = min(y_local);
        y_max = max(y_local);
        y_pad = max((y_max - y_min) * zoom_margin_ratio, 1e-3);
        ylim([y_min - y_pad, y_max + y_pad]);
        xlim([x_local(1), x_local(end)]);

        grid on;
        set(gca, 'FontName', font_name, 'FontSize', tick_fontsize, 'LineWidth', 1.0, ...
            'TickDir', 'in', 'TickLength', [0.01, 0.01], 'GridLineStyle', '--', ...
            'GridColor', [0.5, 0.5, 0.5], 'GridAlpha', 0.3, 'Box', 'on');
        ytickformat('%.2f');
    end
end

%% 4. Export (Optional)
% print(fig, 'line_zoom_3x5.eps', '-depsc', '-tiff');
% print(fig, 'line_zoom_3x5.png', '-dpng', '-r300');
% print(fig, 'line_zoom_3x5.pdf', '-dpdf', '-vector');

%% Usage Notes
% 1. This template uses a fixed 3x5 layout: [main(3 cols) + Z1 + Z2] per row.
% 2. Zoom windows are auto-selected from smoothed normalized error peaks.
% 3. Replace prediction_columns with your ablation model outputs.

function zoom_windows = select_zoom_windows(true_values, pred_matrix, num_windows, window_len, smooth_span)
true_values = true_values(:);
n = min(numel(true_values), size(pred_matrix, 1));
true_values = true_values(1:n);
pred_matrix = pred_matrix(1:n, :);

window_len = max(3, min(round(window_len), n));
smooth_span = max(1, min(round(smooth_span), n));
num_windows = max(1, round(num_windows));

err_matrix = abs(pred_matrix - true_values);
err_matrix(isnan(err_matrix)) = 0;

norm_err = zeros(size(err_matrix));
for k = 1:size(err_matrix, 2)
    e = err_matrix(:, k);
    q95 = quantile(e(e > 0), 0.95);
    if isempty(q95) || q95 <= eps
        q95 = max(mean(e), 1);
    end
    norm_err(:, k) = e ./ q95;
end

score = mean(norm_err, 2);
score = movmean(score, smooth_span, 'Endpoints', 'shrink');
[~, order] = sort(score, 'descend');

zoom_windows = zeros(0, 2);
for i = 1:numel(order)
    cand = make_window(order(i), n, window_len);
    if ~has_overlap(cand, zoom_windows)
        zoom_windows(end + 1, :) = cand; %#ok<AGROW>
    end
    if size(zoom_windows, 1) >= num_windows
        break;
    end
end

if size(zoom_windows, 1) < num_windows
    centers = round(linspace(1, n, num_windows + 2));
    centers = centers(2:end - 1);
    for i = 1:numel(centers)
        cand = make_window(centers(i), n, window_len);
        if ~has_overlap(cand, zoom_windows)
            zoom_windows(end + 1, :) = cand; %#ok<AGROW>
        end
        if size(zoom_windows, 1) >= num_windows
            break;
        end
    end
end

zoom_windows = sortrows(zoom_windows, 1);
if size(zoom_windows, 1) > num_windows
    zoom_windows = zoom_windows(1:num_windows, :);
end
end

function window = make_window(center, n, len)
left = floor((len - 1) / 2);
start_idx = center - left;
end_idx = start_idx + len - 1;

if start_idx < 1
    start_idx = 1;
    end_idx = min(n, len);
end
if end_idx > n
    end_idx = n;
    start_idx = max(1, n - len + 1);
end
window = [start_idx, end_idx];
end

function tf = has_overlap(cand, windows)
tf = false;
for i = 1:size(windows, 1)
    if ~(cand(2) < windows(i, 1) || cand(1) > windows(i, 2))
        tf = true;
        return;
    end
end
end
