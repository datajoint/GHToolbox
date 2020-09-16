function uninstall(varargin)
    % UNINSTALL(varargin)
    %   Description:
    %     Provides a way to directly 'uninstall' MATLAB Community Toolboxes as addons from 
    %     Github.
    %   Inputs:
    %     toolbox[required]: (string) Toolbox name to be uninstalled e.g. 'toolbox1'
    %   Assumptions:
    %     - Users do not wish to have multiple simultaneous versions installed i.e. all
    %       versions of specified toolbox are uninstalled (if applicable).
    %   Examples:
    %     ghtb.uninstall('compareVersions') % uninstalls all versions of Toolbox
    p = inputParser;
    addRequired(p, 'toolbox');
    parse(p, varargin{:});
    toolbox = p.Results.toolbox;
    % remove all versions of toolbox
    addons = matlab.addons.installedAddons;
    existing_id = addons.Identifier(addons.Name == toolbox);
    arrayfun(@(x) matlab.addons.uninstall(x), existing_id, 'UniformOutput', false);
end