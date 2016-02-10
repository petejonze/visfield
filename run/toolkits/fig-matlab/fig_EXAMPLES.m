%EXAMPLES demos showing how to use the FIG plotting package.
%
%     (1a) Very basic example I: Bar chart
%     (1b) Very basic example II: Scatter plot
%     (2)  Basic example
%     (3)  Lattice plot
%     (4)  Multi-panel plot
%     (5)  Multi-panel plot with independent axes
%     (6)  Advanced labeling
%     (E1) Experimental: data breaks
%     (E2) Experimental: correlation matrix
%     (E3) Experimental: pop-out
%     (E4)  Multiple (secondary) axes
%     (E5) =)
%
%   Remember to add the /fig directory (including subdirectories) to your
%   path before attempting to use this toolbox.
%
% @Author:          Pete R Jones <petejonze@gmail.com>
%
% @Version History: 1.0.0	11/10/11	First Build            	[PJ]
%                   1.0.1	08/10/12	Heavily updated         [PJ]
%
% @Todo:            finish fig_addSecondAxis (allow for fig axis labels,
%                   and expand figure borders to fit)
%
%                   see adaptiveSims_v3 for how to resize panels


%% INIT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    close all
    clear all
    clc
    
    [~,d] = fileparts(pwd());
    if ~strcmpi(d, 'fig-matlab')
        fn = fileparts(which(mfilename));
        if isempty(fn)
            error('fig-matlab.EXAMPLES should be run as a Script (F5)');
        else
            warning('fig-matlab.EXAMPLES should be run from its home directory.\nRunning: cd %s', fileparts(which(mfilename)));
            cd(fileparts(which(mfilename)));
        end
    end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (1a) Very basic example I: Bar chart
%%%     1 panel, default parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % initialise output options
    [EXPORT_DIR, EXPORT_FORMAT] = fig_init();
    
    % open a new figure window
    hFig = fig_make(); 

    % plot data
    hDat = bar([1 2],[4 7.5]);

    % format the axes
    fig_axesFormat();
    
    % add legend
    fig_legend([],hDat,'data',[],'NorthWest');
    
    % format the figure
    fig_figFormat(hFig,'X','Y');
    
    % save
    fig_save(hFig, '1a_barChart', EXPORT_DIR, EXPORT_FORMAT);
    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (1b) Very basic example II: Scatter plot
%%%     1 panel, default parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % initialise output options
    [EXPORT_DIR, EXPORT_FORMAT] = fig_init();
    
    % open a new figure window
    hFig = fig_make(); 

    % plot data
    x = rand(20,2);
    y = .9 + x*2.*rand(20,2)+repmat([0 .5],20,1);
    hDat = plot(x,y,'o');

    % format the axes
    fig_axesFormat();
    
    % add legend
    fig_legend(gca,hDat,{'women','men'});
    
    % format the figure
    fig_figFormat(hFig,'X','Y');

    % save
    fig_save(hFig, '1b_sexAndHeight', EXPORT_DIR, EXPORT_FORMAT);

    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (2) Basic example
