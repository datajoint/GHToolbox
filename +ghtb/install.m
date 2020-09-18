function install(target, varargin)
    % INSTALL(target, varargin)
    %   Description:
    %     Provides a way to directly 'install' MATLAB Community Toolboxes from 
    %     Github. For upgrade and downgrade use-cases, users can set the `override` option to
    %     force the install.
    %   Inputs:
    %     target[required]: (string) Toolbox repo (e.g. 'org1/repo1') or local path to *.mltbx
    %     version[optional, default='latest']: (string) Version to be installed e.g. '1.0.0'
    %     override[optional, default=false]: (boolean) Flag to indicate if should override an
    %                                        existing install
    %   Assumptions:
    %     - Community Toolbox linked on FileExchange to GitHub via GitHub Releases.
    %     - Community Toolbox publicly available as open-source on GitHub.
    %     - Community Toolbox attaches a single '.mltbx' artifact to GitHub Releases.
    %     - Community Toolbox name matches the filename of '.mltbx' artifact.
    %     - Users do not wish to have multiple simultaneous versions installed i.e. only a 
    %       single version per Toolbox is installed at any given time.
    %   Examples:
    %     ghtb.install('guzman-raphael/compareVersions')
    %     ghtb.install('guzman-raphael/compareVersions', 'version', '1.0.5')
    %     ghtb.install('guzman-raphael/compareVersions', 'version', '1.0.4', 'override', true)
    clear('functions'); %needed for uninstall of mex-based toolboxes
    s = settings;
    p = inputParser;
    addRequired(p, 'target');
    addOptional(p, 'version', 'latest');
    addOptional(p, 'override', false);
    parse(p, target, varargin{:});
    target = p.Results.target;
    version = p.Results.version;
    override = p.Results.override;
    if ~contains(target, '.mltbx')
        % get release meta (assumes single .mltbx file artifact)
        GitHubAPI = 'https://api.github.com';
        if strcmp(version, 'latest')
            url = [GitHubAPI '/repos/' target '/releases/latest'];
            options = weboptions('HeaderFields', {'Accept', ...
                                                  'application/vnd.github.v3.raw'}, ...
                                'ContentType', 'json');
            data = webread(url, options);
        else
            url = [GitHubAPI '/repos/' target '/releases'];
            options = weboptions('HeaderFields', {'Accept', ...
                                                  'application/vnd.github.v3.raw'}, ...
                                'ContentType', 'json');
            data = webread(url, options);
            % need to optimize to break out on first match
            data = data(arrayfun(@(x) strcmp(x.tag_name, version), data, ...
                                 'UniformOutput', true));
        end
        % determine Toolbox name
        toolboxName = data.assets.name(1:end-6);
        % check if conflict with existing (assumes Toolbox name matches *.mltbx name)
        conflictCheck(toolboxName, override);
        % download
        headers = {...
            'Content-Type', 'application/octet-stream'; ...
            'Accept', 'application/octet-stream'...
        };
        options = weboptions(...
            'HeaderFields', headers, ...
            'RequestMethod', lower('GET'), ...
            'Timeout', 60, ...
            'CertificateFilename', 'default', ...
            'ContentType', 'binary', ...
            'MediaType', 'application/octet-stream', ...
            'CharacterEncoding', 'ISO-8859-1'...
        );
        tmp_toolbox = [tempname '.mltbx'];
        status = websave(tmp_toolbox, data.assets.url, options);
        % install
        matlab.addons.toolbox.installToolbox(tmp_toolbox);
        % remove temp toolbox file
        delete(tmp_toolbox);
    else
        % determine Toolbox name
        [~, toolboxName, ~] = fileparts(target);
        % check if conflict with existing (assumes Toolbox name matches *.mltbx name)
        conflictCheck(toolboxName, override);
        % install
        matlab.addons.toolbox.installToolbox(target);
    end
    % add mex-based path if applicable
    if verLessThan('matlab', '9.2')
        toolboxRoot = [strrep(s.matlab.addons.InstallationFolder.ActiveValue, '\', '/') ...
                       '/Toolboxes/' toolboxName '/code'];
    else
        toolboxRoot = [strrep(s.matlab.addons.InstallationFolder.ActiveValue, '\', '/') ...
                       '/Toolboxes/' toolboxName];
    end
    if any(arrayfun(@(x) contains(x.name, mexext), dir(toolboxRoot), 'uni', true))
        addpath([toolboxRoot '/' mexext]);
        pathfile = fullfile(userpath, 'startup.m');
        fid = fopen(pathfile, 'a+');
        fprintf(fid, '\n%s\n',['addpath(''' [toolboxRoot '/' mexext] ''');']);
        fclose(fid);
    end
end
function conflictCheck(toolboxName, override)
    toolboxes = matlab.addons.toolbox.installedToolboxes;
    matched = toolboxes(strcmp(toolboxName, {toolboxes.Name}));
    if length(matched) > 0 && ~override
        error('Error:Toolbox:Conflict', ['Toolbox ''' toolboxName ''' ' ...
                            'detected. To override installation set ''override'' to true.']);
    elseif length(matched) > 0 && override
        ghtb.uninstall(toolboxName);
    end
end