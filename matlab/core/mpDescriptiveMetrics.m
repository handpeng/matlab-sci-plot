function metrics = mpDescriptiveMetrics(truth, prediction)
% Shared Class-B prediction metrics using one common finite sample mask.
x = truth(:); y = prediction(:);
mask = isfinite(x) & isfinite(y);
if ~any(mask), error('matlab_sci_plot:NoCompleteSamples', 'No common complete samples are available.'); end
x = x(mask); y = y(mask); residual = y - x;
ssTotal = sum((x - mean(x)).^2);
if ssTotal == 0, r2 = NaN; else, r2 = 1 - sum(residual.^2) / ssTotal; end
metrics = struct('metric_version','1.0','n_common',sum(mask),'mae',mean(abs(residual)), ...
    'rmse',sqrt(mean(residual.^2)),'r2',r2,'sample_mask',mask, ...
    'sample_policy','common_complete','r2_definition','1-SSE/SST');
end
