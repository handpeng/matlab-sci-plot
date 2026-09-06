%% Template: RMSE Bar + Violin + Radar (1x3)
clear; clc; close all;

%% 1. Configuration
excel_file = 'linear-plot.xlsx';
sheet_name = 'Sheet1';
true_column = 'True_Value';

model_columns = {'Best_Model_Prediction', 'TabPFN', 'TabNet', 'FAMA'};
model_labels = {'Best Model', 'TabPFN', 'TabNet', 'FAMA'};
highlight_model = 'FAMA';

font_name = 'Arial';
label_fontsize = 14;
tick_fontsize = 11;
legend_fontsize = 10;

bar_width = 0.62;
violin_width = 0.28;

color_normal = [0.00, 0.45, 0.74];
color_highlight = [0.85, 0.33, 0.10];

fig_w = (21.0 * 2.0) / 2.54;
fig_h = (29.7 * 0.5) / 2.54;
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

y_true = data_table.(true_column);

valid_columns = {};
valid_labels = {};
prediction_data = {};
for i = 1:numel(model_columns)
    col_i = model_columns{i};
    if ismember(col_i, data_table.Properties.VariableNames)
        y_pred = data_table.(col_i);
        valid_mask = ~isnan(y_true) & ~isnan(y_pred);
        if nnz(valid_mask) < 5
            warning('Column "%s" has insufficient valid data. Skipped.', col_i);
            continue;
        end
        valid_columns{end + 1} = col_i; %#ok<AGROW>
        if i <= numel(model_labels)
            valid_labels{end + 1} = model_labels{i}; %#ok<AGROW>
        else
            valid_labels{end + 1} = col_i; %#ok<AGROW>
        end
        prediction_data{end + 1} = y_pred(valid_mask); %#ok<AGROW>
    else
        warning('Column "%s" not found. Skipped.', col_i);
    end
end

if isempty(valid_columns)
    error('No valid model columns were found.');
end

n_models = numel(valid_columns);
true_for_metrics = y_true(~isnan(y_true));

rmse_values = nan(1, n_models);
r2_values = nan(1, n_models);
for i = 1:n_models
    y_pred_all = data_table.(valid_columns{i});
    valid_mask = ~isnan(y_true) & ~isnan(y_pred_all);
    yt = y_true(valid_mask);
    yp = y_pred_all(valid_mask);

    rmse_values(i) = sqrt(mean((yp - yt).^2));
    ss_res = sum((yt - yp).^2);
    ss_tot = sum((yt - mean(yt)).^2);
    if ss_tot <= eps
        r2_values(i) = 0;
    else
        r2_values(i) = 1 - ss_res / ss_tot;
    end
end
r2_values = max(min(r2_values, 1), 0);

highlight_idx = find(strcmp(valid_columns, highlight_model), 1);
if isempty(highlight_idx)
    highlight_idx = -1;
end

x_pos = 1:n_models;

%% 3. Plot Layout (1x3)
t = tiledlayout(1, 3, 'Padding', 'compact', 'TileSpacing', 'compact'); %#ok<NASGU>

