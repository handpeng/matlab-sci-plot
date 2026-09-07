function registry = mpFamilyRegistry(rootDir)
% Discover family metadata from manifests; renderer functions are entrypoint data.
if nargin < 1 || strlength(string(rootDir)) == 0
    rootDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
end
manifestDir = fullfile(rootDir, 'manifests', 'families');
files = dir(fullfile(manifestDir, '*.json'));
registry = struct('id', {}, 'manifest_version', {}, 'communication_tasks', {}, ...
    'data_roles_required', {}, 'renderer_backend', {}, 'matlab_renderer', {}, 'status', {});
for i = 1:numel(files)
    payload = jsondecode(fileread(fullfile(files(i).folder, files(i).name)));
    if ~isfield(payload, 'manifest_version') || startsWith(string(payload.manifest_version), '2.')
        error('matlab_sci_plot:UnsupportedManifest', 'Unsupported family manifest version.');
    end
    entry = struct();
    entry.id = char(string(payload.id));
    entry.manifest_version = char(string(payload.manifest_version));
    entry.communication_tasks = cellstr(string(payload.communication_tasks));
    entry.data_roles_required = cellstr(string(payload.data_roles_required));
    entry.renderer_backend = char(string(payload.renderer_backend));
    if isfield(payload, 'matlab_renderer')
        entry.matlab_renderer = char(string(payload.matlab_renderer));
    else
        entry.matlab_renderer = 'mpRenderUnsupportedFamily';
    end
    entry.status = char(string(payload.status));
    registry(end+1) = entry; %#ok<AGROW>
end
end
