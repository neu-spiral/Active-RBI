%% saveInformation
% saveInformation routine saves the session information to the recording
% folder. Parameters folder is also saved as a compressed file.

if sessionID == 6 % RecursiveCalibration
    % Saving RecursiveCalibration latest state.
    RSVPKeyboardTaskObject.saveTaskHistory([dataFolderName '\' recordingFolder],...
        processingStruct.featureExtraction.ERP.Flow,scoreStruct,calibrationDataStruct,calibrationArtifactParameters);
else
    RSVPKeyboardTaskObject.saveTaskHistory([dataFolderName '\' recordingFolder]);
end
rejectSequenceInfo=processingStruct.featureExtraction.ERP.rejectSequenceInfo;
save([dataFolderName '\' recordingFolder '\taskHistory.mat'],'rejectSequenceInfo','-append');
zip([dataFolderName '\' recordingFolder '\Parameters.zip'],'*','Parameters');
    