function missingFields=getMissingRequiredFields()
%GETMISSINGREQUIREDFIELDS shortdescr.
%
% Description    - basically a modification of isSetupComplete
%
% Example: none
%
% See also
% 
% @Author: Pete R Jones
% @Date: 22/01/10
  
    %initialise local variables
    missingFields={};
    requiredFields = getRequiredFields();

    %find each required field is: i) not present; OR ii) blank (i.e. x=='')
    x=1;
    for i=1:length(requiredFields);
        fieldName = requiredFields{i};
        if isempty(getPrefVal(fieldName,true)) 
           missingFields{x} = fieldName;
           x = x + 1;
        end
    end

end