%%%     1 panel, user-specified parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % initialise output options
    EXPORT_DIR      = sprintf('./Figs/%s',datestr(now,1));
    EXPORT_FORMAT   = {'pdf','png','eps'};
    pkgVer          = 0.3;
    [EXPORT_DIR, EXPORT_FORMAT] = fig_init(pkgVer,EXPORT_FORMAT,EXPORT_DIR);

    % open a new figure window
    figDim      = 7.5;
    nPlots      = 1;
    isTight     = true;
    isSquare    = true;
    styleFlag   = [];
    axesLims    = [];
    hFig        = fig_make(figDim, nPlots, isTight, isSquare, styleFlag, axesLims);

    % plot data
    x       = rand(20,2);
    y       = .9 + x*2.*rand(20,2)+repmat([0 .5],20,1);
    hDat    = plot(x,y,'o');

    % format the axes
    xTick       = 0:0.25:1;
    xTickLabels = {'0','.25','.5','.75','1'};
    yTick       = 0:1:3;
    yTickLabels = [];
    xAxisTitle  = [];
    yAxisTitle  = [];
    xlims       = [-0.2 1.2];
    ylims       = [-0.2 4];
    fontSize    = 11;
    formatData  = false;
    xMinorTick  = 0:.1:1;
    yMinorTick  = 0:.1:1;
    [hXTickLbl, hYTickLbl, c_axes] = fig_axesFormat(gca, xTick,xTickLabels, yTick,yTickLabels, xAxisTitle,yAxisTitle, xlims,ylims, fontSize, formatData, xMinorTick,yMinorTick);

    % add annotation
    textLoc(sprintf('p = %1.2f',0.37),'SouthWest');

    % add legend
    hAxes       = 1;
    legendNames = {'women','men'};
    legendTitle = [];
    loc         = 'NorthWest';
    fontSize    = 12;
    markerSize  = [];
    hScale      = .75;
    vScale      = .75;
    hLeg        = fig_legend(hAxes,hDat,legendNames,legendTitle, loc, fontSize, markerSize, hScale, vScale);
    fig_nudge(hLeg, -0.07, 0);

    % format the figure
    xTitle      = '\textbf{Maturation}, $\%$';
    yTitle      = '\textbf{Height}, $m$';
    mainTitle   = 'Sex \& Height';
    fontSize    = 16;
    fig_figFormat(hFig, xTitle,yTitle,mainTitle, fontSize);

    % save
    fig_save(hFig, '2_sexAndHeight', EXPORT_DIR, EXPORT_FORMAT);


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (3) Lattice plot
%%%     3 x 4 matrix of panels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % initialise output options
    EXPORT_FORMAT = {'pdf','png','eps'};
    EXPORT_DIR = sprintf('./Figs/%s',datestr(now,1));
    pkgVer = 0.3;
    [EXPORT_DIR,EXPORT_FORMAT] = fig_init(pkgVer,EXPORT_FORMAT,EXPORT_DIR);

    % open a new figure window.
    figDim = [12 20];
    nPlots = [3 4];
    isTight = true;
    isSquare = true;
    styleFlag = [];
    axesLims = [];
    hFig = fig_make(figDim, nPlots, isTight, isSquare, styleFlag, axesLims);

    % plot data
    for i = 1:prod(nPlots)-1
        fig_subplot(i);
        hDat = plot(rand(20,1)*80,rand(20,1)*10,'ro',rand(20,1)*80,rand(20,1)*10,'o');
    end

    % format all the axes
    xTick = 0:20:80;
    xTickLabels = [];
    yTick = 0:5:10;
    yTickLabels = [];
    xTitle = [];
    yTitle = [];
    xlims = [-15 95];
    ylims = [-2 12];
    fig_axesFormat(NaN, xTick,xTickLabels, yTick,yTickLabels, xTitle,yTitle, xlims,ylims);

    % add legend
    hAxes = 12;
    legendNames = {'Men','Women'};
    legendTitle = [];
    loc = 'West';
    fontSize = 12;
    markerSize = [];
    hScale = .75;
    vScale = .8;
    hLeg = fig_legend(hAxes,hDat,legendNames,legendTitle, loc, fontSize, markerSize, hScale, vScale);
    fig_nudge(hLeg, -0.01, 0);

    % format the figure
    xTitle = 'Age';
    yTitle = 'Score';
    mainTitle = [];
    fontSize = 16;
    fig_figFormat(hFig, xTitle,yTitle,mainTitle, fontSize);

    % save
	fig_save(hFig, '3_myVeryNiceLattice', EXPORT_DIR, EXPORT_FORMAT);


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (4) Multi-panel plot
%%%     Different scaling and titles on each panel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % initialise output options
    [EXPORT_DIR,EXPORT_FORMAT] = fig_init(0.3);

    % open a new figure window.
    figDim = [16 10];
    nPlots = [3 1];
    isTight = true;
    isSquare = true;
    styleFlag = [];
    axesLims = [];
    hFig = fig_make(figDim, nPlots, isTight, isSquare, styleFlag, axesLims);

    % plot data
    % START -----------------------
        % common
        xTick = 1:5;
        xTickLabels = [];
        xTitle = [];
        xlims = [0 6];
        hDat = nan(2,1);
        
        % (1)
        fig_subplot(1);
        hold on
            hDat(1) = errorbar1(randn(20,5)*2+repmat(1:5,20,1),'b-');
            hDat(2) = errorbar1(randn(20,5)*2+repmat(1:5,20,1),'r--');
        hold off
        %
        yTick = 0:2:6;
        yTickLabels = [];
        yTitle = 'Test 1';
        ylims = [-1 7];
        fig_axesFormat(gca, xTick,xTickLabels, yTick,yTickLabels, xTitle,yTitle, xlims,ylims);

        % (2)
        fig_subplot(2);
        hold on
            errorbar1(randn(20,5)*2+repmat(5:-1:1,20,1)./2,'b-');
            errorbar1(randn(20,5)*2+repmat(5:-1:1,20,1)./2,'r--');
        hold off
        %
        yTick = 0:1:3;
        yTickLabels = [];
        yTitle = 'Test 2\n(Verbal)';
        ylims = [-0.5 3.5];
        fig_axesFormat(gca, xTick,xTickLabels, yTick,yTickLabels, xTitle,yTitle, xlims,ylims);
        
        % (3)
        fig_subplot(3);
        hold on
            errorbar1(randn(20,5)*20+repmat(30,20,5),'b-');
            errorbar1(randn(20,5)*20+repmat(30,20,5),'r--');
        hold off
        %
        yTick = 0:20:60;
        yTickLabels = [];
        yTitle = 'Test 2\n(Non-verbal)';
        ylims = [-10 70];
        fig_axesFormat(gca, xTick,xTickLabels, yTick,yTickLabels, xTitle,yTitle, xlims,ylims);
    % END -----------------------
    
    % add legend
    hAxes = 1;
    legendNames = {'Men','Women'};
    legendTitle = [];
    loc = 'SouthEast';
    fontSize = [];
    markerSize = [];
    hScale = .5;
    vScale = .8;
    hLeg = fig_legend(hAxes,hDat,legendNames,legendTitle, loc, fontSize, markerSize, hScale, vScale);

    % format the figure
    xTitle = '\textbf{Session}';
    yTitle = '\textbf{Score}';
    mainTitle = [];
    fontSize = 16;
    alignYLbls = true;
    fig_figFormat(hFig, xTitle,yTitle,mainTitle, fontSize, alignYLbls);

    % save
	fig_save(hFig, '4_multiPanel_tight', EXPORT_DIR, EXPORT_FORMAT);

    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (5) Multi-panel plot with independent axes
