function viewSetup(varargin)
%VIEWSETUP shortdescr.
%
% Description
%
% Example: none
%
% See also exportSetup, checkSetup
% 
% @Author: Pete R Jones
% @Date: 22/01/10

% distinguish between partial and complete setup?

%     %----------------------------------------------------------------------
%     % Parse & validate all input args
%     p = inputParser;
%     p.FunctionName = 'VIEWSETUP';
%     p.parse(varargin{:});
%     %----------------------------------------------------------------------
    
%     %check that we are good to go
%     isSetupComplete();
    
    %get preferences
    prefs=getPrefVal();
    
    %strip out 'lastUpdate' and 'setupComplete' and save for later
    if isfield(prefs,'lastUpdate')
        lastUpdate=prefs.lastUpdate;  %extract value
        prefs = rmfield(prefs,'lastUpdate'); %remove value from original structure
    end    
    
    %alphabetically order the top-level fields for viewing
    prefs = orderfields(prefs);
        
    %output info to console
    cloutput('%line')
    cloutput('/***** PsycTestRig setup *****/')
    cloutput(['Last Updated: ' lastUpdate])
    cloutput('%line')
    dispStruct(prefs)
    cloutput('%line')
    if (isSetup())
        disp('Setup Valid & Complete.')
    else
        %missingFields=getMissingRequiredFields();
        disp('!!Setup Invalid!!')
        disp('Type "PsychTestRig -checkSetup" for details.')
        %disp('The following required fields are missing or empty:')
        %disp(missingFields')
    end
    cloutput('%line')
end