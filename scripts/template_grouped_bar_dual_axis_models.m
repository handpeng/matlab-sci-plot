%% Template: Grouped Bar by Model with Secondary Axis (RMSE/MAE vs R^2)
clear; clc; close all;

%% 1. Configuration
input_csv = 'endpoint_test_predictions_merged.csv';

% Prediction columns (model outputs)
model_cols = {
    'ODE-Anchor Net', 'KNN', 'XGBoost', 'Randomforest', 'Extratrees', ...
    'LightGBM', 'CatBoost', 'NN', 'Linear', 'StackModel'
};

% Ground truth column
true_col = 'y_true';

% Metric policy
clip_r2_below_zero = true;

% Typography
font_name = 'Times New Roman';
label_fontsize = 16;
tick_fontsize = 14;
legend_fontsize = 14;

% Layout
x_tick_angle = 25;
show_xlabel = false;

% Figure width = A4 width * 0.9
% A4 width = 21.0 cm -> 18.9 cm
a4_width_cm = 21.0;
fig_width_cm = a4_width_cm * 0.9;
fig_height_cm = 12.0;

% Scientific palette (Okabe-Ito, colorblind-friendly)
color_rmse = [0, 114, 178] / 255;
color_mae  = [230, 159, 0] / 255;
color_r2   = [0, 158, 115] / 255;

%% 2. Read Data
try
    T = readtable(input_csv, 'VariableNamingRule', 'preserve');
catch ME
    error('Failed to read CSV file: %s', ME.message);
end

required_cols = [model_cols, {true_col}];
missing_cols = required_cols(~ismember(required_cols, T.Properties.VariableNames));
if ~isempty(missing_cols)
    error('Missing required columns: %s', strjoin(missing_cols, ', '));
end

y_true = T.(true_col);

%% 3. Compute RMSE / MAE / R^2 per model
n_models = numel(model_cols);
rmse_vals = nan(1, n_models);
mae_vals  = nan(1, n_models);
r2_vals   = nan(1, n_models);

for i = 1:n_models
    y_pred = T.(model_cols{i});
    valid = ~isnan(y_true) & ~isnan(y_pred);

    yt = y_true(valid);
    yp = y_pred(valid);
    if isempty(yt)
        continue;
    end

    err = yp - yt;
    rmse_vals(i) = sqrt(mean(err.^2));
    mae_vals(i)  = mean(abs(err));

    ss_res = sum((yt - yp).^2);
    ss_tot = sum((yt - mean(yt)).^2);
    if ss_tot > 0
        r2_vals(i) = 1 - ss_res / ss_tot;
    end
end

if clip_r2_below_zero
    r2_vals(r2_vals < 0) = 0;
end

metric_matrix = [rmse_vals(:), mae_vals(:), r2_vals(:)]; % N x 3

%% 4. Plot
fig = figure('Units', 'centimeters', 'Position', [1, 1, fig_width_cm, fig_height_cm], 'Color', 'w');
ax = axes(fig, 'Position', [0.07, 0.13, 0.86, 0.80]); %#ok<LAXES>
hold(ax, 'on');

x = 1:n_models;
bar_w = 0.22;

% Left axis: RMSE + MAE
yyaxis(ax, 'left');
b1 = bar(ax, x - bar_w, metric_matrix(:, 1), bar_w, ...
    'FaceColor', color_rmse, 'EdgeColor', [0.15, 0.15, 0.15], 'LineWidth', 0.8);
b2 = bar(ax, x, metric_matrix(:, 2), bar_w, ...
    'FaceColor', color_mae, 'EdgeColor', [0.15, 0.15, 0.15], 'LineWidth', 0.8);
ylabel(ax, 'Error Metrics (RMSE / MAE)', 'FontName', font_name, 'FontSize', label_fontsize);
ax.YColor = [0, 0, 0];

% Right axis: R^2
yyaxis(ax, 'right');
b3 = bar(ax, x + bar_w, metric_matrix(:, 3), bar_w, ...
    'FaceColor', color_r2, 'EdgeColor', [0.15, 0.15, 0.15], 'LineWidth', 0.8);
ylabel(ax, 'R^2', 'FontName', font_name, 'FontSize', label_fontsize);
ax.YColor = [0, 0, 0];

r2_max = max(metric_matrix(:, 3), [], 'omitnan');
if isempty(r2_max) || isnan(r2_max)
    r2_max = 1;
end
ylim(ax, [0, max(1, r2_max * 1.1)]);

% X-axis model index
ax.XLim = [0.4, n_models + 0.6];
ax.XTick = x;
ax.XTickLabel = model_cols;
xtickangle(ax, x_tick_angle);
if show_xlabel
    xlabel(ax, 'Models', 'FontName', font_name, 'FontSize', label_fontsize);
end

% Axis style
ax.FontName = font_name;
ax.FontSize = tick_fontsize;
ax.LineWidth = 1.1;
ax.TickDir = 'in';
ax.TickLength = [0.01, 0.01];
ax.Box = 'on';
grid(ax, 'on');
ax.GridLineStyle = '--';
ax.GridAlpha = 0.25;

% Legend at top-right
lg = legend(ax, [b1, b2, b3], {'RMSE', 'MAE', 'R^2'}, 'Location', 'northeast', 'Box', 'off');
lg.FontName = font_name;
lg.FontSize = legend_fontsize;

%% 5. Export (Optional)
% timestamp = datestr(now, 'yyyymmdd_HHMMSS');
% out_png = ['grouped_bar_dual_axis_models_' timestamp '.png'];
% out_pdf = ['grouped_bar_dual_axis_models_' timestamp '.pdf'];
% exportgraphics(fig, out_png, 'Resolution', 300);
% exportgraphics(fig, out_pdf, 'ContentType', 'vector');

%% Usage Notes
% 1. Each x-index corresponds to one model, with 3 bars (RMSE / MAE / R^2).
% 2. RMSE and MAE use left y-axis; R^2 uses right y-axis.
% 3. Set clip_r2_below_zero=true to clamp negative R^2 to zero.
% 4. Figure width defaults to A4 width * 0.9 (18.9 cm).
