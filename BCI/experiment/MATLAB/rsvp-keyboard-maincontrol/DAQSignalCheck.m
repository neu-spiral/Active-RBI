%% DAQSignalCheck
%Switch between two Data Acquire type case, gUSBAmp and no Amp
%   in gUSBAmp case
%   call parallelPortTriggerTest to tests the triggers received by the amplifiers
%   call SignalMonitorGui to check impedence and display signals
%   in noAmp case
%   do nothing
%   Also seen parallelPortTriggerTest
%%
switch RSVPKeyboardParams.DAQType
    case 'gUSBAmp'
        parallelPortTriggerTest(amplifierStruct,recordingFilename,fs,RSVPKeyboardParams.parallelPortIOList);
        continueMainBCIFlag=true;
        
    case 'noAmp'
        continueMainBCIFlag=true;
end