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
    % remove mex-based path if applicable
    if verLessThan('matlab', '9.2')
        toolboxRoot = [s.matlab.addons.InstallationFolder.ActiveValue '/Toolboxes/' ...
                       toolboxName '/code'];
    else
        toolboxRoot = [s.matlab.addons.InstallationFolder.ActiveValue '/Toolboxes/' ...
                       toolboxName];
    end
    if any(arrayfun(@(x) contains(x.name, mexext), dir(toolboxRoot), 'uni', true))
        rmpath([toolboxRoot '/' mexext]);
        savepath;
    end
end