% (a) RMSE bar
nexttile;
hold on;
bar_handles = gobjects(1, n_models);
for i = 1:n_models
    if i == highlight_idx
        c = color_highlight;
        alpha_i = 1.0;
    else
        c = color_normal;
        alpha_i = 0.7;
    end

    bar_handles(i) = bar(x_pos(i), rmse_values(i), bar_width, ...
        'FaceColor', c, 'FaceAlpha', alpha_i, 'EdgeColor', 'k', 'LineWidth', 0.6);

    if i ~= highlight_idx
        try
            hatchfill2(bar_handles(i), 'single', 'HatchAngle', 45, 'HatchDensity', 70, ...
                'HatchColor', c, 'HatchLineWidth', 0.45);
        catch ME
            warning('hatchfill2 unavailable for RMSE bar %d: %s', i, ME.message);
        end
    end

    text(x_pos(i), rmse_values(i), sprintf('%.3f', rmse_values(i)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
        'FontName', font_name, 'FontSize', tick_fontsize - 1);
end
hold off;

ylabel('RMSE', 'FontName', font_name, 'FontSize', label_fontsize);
xticks(x_pos);
xticklabels(valid_labels);
xtickangle(30);
ylim([0, max(rmse_values) * 1.2]);

grid on;
ax1 = gca;
set(ax1, 'FontName', font_name, 'FontSize', tick_fontsize, 'LineWidth', 1.0, ...
    'TickDir', 'in', 'TickLength', [0.01, 0.01], 'GridLineStyle', '--', ...
    'GridColor', [0.5, 0.5, 0.5], 'GridAlpha', 0.3, 'Box', 'off');
ytickformat('%.2f');
title('(a) RMSE Comparison', 'FontName', font_name, 'FontSize', tick_fontsize + 1, 'FontWeight', 'normal');

% (b) Violin distribution
nexttile;
hold on;
for i = 1:n_models
    x = prediction_data{i};
    if isempty(x)
        continue;
    end

    if i == highlight_idx
        c = color_highlight;
        alpha_i = 0.85;
    else
        c = color_normal;
        alpha_i = 0.55;
    end

    try
        [f, xi] = ksdensity(x, 'NumPoints', 120);
    catch
        % Fallback: approximate density from histogram
        [n, edges] = histcounts(x, 30, 'Normalization', 'pdf');
        xi = (edges(1:end-1) + edges(2:end)) / 2;
        f = n;
    end

    if max(f) <= eps
        continue;
    end

    f = f / max(f) * violin_width;
    patch([i - f, fliplr(i + f)], [xi, fliplr(xi)], c, ...
        'FaceAlpha', alpha_i, 'EdgeColor', c, 'LineWidth', 0.6);

    med = median(x);
    q1 = quantile(x, 0.25);
    q3 = quantile(x, 0.75);

    plot([i - violin_width * 0.5, i + violin_width * 0.5], [med, med], ...
        'k-', 'LineWidth', 1.8);
    plot([i - violin_width * 0.35, i + violin_width * 0.35], [q1, q1], ...
        'k--', 'LineWidth', 1.0);
    plot([i - violin_width * 0.35, i + violin_width * 0.35], [q3, q3], ...
        'k--', 'LineWidth', 1.0);
end
hold off;

ylabel('Prediction Distribution', 'FontName', font_name, 'FontSize', label_fontsize);
xticks(x_pos);
xticklabels(valid_labels);
xtickangle(30);
xlim([0.5, n_models + 0.5]);

grid on;
ax2 = gca;
set(ax2, 'FontName', font_name, 'FontSize', tick_fontsize, 'LineWidth', 1.0, ...
    'TickDir', 'in', 'TickLength', [0.01, 0.01], 'GridLineStyle', '--', ...
    'GridColor', [0.5, 0.5, 0.5], 'GridAlpha', 0.3, 'Box', 'off');
ytickformat('%.2f');
title('(b) Prediction Violin Plot', 'FontName', font_name, 'FontSize', tick_fontsize + 1, 'FontWeight', 'normal');

% (c) Radar / polar R2
if exist('spider_plot', 'file') == 2
    nexttile;
    spider_plot(r2_values, ...
        'AxesInterval', 4, ...
        'AxesPrecision', 2, ...
        'AxesLimits', [zeros(1, n_models); ones(1, n_models)], ...
        'AxesDisplay', 'one', ...
        'AxesLabelsEdge', 'none', ...
        'AxesWebType', 'circular', ...
        'AxesStart', 0, ...
        'Direction', 'counterclockwise', ...
        'Color', [0.2, 0.4, 0.6], ...
        'FillOption', 'interp', ...
        'FillTransparency', 0.8, ...
        'AxesLabels', valid_labels, ...
        'LabelFont', font_name, ...
        'LabelFontSize', label_fontsize - 1, ...
        'FillCData', r2_values, ...
        'AxesLabelsOffset', 0.10);
    title('(c) R^2 Radar', 'FontName', font_name, 'FontSize', tick_fontsize + 1, 'FontWeight', 'normal');
else
    nexttile;
    pax = polaraxes;
    theta = linspace(0, 2 * pi, n_models + 1);
    r = [r2_values, r2_values(1)];

    polarplot(pax, theta, r, '-o', 'Color', [0.2, 0.4, 0.6], 'LineWidth', 1.6, ...
        'MarkerFaceColor', [0.2, 0.4, 0.6], 'MarkerSize', 4);
    pax.ThetaTick = rad2deg(theta(1:end - 1));
    pax.ThetaTickLabel = valid_labels;
    pax.RLim = [0, 1];
    pax.RTick = 0:0.2:1;
    pax.FontName = font_name;
    pax.FontSize = tick_fontsize;
    title('(c) R^2 Radar (Polar Fallback)', 'FontName', font_name, 'FontSize', tick_fontsize + 1, 'FontWeight', 'normal');
end

% Optional top-right border overlays for first two panels
axes(ax1);
pos1 = get(ax1, 'Position');
axes('Position', pos1, 'XAxisLocation', 'top', 'YAxisLocation', 'right', ...
    'Color', 'none', 'XTick', [], 'YTick', [], 'Box', 'on', 'LineWidth', 1.0);

axes(ax2);
pos2 = get(ax2, 'Position');
axes('Position', pos2, 'XAxisLocation', 'top', 'YAxisLocation', 'right', ...
    'Color', 'none', 'XTick', [], 'YTick', [], 'Box', 'on', 'LineWidth', 1.0);

%% 4. Export (Optional)
% print(fig, 'bar_violin_radar.eps', '-depsc', '-tiff');
% print(fig, 'bar_violin_radar.png', '-dpng', '-r300');
% print(fig, 'bar_violin_radar.pdf', '-dpdf', '-vector');

%% Usage Notes
% 1. model_columns should contain predicted-value columns from the same table.
% 2. highlight_model is shown in accent color in both bar and violin panels.
% 3. spider_plot is optional; when missing, a polar fallback is used.
