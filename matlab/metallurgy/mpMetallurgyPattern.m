function pattern = mpMetallurgyPattern(question)
% Compose generic families; no domain-specific renderer fork.
key = lower(strrep(char(question), ' ', '_'));
patterns = struct();
patterns.external_generalization = struct('families',{{'prediction.parity','comparison.metric_panels','distribution.histogram_kde'}},'layout','hero_plus_diagnostics');
patterns.model_validation = struct('families',{{'prediction.parity','comparison.metric_panels','distribution.histogram_kde'}},'layout','hero_plus_diagnostics');
patterns.temperature_property = struct('families',{{'relationship.scatter','trend.line','distribution.histogram_kde'}},'layout','overview_plus_small_multiples');
if ~isfield(patterns, key), error('matlab_sci_plot:UnknownDomainPattern','Unknown metallurgy pattern.'); end
pattern = patterns.(key);
pattern.domain = 'metallurgy'; pattern.pattern_id = key;
end
