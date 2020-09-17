function uninstall(varargin)
    % UNINSTALL(varargin)
    %   Description:
    %     Provides a way to directly 'uninstall' MATLAB Community Toolboxes from 
    %     Github.
    %   Inputs:
    %     toolboxName[required]: (string) Toolbox name to be uninstalled e.g. 'toolbox1'
    %   Assumptions:
    %     - Users do not wish to have multiple simultaneous versions installed i.e. all
    %       versions of specified toolbox are uninstalled (if applicable).
    %   Examples:
    %     ghtb.uninstall('compareVersions') % uninstalls all versions of Toolbox
    clear('functions'); %needed for uninstall of mex-based toolboxes
    s = settings;
    p = inputParser;
    addRequired(p, 'toolboxName');
    parse(p, varargin{:});
    toolboxName = p.Results.toolboxName;
    % remove all versions of toolbox
    toolboxes = matlab.addons.toolbox.installedToolboxes;
    matched = toolboxes(strcmp(toolboxName, {toolboxes.Name}));
    arrayfun(@(x) matlab.addons.toolbox.uninstallToolbox(x), matched, 'UniformOutput', false);
    % add mex-based paths if applicable
    if any(arrayfun(@(x) contains(x.name, mexext), ...
                    dir([s.matlab.addons.InstallationFolder.ActiveValue '/Toolboxes/' ...
                         toolboxName]), 'uni', true))
        rmpath([s.matlab.addons.InstallationFolder.ActiveValue '/Toolboxes/' toolboxName ...
                 '/' mexext]);
        savepath;
    end
end