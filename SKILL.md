---
name: matlab-sci-plot
description: Use when users need SCI-style academic figures in MATLAB (scatter, line, zoomed line, grouped bar, dual histogram, feature-importance barh, box+errorbar, error analysis, distribution+KDE, violin, radar), or want to reuse this repository's plotting style instead of writing plotting code from scratch.
---

# MATLAB SCI 绘图技能

本技能用于生成符合 SCI 学术期刊风格的 MATLAB 绘图脚本。模板已对齐你现有脚本风格，并统一了字体、配色、布局、导出和依赖容错逻辑。

> **强制规则：图中所有文字（xlabel/ylabel/title/legend/tick/text）必须使用英文。**

## 目录结构

```text
matlab-sci-plot/
├── SKILL.md
└── scripts/
    ├── template_scatter.m
    ├── template_scatter_heat_5x2.m
    ├── template_line_plot.m
    ├── template_line_zoom.m
    ├── template_ablation_scatter.m
    ├── template_bar_line.m
    ├── template_error_hist.m
    ├── template_distribution.m
    ├── template_combined_1x2.m
    ├── template_bar_violin_radar.m
    ├── template_feature_importance_barh.m
    ├── template_dual_hist_1x2.m
    ├── template_grouped_bar_3x1.m
    ├── template_box_bar_error_1x2.m
    ├── template_spider_only_1x3.m
    ├── template_grouped_bar_dual_axis_models.m
    └── template_multi_sheet_scatter_3x1.m
```

## 1. 字体规范

| 元素 | 推荐字体 | 字号 |
|---|---|---|
| Axis labels | Times New Roman / Arial | 14-16 pt |
| Tick labels | Times New Roman / Arial | 10-14 pt |
| Legend | Times New Roman / Arial | 10-14 pt |
| Subplot title | normal weight | 11-12 pt |

- `tight_subplot` 传统布局优先 `Times New Roman`
- `tiledlayout` 现代布局优先 `Arial`

## 2. 标准配色

```matlab
color_true       = [0.00, 0.45, 0.74];
color_prediction = [0.85, 0.33, 0.10];

color_scatter    = [0.30, 0.60, 1.00];
color_best_point = [1.00, 0.00, 0.00];

color_CaO  = [0.20, 0.60, 0.20];
color_SiO2 = [0.80, 0.80, 0.20];
color_FeO  = [0.80, 0.40, 0.40];
color_MgO  = [0.40, 0.80, 0.40];

% Okabe-Ito (recommended for grouped bars / dual-axis metrics)
color_rmse = [0, 114, 178] / 255;
color_mae  = [230, 159, 0] / 255;
color_r2   = [0, 158, 115] / 255;
```

## 3. 线条与标记规范

```matlab
line_width_solid  = 1.5;
line_width_dashed = 1.5;
marker_size       = 80;
edge_line_width   = 1.2;
```

## 4. 坐标轴规范

```matlab
set(gca, 'FontName', font_name, 'FontSize', tick_fontsize);
set(gca, 'Box', 'off');
set(gca, 'TickDir', 'in');
set(gca, 'TickLength', [0.01, 0.01]);
set(gca, 'LineWidth', 1.0);
set(gca, 'GridLineStyle', '--');
set(gca, 'GridColor', [0.5, 0.5, 0.5]);
set(gca, 'GridAlpha', 0.3);
ytickformat('%.2f');
```

`tight_subplot` 子图可使用叠加边框：

```matlab
pos = get(ax, 'Position');
axes('Position', pos, 'XAxisLocation', 'top', 'YAxisLocation', 'right', ...
     'Color', 'none', 'XTick', [], 'YTick', [], 'Box', 'on');
```

## 5. 图形尺寸规范

```matlab
% A4 竖向
figure('Units', 'inches', 'Position', [0, 0, 8.27, 11.69]);

% A4 横向宽幅
fig_w = 21.0 * 1.5 / 2.54;
fig_h = 29.7 * 0.35 / 2.54;
figure('Units', 'inches', 'Position', [1, 1, fig_w, fig_h], ...
       'PaperUnits', 'inches', 'PaperPosition', [0, 0, fig_w, fig_h], ...
       'PaperSize', [fig_w, fig_h], 'Color', 'w');

% 固定像素
f = figure; f.Position = [100, 100, 1600, 800];

% A4 宽度 * 0.9（推荐用于单图对比）
fig_w_cm = 21.0 * 0.9;
fig_h_cm = 12.0;
figure('Units', 'centimeters', 'Position', [1, 1, fig_w_cm, fig_h_cm], 'Color', 'w');
```

## 6. 布局工具

### `tight_subplot`（传统多面板）

```matlab
ha = tight_subplot(nRows, nCols, [gap_h, gap_w], [bot, top], [left, right]);
axes(ha(i));
```

### `tiledlayout`（现代排版）

```matlab
t = tiledlayout(nRows, nCols, 'Padding', 'compact', 'TileSpacing', 'compact');
nexttile;
nexttile(pos, [1, span]);
```

## 7. 图类速查表

