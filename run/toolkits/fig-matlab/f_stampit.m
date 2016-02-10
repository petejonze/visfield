function [hFileTxt,hDateTxt] = f_stampit()
%F_STAMPIT Stamp the current figure with the time and source file.
%
%   Info placed at the bottom of the figure. Source files cannot be
%   determined when run in cell mode. Adapted from stampit.m, by Tim Burke
%   (01/2002)
%
%
% @Requires:        fig [package]
%                   Matlab v2008 onwards
%   
% @Input Parameters:
%
%    	<none>
%
% @Returns:  
%
%    	hFileTxt	Numeric     Handle of filename text
%
%    	hDateTxt 	Numeric     Handle of date text
%
%
% @Syntax:
%
%       [hFileTxt,hDateTxt] = f_stampit()
%
% @Example:    
%
%       figure(); plot(randn(20),'o');
%       f_stampit();
%
% @See also:        fig_save.m
% 
% @Author:          Pete R Jones <petejonze@gmail.com>
%
% @Version History: 1.0.0	11/10/11	First Build            	[PJ]
%                   1.0.1	08/10/12	Tweaks & comments       [PJ]
%
% @Todo:            <none>

% init variables
fontSize = 7;
 
% obtain location of calling m-file
st = dbstack;
if max(size(st))==1 || strcmpi(st(end).name,'fig_figFormat')
    warning('Stampit:inCellMode','Stampit must be called at the end of an m-file (and not in cell mode)');
    fn = '<<Cell Mode>>';
else
    fn = st(end).name;
    full_fn = which(fn);
    %
    if length(full_fn) > 40; % if full filename path too long, abbreviate (max char = 40)
        fn = ['..' full_fn((end-37):end)];
    end
end

% apply stamp
cur_ax = get(gcf,'CurrentAxes'); % gets current axis handle for given figure  
    % Make a hidden axis the size of the entire figure window
    axes('Position',[0 0 1 1], 'Visible','off','Units','normalized','Tag','fig_stampit');

    % add text
    hFileTxt = text(0.13,0.01,fn,'Interpreter','none','FontSize',fontSize);
    hDateTxt = text(.905,0.01,date,'Interpreter','none','FontSize',fontSize,'HorizontalAlignment','Right');  
set(gcf,'CurrentAxes',cur_ax); % Sets current axis back to its previous state
  
chld = get(gcf,'Children');                                 % These lines place the hidden "Stampit" axis
if length(chld)>1                                       	% to the bottom of the figure's Children handle list
    set(gcf,'Children',[chld(2:length(chld)); chld(1)])     % This alieveates problems with zoom and other functions
end                                                         % after stampit has been called. (TAB 11/13/01)