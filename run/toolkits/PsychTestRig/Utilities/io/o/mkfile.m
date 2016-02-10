function fileName = mkfile(fileName)
%MKFILE create a file.
% needs error checking!
%e.g. if file doesn't exist then fopen will silently fail and then fclose
%will throw "Invalid file identifier.  Use fopen to generate a valid file
%identifier."
    fid = fopen(fileName,'w+');
    fclose(fid);
end


