function folders=getDirs(thepath, excludeHidden)
% From: Jan Simon
% @ http://www.mathworks.it/matlabcentral/newsreader/view_thread/258220

    folders = dir(thepath);
    folders = folders([folders.isdir]);
    
    if (excludeHidden)
        folders(strncmp({folders.name}, '.', 1)) = []; % new, no exceptions
    end
    
    folders={folders.name}; %return only names
end