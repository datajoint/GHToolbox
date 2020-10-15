function install(target, varargin)
    % INSTALL(target, varargin)
    %   Description:
    %     Provides a way to directly 'install' MATLAB Community Toolboxes from 
    %     Github. For upgrade and downgrade use-cases, users can set the `override` option to
    %     force the install.
    %   Inputs:
    %     target[required]: (string) Toolbox repo (e.g. 'org1/repo1') or local path to *.mltbx
    %     version[optional, default='latest']: (string||handle) Version to be installed e.g.
    %                                          '1.0.0' or version handle of the form @(v) that
    %                                          resolves to acceptable versions. Handle approach
    %                                          should expect v to be a cell array of version
    %                                          candidates and return a logical array of result.
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
    %     ghtb.install('guzman-raphael/compareVersions', 'version', '1.0.7')
    %     ghtb.install('guzman-raphael/compareVersions', 'version', '1.0.6', 'override', true)
    %     ghtb.install('guzman-raphael/compareVersions', 'version', ...
    %                  @(v) cellfun(@(x) contains(x, '1.0.'), v, 'uni', true))
    %     ghtb.install('compareVersions.mltbx') %install from local toolbox file
    clear('functions'); %needed for uninstall of mex-based toolboxes
    s = settings;
    p = inputParser;
    addRequired(p, 'target');
    addOptional(p, 'version', 'latest');
    addOptional(p, 'override', false);
    parse(p, target, varargin{:});
    target = strrep(p.Results.target, '\', '/');
    version = p.Results.version;
    override = p.Results.override;
    if ~contains(target, '.mltbx')
        % get release meta (assumes single .mltbx file artifact)
        GitHubAPI = 'https://api.github.com';
        options = weboptions('HeaderFields', {'Accept', ...
                                              'application/vnd.github.v3.raw'}, ...
                             'ContentType', 'json', ...
                             'Timeout', 60);
        if ~isa(version,'function_handle') && strcmp(version, 'latest')
            url = [GitHubAPI '/repos/' target '/releases/latest'];
            data = webread(url, options);
        else
            url = [GitHubAPI '/repos/' target '/releases'];
            data = webread(url, options);
            data = data(~[data.prerelease]);
            [~,index] = sort({data.published_at});
            data = data(flip(index));
            if isa(version,'function_handle')
                index = version({data.tag_name});
            else
                index = find(ismember({data.tag_name}, version));
            end
            data = data(index);
            data = data(1);
        end
        if length(data.assets) == 0
            error('GHToolbox:Release:NotFound', ...
                  ['No matching release found at target ''' target '''.']);
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
        try
            matlab.addons.install(tmp_toolbox, 'overwrite');
        catch ME
            if strcmp(ME.identifier, 'MATLAB:undefinedVarOrClass')
                matlab.addons.toolbox.installToolbox(tmp_toolbox);
            else
                rethrow(ME);
            end
        end
        % remove temp toolbox file
        delete(tmp_toolbox);
    else
        % determine Toolbox name
        [~, toolboxName, ~] = fileparts(target);
        % check if conflict with existing (assumes Toolbox name matches *.mltbx name)
        conflictCheck(toolboxName, override);
        % install
        try
            matlab.addons.install(target, 'overwrite');
        catch ME
            if strcmp(ME.identifier, 'MATLAB:undefinedVarOrClass')
                matlab.addons.toolbox.installToolbox(target);
            else
                rethrow(ME);
            end
        end
    end
end
function conflictCheck(toolboxName, override)
    try
        toolboxes = matlab.addons.installedAddons;
        matched = table2struct(toolboxes(toolboxes.Name == toolboxName, :));
    catch ME
        if strcmp(ME.identifier, 'MATLAB:undefinedVarOrClass')
            toolboxes = matlab.addons.toolbox.installedToolboxes;
            matched = toolboxes(strcmp(toolboxName, {toolboxes.Name}));
        else
            rethrow(ME);
        end
    end
    if length(matched) > 0 && ~override
        error('Error:Toolbox:Conflict', ['Toolbox ''' toolboxName ''' ' ...
                            'detected. To override installation set ''override'' to true.']);
    elseif length(matched) > 0 && override
        ghtb.uninstall(toolboxName);
    end
end