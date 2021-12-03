clear;
global BCIframeworkDir
BCIframeworkDir='.';
addpath(genpath(BCIframeworkDir))

subjectID='Asieh';
projectID='CSL_iconCHAT';
sessionID='Calibration';

setPathandFilenames
[success,amplifierStruct,fs,numberOfChannels] = initializeAmps;
if(success==0),return,end


    parallelPortTriggerTest(amplifierStruct,recordingFilename,fs);

checkSignalQuality
initializeSignalProcessing

[success]=startAmps(amplifierStruct,recordingFilename);

[success, mainLoopTimer] = initializeMainLoopTimer();

disp('mainLoopTimer is going to start,')
start(mainLoopTimer);
disp('mainLoopTimer started.')

% wait(mainLoopTimer);
%
% % stop(mainLoopTimer); % wait function will wait until the timer is
% % disabled. wait function does not work with timers that are going to run
% infinit times.
%
% % ############## WHAT PARAMETERS SHOULD BE SAVED AND HOW? #############