function palette = mpSemanticPalette()
% Stable semantic roles resolved through an Okabe-Ito base palette.
palette = struct();
palette.observed = [0, 114, 178] / 255;
palette.reference = palette.observed;
palette.proposed = [230, 159, 0] / 255;
palette.highlight = palette.proposed;
palette.baseline = [0, 158, 115] / 255;
palette.comparator = palette.baseline;
palette.positive = [0, 158, 115] / 255;
palette.negative = [213, 94, 0] / 255;
palette.uncertainty = [86, 180, 233] / 255;
palette.missing = [0.35, 0.35, 0.35];
palette.out_of_range = palette.missing;
end
