% fig
% Version 0.3 24-Mar-2012
%
%   The fig toolbox is a collection of Matlab functions for producing
%   publication quality 2D figures in Matlab. It was intended to be modular
%   and easy to use, and allows users to quickly produce well organised
%   code that is easy to understand and edit. I have used it to produce
%   figures for my doctoral thesis, and journal manuscripts, and continue
%   to update the code on an ad-hoc basis.
%
%   It was originally conceived as a way of drawing together a number of
%   existing functions in a standardised manner. As such, this code 
%   builds upon much work from other authors. I have attempted to 
%   give accreditations where appropriate, but please let me know if any
%   author tags are missing.
%
%   Features of note inlucde:
%       - A standardised framework that can easily be edited/redeployed
%       - Many boring/repetitive processes are automated
%       - All text is handled in LaTeX, allowing for mathematical notation
%       - Greater control, e.g., of subplots, legends, tickmarks, etc.
%       - Subplots can easily be made to share axes
%       - Easy export to publication-quality files
%       - A miscellany of useful/time-saving functions
%       - Fonts are embedded in figures for easy submission to journals
%
%   The basic process for plotting is as follows:
%       (0) Initialise      | fig_init
%       (1) Make figure     | fig_make
%       (2) Plot data       | n/a [this bit is up to you!]
%       (3) Format axes     | fig_axesFormat
%       (4) Add legend      | fig_legend
%       (5) Format figure   | fig_figFormat
%       (6) Export figure   | fig_save
%   see EXAMPLES.m for a more detailed overview.
%
%
%   This code is free for any use, so long as author information remains
%   with code.
%
% @Author:          Pete R Jones <petejonze@gmail.com>
%
% @Version History: 0.1     11/10/11	Basic version           [PJ]
%                   0.2     16/02/12	Further developments	[PJ]
%                   0.3     07/10/12	Post-thesis version     [PJ]
%                           23/01/13	Little tweaks           [PJ]
%
% @Content:
%   EXAMPLES        - Demo code
%   f_legendTitle   - Add title to legend
%   f_stampit       - Stamp draft figures with identifying info
%   f_tickFormat    - Format tick marks. Replace labels with LaTeX versions
%   fig_axesFormat  - X- and Y-Axis tick marks/labels/titles/etc
%   fig_figFormat   - Super titles and final tweaks
%   fig_init        - Helper for validation and output dir creation
%   fig_legend      - Advanced wrapper for legend.m, affording more control
%   fig_make        - Creates and initialises the basic plot lattice
%   fig_nudge       - For tweaking the placement of graphic objects
%   fig_save        - Easy export to all professional image formats
%   fig_subplot     - Control individual panels in a lattice
%
%   n.b., functions begining 'f_' *can* be called directly, but are
%   generally only used internally (i.e., from within the main 'fig_'
%   functions). A number of additional helper functions can also be found
%   inside ./utilities. Various third-party scripts can be found in
%   ./3rdParty.
%
% @Todo:            - 3D plots
%                   - Debugging and cleanups
%
%
% enjoy!
% pete 08/10/2012