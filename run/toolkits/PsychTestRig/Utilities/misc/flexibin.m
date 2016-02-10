function [binEdges, binCentres, n, binIdx] = flexibin(x, initNBins, minBinSize, maxBinSize, rmEmpty, maxNJoins, maxNSplits)
% FLEXIBIN more flexible binning than can be achieved using hist/histc
%
%   ####
%   Alt method might be to bin all the data, and then rebin the data
%   falling within N standard deviations?
%
%   
% @Parameters:  
%
%    	x               Integer.  	The sampling rate/frequency (Hz).
%                                       e.g. 44100
%     	initNBins     	Real.       Total stimulus duration (used to
%                                       generate the sustain period)                  
%       minBinSize   	Real.       ###############                
%                                       e.g. = #######.
%       maxBinSize   	Real.       ###############                
%                                       e.g. = #######.
%       rmEmpty     	boolean.    #####
%       maxNJoins     	Real.       Onset(/Offset) duration (seconds)
%                                       e.g. = #######.
%       maxNSplits   	Real.       Carrier frequency of the target sinusoid
%                                       e.g. = 
% 
% @Returns:  
%
%    	bin_edges 	Real[]      row vector containing ###
%
%    	bin_centres Real[]      row vector containing ###
%
%    	bin_n       Int[]       row vector containing ###
%
%    	bin_idx 	Logical[] 	row vector containing ###
%
%
%
% @Example:         [binEdges,binCentres,n,binIdx] = flexibin(x);
%                   edges = flexibin(randn(100,1),5,0,1,0,20);
%
% @See also:        
% 
% @Author:          Pete R Jones
%
% @Creation Date:	29/03/11
% @Last Update:     29/03/11
%
% @Todo:            ALL

    % Parse inputs / insert defaults
    if nargin<2 || isempty(initNBins);  initNBins = 10; end;
    if nargin<3 || isempty(minBinSize); minBinSize = 1; end;
    if nargin<4 || isempty(maxBinSize); maxBinSize = 50; end;
    if nargin<5 || isempty(rmEmpty);    rmEmpty = true; end;
    if nargin<6 || isempty(maxNJoins);  maxNJoins = 1; end;
    if nargin<7 || isempty(maxNSplits); maxNSplits = inf; end;



    % construct initial bins
    binEdges = linspace(min(x), max(x), initNBins+1);
    binEdges(end) = binEdges(end) + (binEdges(end)-binEdges(end-1))*.00000001;
%     % !!!!!!!!!!!!
%     fprintf('%1.20f\n',  binEdges(end))
%     fprintf('%1.20f\n',  max(x))
%     % !!!!!!!!!!!!
    
    n = histc(x, binEdges);
    n = n(1:end-1); % The last bin will count any values of X that match EDGES(end)
    if length(x)~=sum(n); error('a:b','c'); end % check

    
    % split up bins with many elements
    try
        binEdges=lcl_split(x,binEdges,maxBinSize);
    catch ME
        warning('a:b','Max Recursions?');
    end
        
        
    %
    % !!!!!!!!!!!!    
%     binEdges
%     n = histc(x, binEdges); n = n(1:end-1)
%     if length(x)~=sum(n); error('a:b','c'); end
%     % !!!!!!!!!!!!    
    

    % join togther bins with few elements
	binEdges=lcl_join(x,binEdges,minBinSize);
    %
%     % !!!!!!!!!!!!    
%     binEdges
%     n = histc(x, binEdges); n = n(1:end-1)
%     if length(x)~=sum(n); error('a:b','c'); end
%     % !!!!!!!!!!!!   


    % calc bin centres
    binCentres = mean([binEdges(1:end-1); binEdges(2:end)], 1);
    
    % remove empty bins (n.b., since this happens after calc'ing centres
    % these centres will no longer (necessarily) correspond to the means of
    % the edges)
    if rmEmpty
        % remove empty bins
        n = histc(x, binEdges); n = n(1:end-1);
        idx = n'==0; % empty bin indices
        binCentres(idx) = []; % remove bin
        idx = [0==1 idx]; % (add 0 to the start since will want to remove the UPPER edge subsequently...)
        binEdges(idx) = []; % remove the upper edge
        %
%         % !!!!!!!!!!!!    
%         binEdges
%         n = histc(x, binEdges); n = n(1:end-1)
%         if length(x)~=sum(n); error('a:b','c'); end
%         % !!!!!!!!!!!!      
    end
    
    
    % recalc (final) indices
    [n, binIdx] = histc(x, binEdges); n = n(1:end-1);
    n = n';
    
end

% currently infininte recursion
function binEdges=lcl_split(x,binEdges,maxN)
    i = 1;
    while i<length(binEdges)
        bin = [binEdges(i) binEdges(i+1)];
        nInBin = histc(x,bin);
        nInBin(end) = []; % remove limit case

        if nInBin > maxN
            newBins = linspace(bin(1),bin(2),3); % interpolate between 2 edges to make 3 edges (i.e. split bin in 2)
            newBins = lcl_split(x,newBins,maxN);
            binEdges = [binEdges(1:i-1) newBins binEdges(i+2:end)];
            i = i + length(newBins) - 1;
        else
            i = i + 1;
        end 
    end
end

% currently zero recursion
function binEdges=lcl_join(x,binEdges,minN)
    i = 1;
    while i<length(binEdges)
        bin = [binEdges(i) binEdges(i+1)];
        nInBin = histc(x,bin);
        nInBin(end) = []; % remove limit case
        
        if nInBin < minN
            newBins = binEdges(i); % remove upper edge, so that the bin will extend to the upper edge of the bin above (i.e. join 2 bins into 1)
%             newBins = lcl_split(x,newBins,maxN); RECURSION DISABLED FOR NOW
            binEdges = [binEdges(1:i-1) newBins binEdges(i+2:end)];
%             i = i + length(newBins) - 1;
%         else
%             i = i + 1;
        end 
        i = i + 1;
    end
end