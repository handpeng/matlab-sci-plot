%% Template: Distribution + KDE (8x3)
clear; clc; close all;

%% 1. Configuration
dataset_files = {'source_data.xlsx', 'target_data.xlsx'};
dataset_labels = {'Source Dataset', 'Target Dataset'};
sheet_name = 'Sheet1';

max_features = 22;
n_rows = 8;
n_cols = 3;

font_name = 'Times New Roman';
label_fontsize = 11;
tick_fontsize = 9;
title_fontsize = 12;

hist_face_color = [0.80, 0.85, 0.95];
kde_color = [0.85, 0.33, 0.10];

fig_w = 6.2;
fig_h = 10.0;

%% 2. Generate Plots for Each Dataset
for d = 1:numel(dataset_files)
    file_i = dataset_files{d};
    if d <= numel(dataset_labels)
        dataset_name = dataset_labels{d};
    else
        dataset_name = sprintf('Dataset %d', d);
    end

    try
        tbl = readtable(file_i, 'Sheet', sheet_name, 'VariableNamingRule', 'preserve');
    catch ME
        warning('Failed to read %s: %s', file_i, ME.message);
        continue;
    end

    n_features = min([width(tbl), max_features, n_rows * n_cols]);
    if n_features < 1
        warning('No valid columns found in %s.', file_i);
        continue;
    end

    fig = figure('Units', 'inches', 'Position', [0, 0, fig_w, fig_h], 'Color', 'w');

    use_tight_subplot = (exist('tight_subplot', 'file') == 2);
    if use_tight_subplot
        ha = tight_subplot(n_rows, n_cols, [0.06, 0.05], [0.06, 0.03], [0.07, 0.04]);
    else
        tiledlayout(n_rows, n_cols, 'Padding', 'compact', 'TileSpacing', 'compact');
    end

    for i = 1:n_features
        if use_tight_subplot
            axes(ha(i));
        else
            nexttile(i);
        end

        x = tbl{:, i};
        x = x(~isnan(x));

        if isempty(x)
            title(sprintf('%s (Empty)', tbl.Properties.VariableNames{i}), ...
                'FontName', font_name, 'FontSize', tick_fontsize, 'FontWeight', 'normal');
            continue;
        end

        histogram(x, 'Normalization', 'pdf', 'FaceColor', hist_face_color, ...
            'EdgeColor', 'k', 'LineWidth', 0.8, 'DisplayName', 'Histogram');
        hold on;

        try
            [f, xi] = ksdensity(x);
            plot(xi, f, '-', 'Color', kde_color, 'LineWidth', 1.5, 'DisplayName', 'KDE');
            legend('Location', 'best', 'FontName', font_name, 'FontSize', tick_fontsize - 1, 'Box', 'on');
        catch
            % ksdensity is optional; histogram still remains valid
        end
        hold off;

        xlabel(strrep(tbl.Properties.VariableNames{i}, '_', '\_'), ...
            'FontName', font_name, 'FontSize', label_fontsize);

        if mod(i, n_cols) == 1
            ylabel('Density', 'FontName', font_name, 'FontSize', label_fontsize);
        end

        grid on;
        set(gca, 'FontName', font_name, 'FontSize', tick_fontsize, 'LineWidth', 0.9, ...
            'TickDir', 'in', 'TickLength', [0.01, 0.01], 'GridLineStyle', '--', ...
            'GridColor', [0.6, 0.6, 0.6], 'GridAlpha', 0.25, 'Box', 'on');
        ytickformat('%.2f');
    end

    sgtitle(dataset_name, 'FontName', font_name, 'FontSize', title_fontsize, 'FontWeight', 'normal');

    % Optional export per dataset
    % out_name = sprintf('distribution_%d', d);
    % print(fig, [out_name, '.eps'], '-depsc', '-tiff');
    % print(fig, [out_name, '.png'], '-dpng', '-r300');
    % print(fig, [out_name, '.pdf'], '-dpdf', '-vector');
end

%% Usage Notes
% 1. The script creates one 8x3 figure for each dataset file.
% 2. Each panel shows histogram + KDE (if ksdensity is available).
% 3. Set max_features to control how many columns are displayed.
