%% Template: Scatter Heat + y=x + Regression + 95% Band (5x2)
clear; clc; close all;

%% 1. Configuration
data_file = 'endpoint_test_predictions_merged.csv';
truth_column = 'y_true';

prediction_columns = {'ODE-Anchor Net', 'KNN', 'XGBoost', 'Randomforest', 'Extratrees', ...
    'LightGBM', 'CatBoost', 'NN', 'Linear', 'StackModel'};
prediction_labels = prediction_columns;

font_name = 'Times New Roman';
label_fontsize = 13;
tick_fontsize = 10;
legend_fontsize = 8;
cb_fontsize = 8;

line_width_ref = 1.2;
line_width_reg = 1.5;
line_width_band = 1.2;
marker_size = 20;

n_rows = 5;
n_cols = 2;

fig_w = 8.27;
fig_h = 15.2;
fig = figure('Units', 'inches', 'Position', [0, 0, fig_w, fig_h], ...
    'PaperUnits', 'inches', 'PaperPosition', [0, 0, fig_w, fig_h], ...
    'PaperSize', [fig_w, fig_h], 'Color', 'w');

%% 2. Read and Validate Data
try
    data_table = readtable(data_file, 'VariableNamingRule', 'preserve');
catch ME
    error('Failed to read data file: %s', ME.message);
end

if ~ismember(truth_column, data_table.Properties.VariableNames)
    error('Column "%s" was not found.', truth_column);
end

y_true = data_table.(truth_column);
if ~isnumeric(y_true)
    y_true = str2double(string(y_true));
end

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
    % Wider row spacing and tighter column spacing
    ha = tight_subplot(n_rows, n_cols, [0.08, 0.03], [0.08, 0.05], [0.08, 0.05]);
else
    tiledlayout(n_rows, n_cols, 'Padding', 'compact', 'TileSpacing', 'compact');
end

%% 3. Plot
for i = 1:n_panels
    if use_tight_subplot
        ax = axes(ha(i)); %#ok<LAXES>
    else
        ax = nexttile(i);
    end

    y_pred = data_table.(valid_columns{i});
    if ~isnumeric(y_pred)
        y_pred = str2double(string(y_pred));
    end

    valid_mask = ~isnan(y_true) & ~isnan(y_pred);
    x = y_true(valid_mask);
    y = y_pred(valid_mask);

    if numel(x) < 5
        continue;
    end

    err = abs(x - y);

    mn = min([x; y]);
    mx = max([x; y]);
    span = mx - mn;
    if span <= 0
        span = 1;
    end
    pad = 0.06 * span;
    lims = [mn - pad, mx + pad];

    x_line = linspace(min(x), max(x), 120)';

    hold on;
    h_scatter = scatter(x, y, marker_size, err, 'filled', ...
        'MarkerFaceAlpha', 1.0, 'MarkerEdgeColor', 'none', ...
        'DisplayName', valid_labels{i});

    h_ref = plot(x_line, x_line, 'k--', ...
        'LineWidth', line_width_ref, 'DisplayName', 'y = x');

    h_reg = gobjects(1);
    h_band = gobjects(1);
    try
        mdl = fitlm(x, y);
        y_fit = predict(mdl, x_line);
        h_reg = plot(x_line, y_fit, 'b-', ...
            'LineWidth', line_width_reg, 'DisplayName', 'Regression');
        [~, CI] = predict(mdl, x_line, 'Prediction', 'observation');
        plot(x_line, CI(:, 1), 'b--', 'LineWidth', line_width_band, 'HandleVisibility', 'off');
        h_band = plot(x_line, CI(:, 2), 'b--', ...
            'LineWidth', line_width_band, 'DisplayName', '95% Band');
    catch
        % Fallback if Statistics Toolbox is unavailable
        p = polyfit(x, y, 1);
        y_fit = polyval(p, x_line);
        y_hat = polyval(p, x);
        sigma = std(y - y_hat, 'omitnan');
        band = 1.96 * sigma;
        h_reg = plot(x_line, y_fit, 'b-', ...
            'LineWidth', line_width_reg, 'DisplayName', 'Regression');
        plot(x_line, y_fit - band, 'b--', 'LineWidth', line_width_band, 'HandleVisibility', 'off');
        h_band = plot(x_line, y_fit + band, 'b--', ...
            'LineWidth', line_width_band, 'DisplayName', '95% Band');
    end
    hold off;

    colormap(ax, jet);
    if max(err) > min(err)
        clim(ax, [min(err), max(err)]);
    else
        clim(ax, [min(err) - 0.5, max(err) + 0.5]);
    end

    xlim(lims);
    ylim(lims);
    axis square;
    grid on;

    set(ax, 'FontName', font_name, 'FontSize', tick_fontsize, 'LineWidth', 1.0, ...
        'TickDir', 'in', 'TickLength', [0.01, 0.01], 'GridLineStyle', '--', ...
        'GridColor', [0.5, 0.5, 0.5], 'GridAlpha', 0.3, 'Box', 'on');

    % Axis-label rule:
    % - Y label only on first column
    % - X label only on last row
    if mod(i, 2) == 1
        ylabel('Predicted Value', 'FontName', font_name, 'FontSize', label_fontsize);
    else
        ylabel('');
    end

    if i > (n_rows - 1) * n_cols
        xlabel('True Value', 'FontName', font_name, 'FontSize', label_fontsize);
    else
        xlabel('');
    end

    cb = colorbar(ax, 'eastoutside');
    cb.Label.String = 'Absolute Error';
    cb.Label.FontName = font_name;
    cb.Label.FontSize = cb_fontsize;
    cb.FontName = font_name;
    cb.FontSize = cb_fontsize;

    legend([h_scatter, h_ref, h_reg, h_band], ...
        {valid_labels{i}, 'y = x', 'Regression', '95% Band'}, ...
        'Location', 'northwest', 'FontSize', legend_fontsize, ...
        'FontName', font_name, 'Box', 'on', 'Interpreter', 'none');
end

%% 4. Export (Optional)
% print(fig, 'scatter_heat_5x2_95band.eps', '-depsc', '-tiff');
% print(fig, 'scatter_heat_5x2_95band.png', '-dpng', '-r300');
% print(fig, 'scatter_heat_5x2_95band.pdf', '-dpdf', '-vector');

%% Usage Notes
% 1. Keep all figure text in English.
% 2. This template intentionally has no subplot title.
% 3. Heatmap coloring strictly uses colormap(jet) with per-panel colorbar.
% 4. Legend entries are: model name, y = x, Regression, 95% Band.
