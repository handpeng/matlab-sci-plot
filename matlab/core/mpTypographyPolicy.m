function policy = mpTypographyPolicy()
% Shared authority for Python and MATLAB; no platform-local candidate lists.
rootDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
policy = jsondecode(fileread(fullfile(rootDir,'policies','cjk_typography.json')));
end
