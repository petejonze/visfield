%getFilesMatching already taken

function files=getFiles(thepath, excludeHidden)

    if nargin < 1 || isempty(thepath)
        thepath = './';
    end
    if nargin < 1 || isempty(excludeHidden)
        excludeHidden = false;
    end
    
    files = dir(thepath);

    files = files(~[files.isdir]);
    
    if (excludeHidden)
        files(strncmp({files.name}, '.', 1)) = []; % new, no exceptions
    end
    
    files={files.name}; %return only names
end