function require(requiredToolboxes, varargin)
    % REQUIRE(requiredToolboxes, varargin)
    %   Description:
    %     Provides a way to directly require specific toolboxes with the option to 'install' if
    %     not satisfied. Unsatisfied toolboxes with trigger a
    %     'GHToolbox:requireToolboxes:Failed' error.
    %   Inputs:
    %     requiredToolboxes[required]: (cell) Toolboxes to be required and (if applicable)
    %                                  resolved with installation. Each cell should contain a
    %                                  struct with fields: Name[required, string],
    %                                  ResolveTarget[required, string],
    %                                  Version[optional, string||handle]. For Version
    %                                  specification, see below for examples or
    %                                  see help(ghtb.install) for accepted Version assignment.
    %     prompt[optional, default=true]: (boolean) Whether to silently install or use prompts.
    %     resolveGHToolboxDeps[optional, default=true]: (boolean) Resolve dependencies related
    %                                                   to GHToolbox.
    %   Examples:
    %     requiredToolboxes = {...
    %         struct(...
    %             'Name', 'GHToolbox', ...
    %             'ResolveTarget', 'datajoint/GHToolbox'...
    %         ), ...
    %         struct(...
    %             'Name', 'compareVersions', ...
    %             'ResolveTarget', 'guzman-raphael/compareVersions', ...
    %             'Version', '1.0.8'...
    %         ), ...
    %         struct(...
    %             'Name', 'mym', ...
    %             'ResolveTarget', 'datajoint/mym', ...
    %             'Version', @(v) cellfun(@(x) contains(x, '2.7.'), v, 'uni', true)...
    %         )...
    %     };
    %     ghtb.require(requiredToolboxes) % require with prompts
    %     ghtb.require(requiredToolboxes, 'prompt', false)
    p = inputParser;
    addOptional(p, 'prompt', true);
    addOptional(p, 'resolveGHToolboxDeps', true);
    parse(p, requiredToolboxes, varargin{:});
    prompt = p.Results.prompt;
    resolveGHToolboxDeps = p.Results.resolveGHToolboxDeps;
    % resolve GHToolbox dependencies
    if resolveGHToolboxDeps
        ghtb.initialize('prompt', prompt);
    end
    % determine installed toolboxes
    try
        toolboxes = table2struct(matlab.addons.installedAddons);
        toolboxes = arrayfun(@(x) subsasgn(x(1), substruct('.', 'Name'), char(x(1).Name)), ...
                             toolboxes, 'uni', true);
        toolboxes = arrayfun(@(x) subsasgn(x(1), substruct('.', 'Version'), ...
                                           char(x(1).Version)), toolboxes, 'uni', true);
    catch ME
        if strcmp(ME.identifier, 'MATLAB:undefinedVarOrClass')
            toolboxes = matlab.addons.toolbox.installedToolboxes;
        else
            rethrow(ME);
        end
    end
    installPromptMsg = {
        'Toolbox ''%s'' did not meet the minimum requirements.'
        'Would you like to proceed with the install?'
    };
    for tb = requiredToolboxes
        matched = toolboxes(strcmp(tb{1}.Name, {toolboxes.Name}));
        if ~isfield(tb{1}, 'Version') && any(arrayfun(@(x) strcmp(x.Name, tb{1}.Name), ...
                                             matched, 'uni', true))
            % toolbox found
        elseif isfield(tb{1}, 'Version') && any(arrayfun(@(x) strcmp(x.Name, tb{1}.Name) &&(...
                ischar(tb{1}.Version) && compareVersions({x.Version}, tb{1}.Version) || ...
                isa(tb{1}.Version,'function_handle') && tb{1}.Version({x.Version})...
                ), matched, 'uni', true))
            % toolbox found with appropriate version
        elseif ~isfield(tb{1}, 'Version') && ~isempty(tb{1}.ResolveTarget) && ...
                (~prompt || strcmpi('yes', ...
                                    ask(sprintf(sprintf('%s\n', ...
                                                        installPromptMsg{:}), ...
                                                tb{1}.Name))))
            % toolbox not found so triggering process to install latest
            ghtb.install(tb{1}.ResolveTarget, 'override', true, 'version', 'latest');
        elseif isfield(tb{1}, 'Version') && ~isempty(tb{1}.ResolveTarget) && ...
                (~prompt || strcmpi('yes', ...
                                    ask(sprintf(sprintf('%s\n', ...
                                                        installPromptMsg{:}), ...
                                                tb{1}.Name))))
            % toolbox not found so triggering process to install specific version
            ghtb.install(tb{1}.ResolveTarget, 'override', true, 'version', tb{1}.Version);
        else
            error('GHToolbox:requireToolboxes:Failed', ...
                  ['Toolbox ''' tb{1}.Name ''' is required but did not find ' ...
                   'a matching version.']);
        end
    end
end
function choice = ask(question, choices)
    if nargin<=1
        choices = {'yes','no'};
    end
    choice = '';
    choiceStr = sprintf('/%s',choices{:});
    while ~ismember(choice, lower(choices))
        choice = lower(input([question ' (' choiceStr(2:end) ') > '], 's'));
    end
end