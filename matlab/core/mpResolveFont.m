function state = mpResolveFont(requestedFont, containsCJK, availableFonts)
% Runtime font resolution. Third argument is an optional inventory test seam.
if ~(ischar(requestedFont) && isrow(requestedFont) || isstring(requestedFont) && isscalar(requestedFont)) || ...
        ismissing(string(requestedFont)) || strlength(string(requestedFont)) == 0 || ...
        ~islogical(containsCJK) || ~isscalar(containsCJK)
    error('matlab_sci_plot:InvalidTypography','Expected a font name and scalar logical CJK state.');
end
requestedFont = char(requestedFont);
policy = mpTypographyPolicy();
state = struct('contains_cjk',containsCJK,'requested_font',requestedFont, ...
    'resolved_font',requestedFont,'font_policy_id',policy.font_policy_id, ...
    'policy_version',policy.policy_version,'resolution','requested_english');
if ~containsCJK, return; end
if nargin < 3, availableFonts = listfonts; end
availableFonts = cellstr(string(availableFonts));
candidates = cellstr(string(policy.candidates));
if any(strcmp(requestedFont,candidates)) && any(strcmp(requestedFont,availableFonts))
    state.resolution = 'requested_cjk'; return;
end
for i = 1:numel(candidates)
    if any(strcmp(candidates{i},availableFonts))
        state.resolved_font = candidates{i}; state.resolution = 'fallback_cjk'; return;
    end
end
error('matlab_sci_plot:CJKFontUnavailable', ...
    'Visible CJK text requires a runtime-available font from policy %s; preview and final export are unavailable.', policy.font_policy_id);
end
