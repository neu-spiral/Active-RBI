%% success=quitDAQ(amplifierStruct)
%  quits data aquisition and set a success flag for each
%  case of having amplifier that is 'gUSBAmp' case or 'noAmp' case that is 
%  working with artificially constructed channel signals.
% 
%   Input:
%   amplifierStruct - The structure containing amplifer objects and
%                         some extra information. (for more information see
%                         detectAmps.      
%   Output:
%   success (0/1) - a flag to show the success of the operation
%
%   See also initializeDAQ, DAQParameters, stopAmps, initializeAmps
%%
function success = quitDAQ(amplifierStruct)
    switch amplifierStruct.DAQType
        
        case 'gUSBAmp'
%             [success] = stopAmps(amplifierStruct);
            [success] = closeAmps(amplifierStruct);
            
        case 'noAmp'
            amplifierStruct.awaitingTriggers = [];
            success = true;
    end
end