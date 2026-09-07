function output = mpExport(fig, path, options)
% Native exportgraphics boundary; caller records backend/version in evidence.
arguments
    fig
    path (1,1) string
    options.Format (1,1) string = "png"
    options.Resolution (1,1) double = 300
end
if ~isgraphics(fig, 'figure'), error('matlab_sci_plot:InvalidFigure','Expected a figure handle.'); end
exportgraphics(fig, path, 'Resolution', options.Resolution);
output = struct('path', char(path), 'format', char(options.Format), 'backend', 'matlab');
end
