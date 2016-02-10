function out = getNewline()
	if ispc
        out = sprintf('\r\n');
    elseif isunix
        out = sprintf('\n');
    else
        error('Newline must be either ''pc'' or ''unix''.');
    end
end