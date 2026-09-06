function capabilities = mpBackendCapabilities()
% Return declarative MATLAB backend capabilities without exposing handles.
capabilities = struct();
capabilities.backend_id = 'matlab';
capabilities.backend_version = version;
capabilities.available = true;
capabilities.supported_family_ids = {'prediction.parity','relationship.scatter','comparison.metric_panels','distribution.histogram_kde','trend.line'};
capabilities.vector_formats = {'pdf','svg'};
capabilities.raster_formats = {'png'};
capabilities.layout_capabilities = {'tiledlayout','nexttile','sharedlegend','sharedcolorbar'};
capabilities.font_capabilities = {'system_fonts'};
capabilities.interactive_capabilities = {};
capabilities.optional_dependencies = struct('statistics_toolbox', false, 'hatchfill2', false, 'spider_plot', false);
end