%%%     non-shared axes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % initialise output options
    [EXPORT_DIR,EXPORT_FORMAT] = fig_init(0.3);

    % open a new figure window.
    figDim = [7 15];
    nPlots = [1 2];
    isTight = [.15 0];
    isSquare = false;
    styleFlag = [];
    axesLims = [];
    hFig = fig_make(figDim, nPlots, isTight, isSquare, styleFlag, axesLims);

    % plot data
    % START -----------------------
        % (1)
        fig_subplot(1);
        plot(rand(20)*10,'o');
        %
        xTick = 0:5:10;
        xTickLabels = [];
        yTick = 0:5:10;
        yTickLabels = [];
        xTitle = 'Age';
        yTitle = 'IQ';
        xlims = [0 11];
        ylims = [0 11];
        fig_axesFormat(gca, xTick,xTickLabels, yTick,yTickLabels, xTitle,yTitle, xlims,ylims);

        % (2)
        fig_subplot(2);
        errorbar1(rand(20,5),'-');
        %
        xTick = 0:1:5;
        xTickLabels = [];
        yTick = 0:.2:1;
        yTickLabels = [];
        xTitle = 'Session';
        yTitle = 'Height';
        xlims = [0 6];
        ylims = [0 1];
        fig_axesFormat(gca, xTick,xTickLabels, yTick,yTickLabels, xTitle,yTitle, xlims,ylims);
    % END -----------------------

    % format the figure
    fig_figFormat();

    % save
	fig_save(hFig, '5_multiPanel_loose', EXPORT_DIR, EXPORT_FORMAT);
    
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (6) Advanced labeling
%%%     Different layers of titles. LaTeX commands
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % initialise output options
    [EXPORT_DIR, EXPORT_FORMAT] = fig_init(0.3);
    
    % open a new figure window
    figDim = [10 9];
    nPlots = [2 1];
    isTight = true;
    isSquare = true;
    styleFlag = [];
    axesLims = [.4 .95];
    hFig = fig_make(figDim, nPlots, isTight, isSquare, styleFlag, axesLims); 

    % plot data
    % START -----------------------
        % common
        xTick = 0:.33:1;
        xTickLabels = {'$\frac{1}{4}$','$\frac{2}{4}$','$\pi$','$\frac{3}{4}$'};
        yTick = [.02 .05 .125 .25 .5 1];
        yTickLabels = yTick*10000;
        xTitle = [];
        xlims = [-.1 1.1];
        ylims = [.01 2];
        fontSize = [];
        formatData = [];
        xMinorTick = [];
        yMinorTick = [];
        mrTickLgth = [];
        xRotation = 0;
        yRotation = 30;

        % (1)
        fig_subplot(1);
        plot(rand(20,1),rand(20,1),'o');
        set(gca,'YScale','log');
        %
        yTitle = '$before$';
        fig_axesFormat(gca, xTick,xTickLabels, yTick,yTickLabels, xTitle,yTitle, xlims,ylims, fontSize, formatData, xMinorTick,yMinorTick,mrTickLgth, xRotation,yRotation);

        % (2)
        fig_subplot(2);
        plot(rand(20,1),rand(20,1),'o');
        set(gca,'YScale','log');
        %
        yTitle = '$after$';
        fig_axesFormat(gca, xTick,xTickLabels, yTick,yTickLabels, xTitle,yTitle, xlims,ylims, fontSize, formatData, xMinorTick,yMinorTick,mrTickLgth, xRotation,yRotation);
    % END -----------------------

    % format the figure
    xTitle = '$P_{C \langle \textrm{`} SN \textrm{''}  \rangle}$';
    yTitle = '$d^{\prime} = \sum\limits_{-\infty}^{\infty} x_{i} \cdot \Delta$';
    mainTitle = [];
    fontSize = 16;
    fig_figFormat(hFig, xTitle,yTitle,mainTitle, fontSize);

    % save
    fig_save(hFig, '6_advancedLabels', EXPORT_DIR, EXPORT_FORMAT);
   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (E1) Experimental: data breaks
