%% User parameters

% define colours
% top row defines colours when > 0, bottom row when < 0. Each column is a
% different bar number within each group.
colours =   {1   2   3   4;
             1.1 2.1 3.1 6.1}
         
% DO NOT EDIT BELOW THIS POINT         
%% Plot data
close all
Y = [-1 2 -3 4;
    5 -6 7 8;
    9 10 -11 -12];
hBar = bar(Y);

%% Colour bars  
% init
nGroups = size(Y,1);
nBars = size(Y,2);
for bid = 1:nBars
    % get the bid'th bar in each group (e.g. the leftmost column in each
    % group)
    ch = get(hBar(bid),'children');
    % calc colours
    colour = nan(1,3);
    for gid = 1:nGroups
        wasCorrect = Y(gid,bid) > 0;
        colour(gid) = colours{wasCorrect+1, bid};
    end
    % set colours
    cd=repmat(colour,5,1);
    cd=[cd(:);nan];
    set(ch,'facevertexcdata',cd);
end