function [] = fig_dataFormat(hDat,linewidth)
%FIG_DATAFORMAT format data

%
%   Step 5 in the fig package (see: help fig)
%
%   Use this for finishing the formatting of a figure. Add master titles,
%   align the subtitles, set the colours of the figure, etc.
%
%
% @Requires:        fig [package]
%                   Matlab v2008 onwards
%   
% @Input Parameters:
%
%    	hFig        Numeric         Handle to figure
%                                   @default: gcf
%
%    	xTitle      Char            Text for main X label. Use \n for
%                                   linebreaks. It is LaTeX interpreted, so
%                                   enclose mathematics inside dollar signs
%                                   (e.g., $x_{i} = 1$)
%                                   @default: []
%
%    	yTitle      Char            Text for main Y label, as per xTitle
%                                   @default: []
%
%    	mainTitle   Char            Text for main title
%                                   @default: []
%
%    	fontSize    Numeric         Fontsize for main titles
%                                   @default: 14
%
%    	alignLbls   Logical         Whether to realign any axisTitles that
%                                   were created using fig_axesFormat.m
%                                   @default: true
%
% @Returns:  
%
%       hXTitle     Numeric         Handle for main X label
%
%       hYTitle     Numeric         Handle for main Y label
%
%       hTitle      Numeric         Handle for main title
%
% @Syntax:
%
%       [hXTitle,hYTitle,hTitle] = fig_figFormat([hFig], [xTitle],[yTitle],[mainTitle], [fontSize], [alignLbls])
%
% @Example:    
%
%       hFig = gcf;
%       xTitle = 'Age, years';
%       yTitle = 'Height, cm';
%       mainTitle = [];
%       fontSize = [];
%       alignLbls = true;
%       [hXTitle,hYTitle,hTitle] = fig_figFormat(hFig, xTitle,yTitle,mainTitle, fontSize, alignLbls)
%
% @See also:        EXAMPLES.m
% 
% @Author:          Pete R Jones <petejonze@gmail.com>
%
% @Version History: 1.0.0	11/10/11	First Build            	[PJ]
%                   1.0.1	08/10/12	Tweaks & comments       [PJ]
%
% @Todo:            <none>

    if nargin < 2
        linewidth = 1.6;
    end
    
    set(hDat,'linewidth',1.6);
    
end