%%%     Breaking an axis and skipping forwards by X
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % initialise output options
    [EXPORT_DIR, EXPORT_FORMAT] = fig_init(0.3);

    % open a new figure window.
    fig_make();

    % plot data
    plot(linspace(0,40,20),rand(20,1),'o');

    % add xAxis break
    start=10;
    stop=20;
    fig_breakXAxis(gca, start, stop);

    % format the axes
    fig_axesFormat();

    % format the figure
    fig_figFormat();

    % save
    fig_save(gcf, 'E1_dataBreaks', EXPORT_DIR, EXPORT_FORMAT);

    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (E2) Experimental: Experimental: correlation matrix
%%%     Still in development
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % initialise output options
    [EXPORT_DIR, EXPORT_FORMAT] = fig_init(0.3);
    
    X = randn(30,4);
    varNames = {'age','sex','IQ','SSE'};
    dohist= true;
    showRho = false;
    ticks = [-3 0 3];
    tickLbls = [];
    lims = [-5 5];
    hFig = fig_corrmatrix([], X, varNames, dohist, showRho, ticks, tickLbls, lims);

    % save
    fig_save(hFig, 'E2_corrmatrix', EXPORT_DIR, EXPORT_FORMAT);

    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (E3) Experimental: pop-out
%%%     Still in development
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % initialise output options
    [EXPORT_DIR, EXPORT_FORMAT] = fig_init(0.3);

    % open a new figure window.
    fig_make();

    % plot data
    x=0:0.1:100;
    y = sin(x);
    plot(x,y);
    fig_popout(0, 10, 20);

    % format the axes
    fig_axesFormat();

    % format the figure
    fig_figFormat();

    % save
    fig_save([], 'E3_popout', EXPORT_DIR, EXPORT_FORMAT);
    
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (E4) Muliple (secondary) axes
%%%     Add a second x axis and a second y axis, with separate titles and
%%%     scaling
%%%
%%%     Note that to just have a *single* axis on the right, just run
%%%     something like 'set(gca, 'YAxisLocation', 'right');', prior to
%%%     calling fig_axesFormat();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
close all


    % initialise output options
    [EXPORT_DIR, EXPORT_FORMAT] = fig_init(0.3);

    % open a new figure window
    hFig = fig_make();

    % plot data
    x = rand(20,2);
    y = .9 + x*2.*rand(20,2)+repmat([0 .5],20,1);
    hDat = plot(x,y,'o');

    % format the axes
    xTick = 0:0.25:1;
    xTickLabels = {'0','.25','.5','.75','1'};
    yTick = 0:1:3;
    yTickLabels = [];
    xAxisTitle = []; % '\textbf{Maturation}, $\%$';
    yAxisTitle = []; % '\textbf{Height}, $m$';
    xlims = [-0.2 1.2];
    ylims = [-0.2 4];
    [hXTickLbl, hYTickLbl, c_axes] = fig_axesFormat(gca, xTick,xTickLabels, yTick,yTickLabels, xAxisTitle,yAxisTitle, xlims,ylims);

    % add annotation
    textLoc(sprintf('p = %1.2f',0.37),'SouthWest');

    % add legend
    hAxes = 1;
    legendNames = {'women','men'};
    legendTitle = [];
    loc = 'NorthWest';
    hLeg = fig_legend(hAxes,hDat,legendNames,legendTitle, loc);

    % format the figure
    xTitle = '\textbf{Maturation}, $\%$';
    yTitle = '\textbf{Height}, $m$';
    
    
    fig_figFormat(hFig, xTitle,yTitle);

    % add secondary axes: note, currently comes *after* figFormat(!)
