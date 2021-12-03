%% sessionControl(mainLoopTimer,mainLoopCounter,decision,amplifierStruct)
%sessionControl(mainLoopTimer,mainLoopCounter,decision,amplifierStruct)
%controls the length mainLoopTimer, the length of the experiment.
%   
%   The inputs of the function
%   
%      mainLoopTimer - Timer object used in the main function
%
%   `  mainLoopCounter - A counter that controls the length of the
%      mainLoopTimer.
%
%      amplifierStruct - A structure that contains information about the
%      amplifiers connected to the system.
%       
%      sessionID - a varible which shows the type of the session (Calibration/Testing)
%
%
%   See also mainLoopFunction, and initializeMainLoopTimer . 
%%



%function continueMainLoopFlag=sessionControl(RSVPKeyboardTaskObject)



% if(mainLoopCounter>2000)
%     stop(mainLoopTimer);
%     delete(mainLoopTimer);
%     success=quitDAQ(amplifierStruct);
% end
    
% 
% persistent escFlag
%     if isempty(escFlag)
%         escFlag = 0;
%     end
%     
%     
% if ~escFlag
%     pause(1)
%     [keyisdown,secs,keycode] = KbCheck;
%     if keycode(27)
%         escFlag = 1;
%     end
% end
% 
% if escFlag
%     stop(mainLoopTimer);
%     disp('mainLoopTimer Stopped')
%     delete(mainLoopTimer);
%     success=quitDAQ(amplifierStruct)
%     escFlag = 0;
% end

% an example that stops the run after 100 loops of timer.
% if(mainLoopCounter==100)
%      stop(mainLoopTimer);
%      disp('mainLoopTimer Stopped')
%      delete(mainLoopTimer);
%      [success]=stopAmps(amplifierStruct);
%      [success]=closeAmps(amplifierStruct);
% end
