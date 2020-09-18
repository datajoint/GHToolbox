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
    % remove mex-based path if applicable
    if verLessThan('matlab', '9.2')
        toolboxRoot = [strrep(s.matlab.addons.InstallationFolder.ActiveValue, '\', '/') ...
                       '/Toolboxes/' toolboxName '/code'];
    else
        toolboxRoot = [strrep(s.matlab.addons.InstallationFolder.ActiveValue, '\', '/') ...
                       '/Toolboxes/' toolboxName];
    end
    if any(arrayfun(@(x) contains(x.name, mexext), dir(toolboxRoot), 'uni', true))
        rmpath([toolboxRoot '/' mexext]);
        pathfile = fullfile(userpath, 'startup.m');
        if exist(pathfile, 'file') == 2
            fid = fopen(pathfile, 'r');
            f = fread(fid, '*char')';
            fclose(fid);
            f = regexprep(f,strrep(['\naddpath(''' [toolboxRoot '/' mexext] ''');\n'], ...
                                   ')', '\)'), '');
            fid = fopen(pathfile, 'w');
            fprintf(fid,'%s',f);
            fclose(fid);
        end
    end
    % remove all versions of toolbox
    toolboxes = matlab.addons.toolbox.installedToolboxes;
    matched = toolboxes(strcmp(toolboxName, {toolboxes.Name}));
    warning('off','toolboxmanagement_matlab_api:uninstallToolbox:manualCleanupNeeded');
    arrayfun(@(x) matlab.addons.toolbox.uninstallToolbox(x), matched, 'UniformOutput', false);
    warning('on','toolboxmanagement_matlab_api:uninstallToolbox:manualCleanupNeeded');
    if exist(toolboxRoot, 'dir')
        rmdir(toolboxRoot);
    end
end