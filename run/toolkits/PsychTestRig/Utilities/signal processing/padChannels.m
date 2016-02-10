function audioMatrix = padChannels(x, testChans, outChans)
% PADCHANNELS pad unused output (audio) channels with zeros
%
%   <Further Info>
%
% @Parameters:             
%
%     	x         	Real[]  	#####
%                                	e.g. #####
%     	testChans  	Int[]   	#####
%                                   e.g. #####
%     	outChans  	Real[]    	#####
%                                   e.g. #####
% @Returns:  
%
%    	x       	Real      Signal vector (time-domain)
%
% @Usage:           [x] = padChannels(x, testChans, outChans)
% @Example:         x = padChannels(1:10,[0 3],[0 1 2 3])
%                   x = padChannels(1:10,[1],[0 1])
%                   x = padChannels(1:10,[0 1],[0 1])
%
% @Requires:        PsychTestRig2
%   
% @See also:        #####
%
% @Matlab:          v2008 onwards
%
% @Author(S):    	Pete R Jones
%
% @Creation Date:	26/11/2011
% @Last Update:     26/11/2011
%
% @Current Verion:  1.0.0
% @Version History: v1.0.0	26/11/2011    Initial build.
%
% @Todo:            Lots!
    
    %% INIT
    nDataChans = size(x, 1);
    nTestChans = length(testChans);
    nOutChans = length(outChans);
    
    if nDataChans == 1 && nTestChans > 1 % assume want to duplicate
        x = repmat(x, nTestChans, 1);
    end
       
    nDataChans = size(x, 1);
    if nDataChans ~= nTestChans
        error('padChannels:invalidInput','number of test channels (%i) does''t match number of data channels (%i)',nTestChans,nDataChans);
    end
            
    if ~all(ismember(testChans,outChans)) % if not all of the test channels are in the output channel list
        testChans = testChans(:) %#ok
        outChans = outChans(:) %#ok
        error('padChannels:invalidInput','not all test channels contained within list of output channels');
    end

    n = size(x, 2);

    
    %% PAD
    audioMatrix = zeros(nOutChans, n);

    for i = 1:nDataChans
        idx = testChans(i)+1; % +1 since matlab indexes from 1, not 0
        audioMatrix(idx,:) = x(i,:);
    end
  
end