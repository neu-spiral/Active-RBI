%% [success]=closeAmps(amplifierStruct) 
%closeAmps(amplifierStruct) closes the connection with the amplifiers. The
%   conection is closed by deleting the analog input objects coresponding to
%   all amplifiers. The index of the amplifier list is in an increasing order 
%   starting from the master amplifier. The master amplifier is deleted last.
%    
%   [success]=closeAmps(amplifierStruct) closes the connection with
%   amplifiers.
%        The inputs of the function
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
%         The outputs of the function
%           success (0/1) - A flag to show the success of the procedure
%           
%          
%
%%



function [success]=closeAmps(amplifierStruct)

try   
    %% Closing the connection with amplifiers
    
    for ampIndex = amplifierStruct.numberOfAmplifiers:-1:1
        delete(amplifierStruct.ai(ampIndex));
        clear amplifierStruct.ai(ampIndex);
    end
    disp('Connection with amplifier(s) closed.')
    success = 1;
catch ME
    logError(ME);
    success=0;
end