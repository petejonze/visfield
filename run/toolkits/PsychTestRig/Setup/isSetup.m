function ok=isSetup()
%ISSETUP shortdescr.
%
% Description    - v. simple wrapper for checkSetup
%
% Example: none
%
% See also
% 
% @Author: Pete R Jones
% @Date: 22/01/10
  
    prefs = getPrefVal();
    if isempty(prefs)
        ok = false;
    else
        ok=checkSetup(getPrefVal(),'silent',true);
    end

end