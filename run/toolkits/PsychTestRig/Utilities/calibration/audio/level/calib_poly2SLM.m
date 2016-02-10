function calib = calib_poly2SLM(calib, chanIdx, freqIdx, yMin, yMax, saveFile)
% yMin to yMax significant since SLM doesn't permit extrapolation

    % init
    calib = calib_load(calib);
    if nargin<4 || isempty(yMin)
        yMin = 0;
    end
    if nargin<5 || isempty(yMax)
        yMax = 114;
    end 
    if nargin<6 || isempty(saveFile)
        saveFile = true;
    end

    % get poly
    P = calib.channels(chanIdx).freqs(freqIdx).fit.poly;
    nPoly = length(P.coefs)-1;
    
    % convert
    lrms = ipolyval(P.coefs,[yMin yMax]);
    if nPoly > 1 % untested
        warning('calib_poly2SLM:UntestedFeature','This script has not been tested for poly > 1');
        SLM = slmengine(lrms,[yMin yMax],'knots',nPoly+1,'plot','off','interiorknots','free'); % see "shape prescriptive modeling.rtf"
    else
        SLM = slmengine(lrms,[yMin yMax],'knots',nPoly+1,'plot','off','degree','linear'); % see "shape prescriptive modeling.rtf"
    end
        
    % set SLM
    calib.channels(chanIdx).freqs(freqIdx).fit.SLM = SLM;
    
    % save
    if saveFile
        calib_save(calib,[],true); % save
    end
    
end