function varargout = version
    % VERSION()
    %   Description:
    %     Prints GHToolbox version.
    %   Outputs:
    %     version: (string) Current semantic version e.g. '0.0.0'
    %   Examples:
    %     ghtb.version % display GHToolbox version
    %     v = ghtb.version % return GHToolbox version
    %   License:
    %     MIT (use/copy/change/redistribute on own risk)
    v = '1.0.4';
    if nargout
        varargout{1}=v;
    else
        fprintf('\nVersion %s\n\n', v);
    end
end