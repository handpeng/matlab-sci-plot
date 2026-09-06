%% Template: Spider-Only Comparison (1x3)
clear; clc; close all;

%% 1. Configuration
excel_file = 'avg_loss.xlsx';
sheet_names = {'order1', 'order2', 'noorder'};

label_column = 1;   % feature/category labels
value_column = 4;   % numeric value used in spider plot

font_name = 'Times New Roman';
label_fontsize = 12;
title_fontsize = 12;

custom_titles = {'(a) Order 1', '(b) Order 2', '(c) No Order'};

fig = figure('Units', 'pixels', 'Position', [50, 50, 1700, 620], 'Color', 'w');
t = tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact'); %#ok<NASGU>
colormap(fig, flipud(hot));

%% 2. Plot Each Spider
for i = 1:min(3, numel(sheet_names))
    nexttile(i);

    sheet_i = sheet_names{i};
    try
        tbl = readtable(excel_file, 'Sheet', sheet_i, 'VariableNamingRule', 'preserve');
    catch ME
        warning('Failed to read sheet "%s": %s', sheet_i, ME.message);
        continue;
    end

    if width(tbl) < max(label_column, value_column)
        warning('Sheet "%s" does not contain required columns.', sheet_i);
        continue;
    end

    labels = string(tbl{:, label_column});
    values = tbl{:, value_column};

    valid_mask = ~isnan(values);
    labels = labels(valid_mask);
    values = values(valid_mask);

    if numel(values) < 3
        warning('Sheet "%s" has insufficient valid values.', sheet_i);
        continue;
    end

    p = values(:)';

    lo = min(p);
    hi = max(p);
    if hi <= lo
        hi = lo + 1;
    end
    axes_limits = [lo * ones(1, numel(p)); hi * ones(1, numel(p))];

    if exist('spider_plot', 'file') == 2
        spider_plot(p, ...
            'AxesInterval', 4, ...
            'AxesPrecision', 2, ...
            'AxesLimits', axes_limits, ...
            'AxesDisplay', 'one', ...
            'AxesLabelsEdge', 'none', ...
            'AxesWebType', 'circular', ...
            'AxesStart', 0, ...
            'Direction', 'counterclockwise', ...
            'Color', [0.85, 0.33, 0.10], ...
            'FillOption', 'interp', ...
            'FillTransparency', 0.85, ...
            'AxesLabels', labels, ...
            'LabelFont', font_name, ...
            'LabelFontSize', label_fontsize, ...
            'FillCData', p, ...
            'AxesLabelsOffset', 0.08);
    else
        % Polar fallback when spider_plot is unavailable
        pax = polaraxes;
        theta = linspace(0, 2 * pi, numel(p) + 1);
        r = [p, p(1)];
        polarplot(pax, theta, r, '-o', 'LineWidth', 1.5, 'Color', [0.85, 0.33, 0.10], ...
            'MarkerFaceColor', [0.85, 0.33, 0.10], 'MarkerSize', 4);
        pax.ThetaTick = rad2deg(theta(1:end - 1));
        pax.ThetaTickLabel = labels;
        pax.FontName = font_name;
        pax.FontSize = label_fontsize - 1;
        pax.RLim = [lo, hi];
    end

    if i <= numel(custom_titles)
        title(custom_titles{i}, 'FontName', font_name, 'FontSize', title_fontsize, 'FontWeight', 'normal');
    else
        title(sprintf('(%c) %s', char('a' + i - 1), sheet_i), ...
            'FontName', font_name, 'FontSize', title_fontsize, 'FontWeight', 'normal');
    end
end

%% 3. Export (Optional)
% print(fig, 'spider_only_1x3.eps', '-depsc', '-tiff');
% print(fig, 'spider_only_1x3.png', '-dpng', '-r300');
% print(fig, 'spider_only_1x3.pdf', '-dpdf', '-vector');

%% Usage Notes
% 1. value_column selects which numeric metric is used for each radar panel.
% 2. spider_plot is optional; polar fallback is used when unavailable.
% 3. Keep labels in English for journal publication consistency.
