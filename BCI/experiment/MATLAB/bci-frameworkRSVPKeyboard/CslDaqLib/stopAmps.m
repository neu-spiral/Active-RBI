%% [success]=stopAmps(amplifierStruct)
%stopAmps(amplifierStruct) stops the amplifiers connected to the system. The
%   amplifiers are stopped by stopping the analog input objects coresponding to
%   all amplifiers. The index of the amplifier list is in an increasing order 
%   starting from the master amplifier. The master amplifier is stopped last.
%    
%   [success]=stopAmps(amplifierStruct) stops the amplifiers connected to the system. 
%      
%       The inputs of the function
%           amplifierStruct - A structure that contains the amplifier
%           information. The following members of this structure 
%           is used in the function.  
%
%                   * amplifierStruct.numberOfAmplifiers - An integer
%                   demonstrating the number of amplifiers connected to the
%                   system.
%                   
%                   * amplifierStruct.ai() - A vector of analog input
%                   objects corresponding to the amplifiers connected to
%                   the system.
%
%       The outputs of the function
%            success (0/1) - A flag to show the success of the procedure
%           
%           
%
%%




function [success]=stopAmps(amplifierStruct)

try
    %To get the last chunk of data, since data is sent from amplifier as chunks.
    pause(0.5); 
    
    %% Stopping the amplifiers

    for ampIndex = amplifierStruct.numberOfAmplifiers:-1:1
        stop(amplifierStruct.ai(ampIndex));
    end
    disp('Recording stopped')
    success = 1;
    
catch ME
    logError(ME);
    success=0;
end