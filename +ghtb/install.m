function install(repository, varargin)
    % INSTALL(repository, varargin)
    %   Description:
    %     Provides a way to directly 'install' MATLAB Community Toolboxes as addons from 
    %     Github. For upgrade and downgrade use-cases, users can set the `override` option to
    %     force the install.
    %   Inputs:
    %     repository[required]: (string) Target repo for Toolbox e.g. 'org1/repo1'
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
    p = inputParser;
    addRequired(p, 'repository');
    addOptional(p, 'version', 'latest');
    addOptional(p, 'override', false);
    parse(p, repository, varargin{:});
    repository = p.Results.repository;
    version = p.Results.version;
    override = p.Results.override;
    % get release meta (assumes single .mltbx file artifact)
    GitHubAPI = 'https://api.github.com';
    if strcmp(version, 'latest')
        url = [GitHubAPI '/repos/' repository '/releases/latest'];
        options = weboptions('HeaderFields', {'Accept', 'application/vnd.github.v3.raw'}, ...
                             'ContentType', 'json');
        data = webread(url, options);
    else
        url = [GitHubAPI '/repos/' repository '/releases'];
        options = weboptions('HeaderFields', {'Accept', 'application/vnd.github.v3.raw'}, ...
                             'ContentType', 'json');
        data = webread(url, options);
        % need to optimize to break out on first match
        data = data(arrayfun(@(x) strcmp(x.tag_name, version), data, 'UniformOutput', true));
    end
    % check if conflict with existing (assumes Toolbox name matches *.mltbx name)
    addons = matlab.addons.installedAddons;
    existing_id = addons.Identifier(addons.Name == data.assets.name(1:end-6));
    if length(existing_id) > 0 && ~override
        error('Error:Toolbox:Conflict', ['Toolbox ''' data.assets.name(1:end-6) ''' ' ...
                            'detected. To override installation set ''override'' to true.']);
    elseif length(existing_id) > 0 && override
        arrayfun(@(x) matlab.addons.uninstall(x), existing_id, 'UniformOutput', false);
    end
    % download
    options = weboptions('HeaderFields', {'Accept', 'application/octet-stream' });
    tmp_toolbox = [tempname '.mltbx'];
    status = websave(tmp_toolbox, data.assets.url, options);
    % install
    matlab.addons.install(tmp_toolbox);
    % remove temp toolbox file
    delete(tmp_toolbox);
end