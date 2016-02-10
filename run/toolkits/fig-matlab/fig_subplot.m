function [hAxes] = fig_subplot(M,N, varargin)
%FIG_SUBPLOT improved subplotting.
%
%   Can be used in 2 ways. If single input argument is given, then this is
%   the subplot-number for which to set focus. If two or more input
%   arguments are given, then a new lattice plot with the specified number
%   of MxN panels.
%
%   The mapping from panel to axes handle is maintained explicitly through
%   a persistant matrix variable. This is preferable then computing the
%   mapping at runtime from the global stack, since the order of objects is
%   liable to change.
%
%   Adapted from subplot1.m, by Eran Ofek (01/2006)
%
%
% @Requires:        fig [package]
%                   Matlab v2008 onwards
%   
% @Input Parameters:
%
%    	M           Numeric         Integer, number of rows in each column
%                                   @default: []
%
%    	N           Numeric         Integer, number of columns in each row
%                                   @default: []
%
%    	varargin                    See below for options
%                                   @default: []
%
%       * variable parameters
%            (in pairs: ...,Keywoard, Value,...)
%           - 'Min'    : X, Y lower position of lowest subplot,
%                        default is [0.10 0.10].
%           - 'Max'    : X, Y largest position of highest subplot,
%                        default is [0.95 0.95].
%           - 'Gap'    : X,Y gaps between subplots,
%                        default is [0.01 0.01].
%           - 'XTickL' : x ticks labels option,
%                        'Margin' : plot only XTickLabels in the
%                                   subplot of the lowest  row (default).
%                        'All'    : plot XTickLabels in all subplots.
%                        'None'   : don't plot XTickLabels in subplots.
%           - 'YTickL' : y ticks labels option,
%                        'Margin' : plot only YTickLabels in the
%                                   subplot of the lowest  row (defailt).
%                        'All'    : plot YTickLabels in all subplots.
%                        'None'   : don't plot YTickLabels in subplots.
%           -  'FontS'  : axis font size, default is 10.
%             'XScale' : scale of x axis:
%                        'linear', default.
%                        'log'
%           -  'YScale' : scale of y axis:
%                        'linear', default.
%                        'log'
%
% @Returns:  
%
%       hAxes       Numeric         Handle of....
%
%
% @Syntax:
%
%       [hAxes] = fig_subplot([M],[N], [varargin])
%
% @Example:    
%
%       figure();
%       fig_subplot(2,2,'Gap',[0 0],'XTickL','Margin','YTickL','Margin')
%      	%
%      	fig_subplot(1)
%    	plot(randn(20,2),'o');
%      	%
%     	fig_subplot(2)
%       plot(randn(20,2),'o');
%
% @See also:        EXAMPLES.m
% 
% @Author:          Pete R Jones <petejonze@gmail.com>
%
% @Version History: 1.0.0	11/10/11	First Build            	[PJ]
%                   1.0.1	08/10/12	Tweaks & comments       [PJ]
%
% @Todo:            persistent hAxess makes it impossible to reedit a prior
%                   figure...

persistent hAxess

%-------------------------------------------------------------------------
% establish defaults
MinDef      = [0.10 0.10];
MaxDef      = [0.95 0.95];
GapDef      = [0.01 0.01];
XTickLDef   = 'Margin';  
YTickLDef   = 'Margin';  
FontSDef    = 10;
XScaleDef   = 'linear';
YScaleDef   = 'linear';

% set default parameters
Min    = MinDef;
Max    = MaxDef;
Gap    = GapDef;
XTickL = XTickLDef;
YTickL = YTickLDef;
FontS  = FontSDef;
XScale = XScaleDef;
YScale = YScaleDef;



% tmp hack for Bias paper
if nargin>0 && strcmpi(M,'reset')
    hAxess = get(gcf,'Children');
    return
end



MoveFoc = 0;
if (nargin==0),
    hAxes = hAxess; % return all handles
    return;
elseif (nargin==1),
   %--- move focus to subplot # ---
   MoveFoc = 1;
elseif (nargin==2),
   %--- move focus to subplot # ---
   M = [M N];
   MoveFoc = 1;
elseif (nargin>2),
   Narg = length(varargin);
   if (0.5*Narg==floor(0.5.*Narg)),
      for I=1:2:Narg-1,
         switch varargin{I},
          case 'Min'
 	     Min = varargin{I+1};
          case 'Max'
 	     Max = varargin{I+1};
          case 'Gap'
 	     Gap = varargin{I+1};
          case 'XTickL'
 	     XTickL = varargin{I+1};
          case 'YTickL'
 	     YTickL = varargin{I+1};
          case 'FontS'
 	     FontS = varargin{I+1};
          case 'XScale'
 	     XScale = varargin{I+1};
          case 'YScale'
 	     YScale = varargin{I+1};
          otherwise
	     error('Unknown keyword');
         end
      end
   else
      error('Optional arguments should given as keyword, value');
   end
else
   error('Illegal number of input arguments');
end

switch MoveFoc        
 case 1
     if isempty(hAxess)
         error('hAxess not initialised?!?');
     end
    
    %--- move focus to subplot # ---
    if (length(M)==1),
        [nRows, nCols] = size(hAxess); %#ok
        % proceeds down each column
        Row = ceil(M/nCols);
        Col = mod((M-1),nCols)+1;
    elseif (length(M)==2),
       Row = M(1);
       Col = M(2);
    else
       error('Unknown option, undefined subplot index');
    end
    set(gcf,'CurrentAxes',hAxess(Row,Col));
 case 0
    %--- open subplots ---

    Xmin   = Min(1);
    Ymin   = Min(2);
    Xmax   = Max(1);
    Ymax   = Max(2);
    Xgap   = Gap(1);
    Ygap   = Gap(2);
    
    
    Xsize  = (Xmax - Xmin)./N;
    Ysize  = (Ymax - Ymin)./M;
    
    Xbox   = Xsize - Xgap;
    Ybox   = Ysize - Ygap;

    hAxess = nan(M, N);
 
    clf;
    
    for Row = 1:M
        for Col = 1:N

            Xstart = Xmin + Xsize.*(Col - 1);
            Ystart = Ymax - Ysize.*Row;
            
            hAxess(Row,Col) = axes('position',[Xstart,Ystart,Xbox,Ybox]);
            set(gca,'FontSize',FontS);
            box on;
            hold on;

            switch lower(XTickL)
                case 'margin'
                    if (Row~=M),
                        %--- erase XTickLabel ---
                        set(gca,'XTickLabel',[]);
                    end
                case 'all'
                    % do nothing
                case 'none'
                    set(gca,'XTickLabel',[]);
                otherwise
                    error('Unknown XTickL option');
            end
            
            switch lower(YTickL)
                case 'margin'
                    if (Col~=1),
                        %--- erase YTickLabel ---
                        set(gca,'YTickLabel',[]);
                    end
                case 'all'
                    % do nothing
                case 'none'
                    set(gca,'YTickLabel',[]);
                otherwise
                    error('Unknown XTickL option');
            end
            
            switch XScale
                case 'linear'
                    set(gca,'XScale','linear');
                case 'log'
                    set(gca,'XScale','log');
                otherwise
                    error('Unknown XScale option');
            end
            
            switch YScale
                case 'linear'
                    set(gca,'YScale','linear');
                case 'log'
                    set(gca,'YScale','log');
                otherwise
                    error('Unknown YScale option');
            end

        end
    end

 otherwise
    error('Unknown MoveFoc option');
end

hAxes = gca();