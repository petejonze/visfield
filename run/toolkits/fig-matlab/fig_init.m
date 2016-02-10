function [outdir, fileformat] = fig_init(pkgVer, fileformat, outdir)
%FIG_INIT initialise fig parameters.
%
%   Step 0 in the fig package (see: help fig)
%
%   Validation script. If the output directory is not found then one will
%   be created. It is not necessary to call this before using other
%   functions. However, it may improve the clarity/ organisation of your
%   code to use this function.
%
%
% @Requires:        fig [package]
%                   Matlab v2008 onwards
%   
% @Input Parameters:
%
%       pkgVer      Numeric         The expected version of the fig
%                                   package. An error/warning will be
%                                   thrown if the found version is less or
%                                   more than this value, respectively
%                                   @default: []
%
%    	fileformat  Cellstr         Output file formats (cf., help fig_save
%                                   for valid options)
%                                   @default: {'pdf','png'}
%
%    	outdir      Char            File directory (relative or absolute)
%                                   @default: ./Figs/<timestamp>
%
%
% @Returns:  
%
%    	outdir      Char            File directory
%
%    	fileformat  Cellstr         Output file formats 
%
%
% @Syntax:
%
%       fig_init([pkgVer], [outdir], [fileformat])
%
% @Example:    
%
%    	pkgVer = 0.3;
%      	[exportDir, exportFormat] = fig_init(pkgVer);
%   	figure(); plot(randn(20,2),'o');
%     	fig_save([], 'tmpFig', exportDir, exportFormat);
%
% @See also:        EXAMPLES.m
% 
% @Author:          Pete R Jones <petejonze@gmail.com>
%
% @Version History: 1.0.0	08/10/12	First Build            	[PJ]
%
% @Todo:            - Further validation
%                   - Remove use of ptr scripts
%                   - Does it really make sense to have fileformat here?

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Init (process inputs)
        
    if nargin < 1
        pkgVer = [];
    end

    if nargin < 2 || isempty(fileformat)
        fileformat = {'pdf','png'};
    end
    
    if nargin < 3 || isempty(outdir)
        outdir = sprintf('./Figs/%s',datestr(now,1));
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Main
    % check requisite fig version is on path
    if ~isempty(pkgVer)
        if isnumeric(pkgVer)
            pkgVer = num2str(pkgVer); % verLessThan only takes strings
        end
        % check fig package version
        if verLessThan('fig-matlab',pkgVer)
            error('fig_make:oldFigPackage','The installed version of the FIG package (%s) predates the expected version (%s). Please install a newer version of the package, or request an older version when invoking fig_make()',getversion('fig-matlab'),pkgVer);
        end
        if verGreaterThan('fig-matlab',pkgVer)
            fprintf('The installed version of the FIG package (%s) is newer the expected version (%s)\n',getversion('fig-matlab'),pkgVer);
            if ~getLogicalInput('continue (y/n)?');
                error('fig_make:userAbort','figure creation aborted');
            end
        end
    end
    
    % Create output directory if necessary
    if ~any(isnan(outdir)) && ~exist(outdir,'dir') % create export folder
        fprintf('%s not found, creating...\n', fullfile(pwd(), outdir(2:end)));
        mkdir(outdir);
    end
    
    % Make all fonts latex by default
   	set(0,'DefaultTextInterpreter','latex')
    
        
end