| 图类 | 脚本文件 | 布局 | 典型用途 |
|---|---|---|---|
| Scatter + regression + confidence band | `template_scatter.m` | tight_subplot 3x2 | Prediction consistency |
| Scatter heat + y=x + regression + 95% prediction band | `template_scatter_heat_5x2.m` | 5x2 | Multi-model prediction comparison |
| Multi-line comparison (4x1) | `template_line_plot.m` | tiledlayout 4x1 | True vs prediction |
| Line + local zoom (3x5) | `template_line_zoom.m` | tiledlayout 3x5 | Ablation model detail |
| Ablation scatter (2x2) | `template_ablation_scatter.m` | tight_subplot 2x2 | Hyperparameter ablation |
| Bar + line (2x2) | `template_bar_line.m` | tight_subplot 2x2 | Multi-metric model comparison |
| Error hist + scatter regression | `template_error_hist.m` | tight_subplot 4x2 | Multi-target error analysis |
| Distribution + KDE (8x3) | `template_distribution.m` | tight_subplot 8x3 | Dataset distribution |
| Line + frequency histogram | `template_combined_1x2.m` | tiledlayout 1x2 | Single-model report |
| RMSE bar + violin + radar | `template_bar_violin_radar.m` | tiledlayout 1x3 | Comprehensive model comparison |
| Feature importance barh | `template_feature_importance_barh.m` | tiledlayout 1x4 | SHAP/importance style summary |
| Dual histogram | `template_dual_hist_1x2.m` | tiledlayout 1x2 | Two-variable distribution comparison |
| Grouped bar (multi-sheet) | `template_grouped_bar_3x1.m` | tiledlayout 3x1 | Order/No-order grouped comparison |
| Grouped bar + secondary axis (model index) | `template_grouped_bar_dual_axis_models.m` | single axes + `yyaxis` | RMSE/MAE (left) and R^2 (right) per model |
| Box summary + error bar | `template_box_bar_error_1x2.m` | tiledlayout 1x2 | Proposed vs chained model loss |
| Spider only (multi-sheet) | `template_spider_only_1x3.m` | tiledlayout 1x3 | Radar comparison by sheet |
| Multi-sheet scatter | `template_multi_sheet_scatter_3x1.m` | tiledlayout 3x1 | Residual/sample scatter comparison |

### Scatter Heat 默认规范（5x2）

- 热图着色：`scatter(..., c = abs(y_true - y_pred))`，并使用 `colormap(jet)`
- 每个子图单独显示 `colorbar`，标签为 `Absolute Error`
- 每个子图绘制：`y = x`、`Regression`、`95% Band`
- 图例顺序：`{ModelName, 'y = x', 'Regression', '95% Band'}`
- 不使用 subplot title；多面板标签规则为：第一列显示 `Predicted Value`，最后一行显示 `True Value`

### Grouped Bar + Secondary Axis 默认规范

- 横轴为模型索引，每个 index 三根柱：`RMSE`、`MAE`、`R^2`
- 使用 `yyaxis`：左轴放 `RMSE/MAE`，右轴放 `R^2`
- `R^2 < 0` 默认截断为 `0`
- 图例默认右上角：`'Location','northeast'`
- 边框开启：`Box='on'`，并保留右侧刻度线
- 默认尺寸：A4 宽度 `* 0.9`（`18.9 cm`）

## 8. 依赖说明

| 函数 | 用途 | 涉及模板 |
|---|---|---|
| `tight_subplot` | 子图间距精细控制 | 大多数传统布局模板 |
| `hatchfill2` | 条形图斜线填充 | `bar_line`, `combined_1x2`, `bar_violin_radar`, `grouped_bar_3x1` |
| `spider_plot` | 雷达图 | `bar_violin_radar`, `spider_only_1x3` |

- 所有 `hatchfill2` 调用必须包裹在 `try/catch` 中
- `spider_plot` 不存在时，模板自动回退为 `polaraxes` 绘制

## 9. 导出规范

```matlab
print(fig, 'output.eps', '-depsc', '-tiff');
print(fig, 'output.png', '-dpng', '-r300');
print(fig, 'output.pdf', '-dpdf', '-vector');

% 推荐：避免部分环境下 print 的页面尺寸警告
exportgraphics(fig, 'output.png', 'Resolution', 300);
exportgraphics(fig, 'output.pdf', 'ContentType', 'vector');
```

## 10. 代码生成规则

1. 顶部必须有 `%% 1. Configuration` 配置区
2. 使用 `readtable` 读取数据并验证列名
3. `>= 3x2` 复杂多面板优先 `tight_subplot`
4. `tight_subplot` 子图优先叠加边框
5. FontName/FontSize 显式设置
6. 导出代码保留为注释模板
7. 每个脚本末尾提供 `%% Usage Notes`
8. 批量绘图时建议 `'Visible','off'` 并在循环后 `close(fig)`
9. 文件读取与可选依赖统一 `try/catch`
10. 图中所有文字必须英文

## 11. Codex CLI 调用建议

当用户提到以下意图时，直接读取对应模板并生成可运行脚本：

- 关键词：`画图`、`绘图`、`MATLAB图`、`SCI图`、`论文图`
- 图类型：`scatter`、`scatter heat`、`line plot`、`bar chart`、`grouped bar`、`grouped bar dual-axis`、`ablation`、`error plot`、`distribution`、`dual histogram`、`feature importance`、`boxplot`、`violin`、`radar`

工作流程：

1. 判断图类并定位模板
2. 仅修改配置区（文件、列名、图例、导出名）
3. 保留模板风格和容错结构
4. 返回完整脚本给用户