%     yTick = (round(yTick*3.28*10)/10)/3.28; % round to 1 d.p.
    yTickLabels = yTick*3.28;
    yAxisTitle = '\textbf{Height}, $ft$';
    fig_addSecondAxis(gca, 'right', yTick, yTickLabels, yAxisTitle);

    xTick = 0:.2:1;
    xTickLabels = xTick*16;
    xAxisTitle = '\textbf{Age}, $years$';
    fig_addSecondAxis(gca, 'top', xTick, xTickLabels, xAxisTitle);
    
    % save
    fig_save(gcf, 'E4_secondaryAxes', EXPORT_DIR, EXPORT_FORMAT);
    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (E5) Murray's friendship graph
%%%     Everybody present?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % initialise output options
    [EXPORT_DIR, EXPORT_FORMAT] = fig_init(0.3);

    % open a new figure window.
    fig_make([10 20],[],[],false);

    % plot data
    x = linspace(0,10,40);
    y = x.*.5 + randn(1,40);
    plot(x,y,'r-','linewidth',3);

    % draw hlines
    xlim([0 20]);
    hline([-2.5 0 1.5 3.8 9], 'k:')
    
    % format the axes
    xTick = 0:5:20;
    xTickLabels = [];
    yTick = [-2.5 0 1.5 3.8 9];
    yTickLabels = {'\textnormal{Enemies}\,', '\textnormal{Strangers}\,', '\textnormal{Colleagues}\,', '\textnormal{Workmates}\,', '\textnormal{Friends}\,'};
    xTitle = 'Time';
    yTitle = 'Friendship';
    xlims = [0 20];
    ylims = [-3 10];
    fig_axesFormat(gca, xTick,xTickLabels, yTick,yTickLabels, xTitle,yTitle, xlims,ylims);

    % format the figure
    fig_figFormat();

    % save
    fig_save([], 'E5_friendship', EXPORT_DIR, EXPORT_FORMAT);  

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (E6) Different sized panels
%%%     #####
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
        % open a new figure window
    figDim = [12 7];
    nPlots = [2 1];
    isTight = true; % [.02 .05];
    isSquare = false;
    hFig = fig_make(figDim, nPlots, isTight, isSquare, [], [], 'XTickL','Margin');
    
fig_subplot(1);    
set(gca, 'Position', get(gca,'Position').*[1 1.2 1 .5])
fig_subplot(2);
set(gca, 'Position', get(gca,'Position').*[1 1.35 1 1])
