
%[success,impedances]=getImpedance(amplifierStruct);

[success]=startAmps(amplifierStruct,recordingFilename);

 [success,rawData,triggerData]=getAmpsData(amplifierStruct);

% escFlag=0;
% figure
% while ~escFlag
%     pause(1)
%     [success,rawData,triggerData]=getAmpsData(amplifierStruct);
%     plot(rawData)
%     [keyisdown,secs,keycode] = KbCheck;
%     if keycode(27)
%         escFlag = 1;
%     end
% end

stopAmps(amplifierStruct);