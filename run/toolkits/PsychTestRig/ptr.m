function varargout = ptr(varargin)
%ptr Alias for PsychTestRig

    [varargout{1:nargout('PsychTestRig')}] = PsychTestRig(varargin{:});

end
