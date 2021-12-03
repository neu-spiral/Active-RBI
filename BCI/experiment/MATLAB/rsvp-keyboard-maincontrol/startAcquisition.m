%% startAcquisition
% Start amplifiers
%   in case gUSBAmp : call startAmps to starts data acquisition
%                     return success : 0/1 0 represents fail , 1 presents
%                     success
%   in case noAmp   : record starting time
%%
switch RSVPKeyboardParams.DAQType
    case 'gUSBAmp'
        if showPresentation
            [success]=startAmps(amplifierStruct,recordingFilename,'Presentation');
        else
            [success]=startAmps(amplifierStruct,recordingFilename_additional);
        end
        
    case 'noAmp'
        amplifierStruct.lastAcquisitionTimeStamp=handleVariable;
        amplifierStruct.lastAcquisitionTimeStamp.data=tic;
end