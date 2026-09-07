function state = mpApplyTypography(fig, style, varargin)
% Inspect actual rendered text, then apply one CJK font across the hierarchy.
% Optional third argument supplies a deterministic inventory for tests.
drawnow;
objects = findall(fig);
properties = {'String','XTickLabel','YTickLabel','ZTickLabel','TickLabels'};
visibleText = {};
for i = 1:numel(objects)
    object = objects(i);
    % Offscreen figures are intentional. Inspect each text object's own state.
    if isprop(object,'Visible') && strcmp(string(object.Visible),'off'), continue; end
    for j = 1:numel(properties)
        if isprop(object,properties{j})
            visibleText{end+1} = get(object,properties{j}); %#ok<AGROW>
        end
    end
end
state = mpResolveFont(style.typography.font_name, mpContainsCJK(visibleText), varargin{:});
if state.contains_cjk
    fontname(fig, state.resolved_font);
    % R2023b interprets sample identifiers such as 样品_A as subscripts.
    % Keep literal CJK identifiers on ordinary text objects only. Explicit
    % TeX commands/superscripts/braces, English text, legends and ticks retain
    % their existing interpreter behavior; do not rewrite any String value.
    for i = 1:numel(objects)
        object = objects(i);
        if ~isgraphics(object,'text') || ~strcmp(object.Interpreter,'tex'), continue; end
        value = string(object.String);
        if mpContainsCJK(value) && any(contains(value,'_'),'all') && ...
                ~any(contains(value,{char(92),'^','{','}'}),'all')
            object.Interpreter = 'none';
        end
    end
end
% English retains the existing mpApplyStyle/family font behavior unchanged.
% Font size, geometry and scientific data are untouched.
end
