function isAnActiveFile = isCurrentDataFile()

    %----------------------------------------------------------------------
    global OUTPUT_FILE_ID;
    %---------------------------------------------------------------------- 
    
    isAnActiveFile = ~isempty(OUTPUT_FILE_ID);

end