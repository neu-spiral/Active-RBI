%% function sendTrigger(triggerValue)
%   sends the trigger to the list of all possible port numbers that is
%   'parallelPortIOListdec'. 
%       triggerValue - value of the trigger to be sent
% 
%   See also initializeParallelPortTriggerSender
%%
function sendTrigger(triggerValue)
    
    global parallelPortIOListdec
    
    for portIndex = 1:length(parallelPortIOListdec)
        
        calllib('inpout32','Out32',parallelPortIOListdec(portIndex),triggerValue);
        
    end

end