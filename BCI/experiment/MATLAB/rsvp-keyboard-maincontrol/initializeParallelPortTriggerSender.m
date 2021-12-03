%% function initializeParallelPortTriggerSender(parallelPortIOListinhex)
%   initializes parallel port trigger by first loading parallel port library
%   'inpout32' and sends a test trigger.  
%       Input:
%       parallelPortIOListinhex - list of all possible port numbers that is
%       defined in RSVPKeyboardParameters script
% 
%   See also sendTrigger
%%
function initializeParallelPortTriggerSender(parallelPortIOListinhex)
global parallelPortIOListdec
    
loadlibrary('inpout32','inpout32.h');

parallelPortIOListdec=hex2dec(parallelPortIOListinhex);
sendTrigger(0);