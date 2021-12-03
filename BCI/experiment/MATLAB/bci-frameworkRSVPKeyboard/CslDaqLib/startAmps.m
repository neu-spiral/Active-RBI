%% [success]=startAmps(amplifierStruct,dataFilename,logToDiskMode)
%Sets amplifier(s) operating mode and starts data acquisition.
%   startAmps, sets the amplifier mode to "Normal" and sets the filename
%   for storing the data on the disk.
%
%   Note: When more than one amplifier is connected the Master amplifier 
%         should be started last.
%
%   [success]=startAmps(amplifierStruct,dataFilename,mode)
%   inputs:
%       amplifierStruct - a structure which contains the amplifier(s)
%                       objects
%       
%       dataFilename - a filename which is used to record data to Disk
%
%       postfix - an additional string to append to the end of the file
%
%   returns:
%       success (0/1) - a flag to show the success of the operation
%   
%%

function [success]=startAmps(amplifierStruct,dataFilename,postfix)

    if ~exist('postfix','var')
        
        postfix = '';
        
    else
        
        if ~isempty(postfix)
            
            postfix = ['_',postfix];
            
        end
        
    end

    try
        
        %% Test if amplifier(s) are running already    
        if strcmpi(amplifierStruct.ai(1).Running,'on')
            
            warning('startAmps called while amplifier(s) are still running.');
%             [success]=stopAmps(amplifierStruct);
%             ME = (['Amplifier(s) were still running.',...
%                 ' The recording stopped and will start with the new filename(s).']);        
%             warning(ME);
%             logError(ME,0);

        else

            %% Check to see if the file exists. If it does, increment the file name by one.
            addpath(genpath('.'));
            for index = 0:999
                
                if ~exist([dataFilename,'_Amp1_Run',sprintf('%03i',index),postfix,'.daq'],'file')

                    break;
                    
                end
                
            end
            
            if index == 999
                
                if exist([dataFilename,'_Amp1_Run999.daq'],'file')
                    
                    error('Too many DAQ files created.');
                    
                end
                
            end
            
            %% Start amplifier(s)
            % Master amplifier should start at last.
            for ampIndex = amplifierStruct.numberOfAmplifiers:-1:1

                set(amplifierStruct.ai(ampIndex),'LogFileName',[dataFilename,'_Amp',num2str(ampIndex),'_Run',sprintf('%03i',index),postfix]);
                start(amplifierStruct.ai(ampIndex));

            end
            disp('Recording started');

        end
        
        success = 1;
        
    catch ME
        
        logError(ME);
        success = 0;
        
    end
    
end