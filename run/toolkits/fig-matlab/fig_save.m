function fns = fig_save(fhandles, fnames, outdir, fileformat, dpi, crop, fnMetaInfo, stampit, varargin)
%FIG_SAVE save the secified figure(s) to various vector and/or bitmap formats.
%
%   Step 6 in the fig package (see: help fig)
%
%   Mostly a wrapper for other export packages, such as export_fig.m.
%   Setting the outdir to NaN will supress all output (useful for
%   toggling outputs on/off).
%
%   Tips: set the legend 'Location' to 'none' to prevent reformatting (this
%           is done automatically in fig_legend)
%
%         set outdir to NaN to supress output
%
%
% @Requires:        fig [package]
%                   Matlab v2008 onwards
%   
% @Input Parameters:
%
%    	fhandles    Numeric[n]      Handles to figure handle(s)
%                                   @default: gcf
%
%    	fnames      Strcell{n}      Output file names (potentially with
%                                   meta info appended, see below). If only
%                                   1 name is specified for multiple
%                                   fig handles then names will be appended
%                                   with their identity (i-of-n)
%                                   @default: 'Unnamed'
%
%    	outdir   Char            Output directory (relative or absolute)
%                                   @default: './' [local dir]
%
%    	fileformat   Strcell{n}      Array of output types. Valid options
%                                   are: {'pdf', 'eps', 'png', 'svg',
%                                   'tikz', 'tiff', 'jpg', 'bmp'}
%                                   @default: {'pdf'}
%
%    	dpi         Numeric         Print quality. For A4 printing 50 = low
%                                   , 150 = high. This only applies to
%                                   bitmap files. Vector formats such as
%                                   .eps are lossless at any scale.
%                                   @default: 100
%
%    	crop        Logical         Whether to crop the image to the
%                                   bounding area
%                                   @default: true
%
%    	fnMetaInfo  Logical         Whether to include meta info in the
%                                   file name, such as the date (useful if
%                                   you don't want to overwrite old files)
%                                   @default: false
%
%    	stampit     Logical         Whether to stamp the bottom of the file
%                                   with metainfo (see f_stampit.m)
%                                   @default: true
%
%    	varargin                    Additional arguments, not processed
%                                   here but passed directly to export_fig
%                                   @default: []
%
% @Returns:  
%
%       fns      Cellstr{n}         Array of output fullfile names
%
%
% @Syntax:
%
%       fig_save([fhandles], [fnames], [outdir], [fileformat], [dpi], [crop], [fnMetaInfo], [stampit], [varargin])
%
% @Example:    
%
%       figure(); plot(1,1,'o'); 
%       %
%       fhandles = gcf;
%       fnames = 'my_fig';
%       outdir = './';
%       fileformat = {'png','pdf'};
%       dpi = 75;
%       crop = true;
%       fnMetaInfo = true;
%       stampit = true;
%       fig_save(fhandles, fnames, outdir, fileformat, dpi, crop, fnMetaInfo, stampit)
%
% @See also:        EXAMPLES.m, f_stampit.m
% 
% @Author:          Pete R Jones <petejonze@gmail.com>
%
% @Version History: 1.0.0	11/10/11	First Build            	[PJ]
%                   1.0.1	08/10/12	Simplified & commented	[PJ]
%
% @Todo:            <none>


    %% Constants
    VALID_SAVE_TYPES = {'pdf', 'eps', 'png', 'svg', 'tikz', 'tiff', 'jpg', 'bmp'};
    verbosity = 1;
    
    %% Process user inputs
    if nargin < 1 || isempty(fhandles)
        fhandles = gcf;
    end
    
    if nargin < 2 || isempty(fnames)
        fnames = {'Unnamed'};
    end
    if ~iscell(fnames)
        fnames = {fnames};
    end
    
    
    if nargin < 3 || isempty(outdir)
        outdir = './';
    end
    
    % abort - useful for toggling fig_save on/off in a large script
    if isnan(outdir)
        return
    end

    if nargin < 4 || isempty(fileformat)
        fileformat = {'pdf'};
    end
    if ~iscell(fileformat)
        fileformat = {fileformat};
    end
    if ~any(cellfun(@(x)any(strcmpi(x,VALID_SAVE_TYPES)),fileformat))
        txt = sprintf('%s, ',VALID_SAVE_TYPES{:}); txt = txt(1:end-2);
        txt2 = sprintf('%s, ',fileformat{:}); txt2 = txt2(1:end-2);
        error('fig_save:invalidInput', 'No valid save-format detected.\nValid options are: %s\n\n(You requested: %s)\n', txt, txt2);
    end
    
    if nargin < 5 || isempty(dpi)
        dpi = 100;
    end
    
    if nargin < 6 || isempty(crop)
        crop = true;
    end
    if crop
        cropFlag = [];
    else
        cropFlag = '-nocrop';
    end
    
    nFigs = length(fhandles);
    
    
    if nargin < 7 || isempty(fnMetaInfo)
        fnMetaInfo = false; % include meta info in filename
    end
        
   	if nargin < 8 || isempty(stampit)
        stampit = false;
    end
    
    %% Output
    fns = {};
      
    
    for fnum=1:nFigs
        
        % add stamp if requested
        if stampit
            f_stampit();
        end
    
        % compute output file name
        if nFigs > 1
            if length(fnames) == 1
                fname=fullfile(outdir,sprintf('%s-%iof%i',fnames{1},fnum,nFigs));
            else
                fname=fullfile(outdir,fnames{fnum});
            end
        else
            fname=fullfile(outdir,fnames{1});
        end
        % append meta info
        if fnMetaInfo
            fname = sprintf('%s.%s',fname,datestr(now,30));
        end
            
        % save
        for saveType = fileformat
            ftype = lower(saveType{:});
            fn = sprintf('%s.%s', fname, ftype);
                 
            % print to console
            if verbosity > 0
                fprintf('   exporting figure: %s', fn);
            end
        
            fns{end+1} = fn; %#ok
            switch ftype
                case {'pdf', 'eps', 'tiff', 'jpg', 'bmp'}
                    set(fhandles(fnum), 'PaperPositionMode', 'auto');
                    export_fig(fn,['-' ftype],cropFlag,fhandles(fnum));
                case 'png'
                    if ismac % export_fig seems to work better..
                        export_fig(fn,'-png',cropFlag,'-painters',sprintf('-r%i',dpi),varargin{:},fhandles(fnum)); %zbuffer and opengl don't seem to work well with latex text
                    else
                        %print(fhandles(fnum),'-dpng',sprintf('-r%i',dpi), fn);	% print @ given dpi quality
                        % export_fig also seems to work better on windows
                        % (e.g., no more panels randomly disappearing!)
%                         export_fig(fn,'-png',cropFlag,'-painters',sprintf('-r%i',dpi),varargin{:},fhandles(fnum));
                        export_fig(fn,'-png',cropFlag,sprintf('-r%i',dpi),varargin{:},fhandles(fnum));
                    end
                case 'svg'
                    if ~isempty(which('plot2svg')) %ALT: exist(...
                        plot2svg(fn);
                    else
                        warning('fig_save:missingEngine','svg was requested, but no svg export engine was found.\nMake sure plot2svg.m is on the path');
                    end
                case 'tikz' % UNTESTED! (unlikely to work)
                    if ~isempty(which('matlab2tikz')) %ALT: exist(...
                        matlab2tikz(fn);
                    else
                        warning('fig_save:missingEngine','tikz was requested, but no tikz export engine was found.\nMake sure matlab2tikz.m is on the path');
                    end
                otherwise
                    fns(end) = []; % remove from return list
                    warning('fig_save:unknownMethod','Unknown method: %s. Will ignore\n',ftype)
            end
            
            % print to console
            if verbosity > 0
                fprintf('\n');
            end
        end

    end
    
end