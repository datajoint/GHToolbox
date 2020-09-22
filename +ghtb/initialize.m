function initialize(varargin)
    % INITIALIZE(varargin)
    %   Description:
    %     Internal function to load GHToolbox's dependencies.
    %   Inputs:
    %     force[optional, default=false]: (boolean) Determine if using cache or re-trigger
    %                                     dependency resolver.
    %     prompt[optional, default=true]: (boolean) Whether to silently install or use prompts.
    %   Examples:
    %     ghtb.initialize
    %     ghtb.initialize('prompt', false)
    %     ghtb.initialize('force', true)
    %     ghtb.initialize('force', true, 'prompt', false)
    p = inputParser;
    addOptional(p, 'force', false);
    addOptional(p, 'prompt', true);
    parse(p, varargin{:});
    force = p.Results.force;
    prompt = p.Results.prompt;
    % only trigger first invokation or with 'force' set
    persistent INVOKED
    if ~isempty(INVOKED) && ~force
        return
    end
    % require certain toolboxes
    requiredToolboxes = {...
        struct(...
            'Name', 'compareVersions', ...
            'ResolveTarget', 'guzman-raphael/compareVersions'...
        ) ...
    };
    ghtb.require(requiredToolboxes, 'prompt', prompt, 'resolveGHToolboxDeps', false);
    % set cache
    INVOKED = true;
end