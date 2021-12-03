%% quitPresentation
% Prepares to exit the presentation. Frees variables and deallocates pointers.
%
%%

% Sets the boolean value that is used to determine if the presentation is to continue to false.
presentationContinueFlag = 0;

% Checks to see if the presentationInfo.lockKeyboard boolean variable is true
if presentationInfo.lockKeyboard
    
    % Tells the Psychtoolbox function 'GetChar' to stop polling for keyboard input.
    ListenChar(0);
    
end

% Executes the 'sca' command, which closes all open windows.
sca;

% Prevents the Psychtoolbox HID protocols from obtaining further keyboard data.
PsychHID('KbQueueRelease');
PsychHID('KbQueueStop');

% Deallocates the 32 bit keyboard library.
unloadlibrary('inpout32');

% Checks to see if the standaloneFlag boolean variable is false.
if ~standaloneFlag
    
    % Sets the thisPacket.header variable to the default stop value, as specified by BCIPacketStruct.HDR.STOP.
    thisPacket.header = BCIPacketStruct.HDR.STOP;
    
    % Clears the thisPacket.data variable.
    thisPacket.data = [];
    
    % Sends the thisPacket struct as a packet to the main BCI control module.
    success = sendBCIPacket(CommObjectStruct.presentation2mainCommObject,BCIPacketStruct,thisPacket);
    
    % Terminates the program.
    quit;
    
end