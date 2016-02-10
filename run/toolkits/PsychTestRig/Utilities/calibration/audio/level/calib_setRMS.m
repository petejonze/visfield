function x=calib_setRMS(x,rms)
%     % basic old version
%     old_rms = sqrt(mean(x.^2));
%     x = x.*rms/old_rms;

	% new improved multi-channel version

    
    %% INPUTS

    nChans = size(x,1);
    
    % If single value given for RMS then replace with vector (identical value for each channel) 
 	if length(rms) == 1
        rms = repmat(rms,nChans,1);
    end
    
  	% Similarly the sound input (x) may be a single vector, but multiple
  	% RMS values specified. In this case we'll assume that the user is
  	% being lazy and wants us to split the sound into a matrix (one row
  	% vector per channel)
    if size(x,1) == 1 && length(rms) > 1
        x = repmat(x,length(rms),1);
        nChans = size(x,1); % recalc number of channels
    end
    
    % ensure that RMS is a column vector (not row)
    if size(rms,1) == 1 % (might just be a single item of course, in which case this will do nothing)
        rms = rms'; 
    end

    % check that each channels has an RMS value
    if length(rms) ~= nChans
        error('calib_makeDummy:inputError','Each channel must have an RMS value. Input a single number to use the same value for each channel.');
    end


    %%
%     old_x = x;
    
    for i=1:nChans
        old_rms = sqrt(mean(x(i,:).^2));
        x(i,:) = x(i,:).*rms(i)/old_rms;
    end
    
%     % one line version (for comparison)
%     xAlt = old_x.*repmat(rms./old_rms,1,length(x));
%     x(:,1:10), xAlt(:,1:10)
%     if all(x ~= xAlt); error('a:b','ouch!'); end
    
end