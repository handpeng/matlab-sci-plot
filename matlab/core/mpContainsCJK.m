function found = mpContainsCJK(text)
% Deterministic Unicode capability gate; numeric data is never made into text.
policy = mpTypographyPolicy();
found = inspect(text, policy.unicode_ranges);
end

function found = inspect(value, ranges)
found = false;
if iscell(value)
    for i = 1:numel(value)
        if inspect(value{i},ranges), found = true; return; end
    end
elseif isstring(value) || ischar(value)
    if ischar(value), value = string(cellstr(value)); end
    for i = 1:numel(value)
        if ismissing(value(i)), continue; end
        % MATLAB char uses UTF-16: combine surrogate pairs before range checks.
        units = double(char(value(i))); j = 1;
        while j <= numel(units)
            point = units(j);
            if point >= hex2dec('D800') && point <= hex2dec('DBFF') && j < numel(units) && ...
                    units(j+1) >= hex2dec('DC00') && units(j+1) <= hex2dec('DFFF')
                point = 65536 + (point-55296)*1024 + units(j+1)-56320;
                j = j + 1;
            end
            if any(point >= ranges(:,1) & point <= ranges(:,2))
                found = true; return;
            end
            j = j + 1;
        end
    end
end
end
