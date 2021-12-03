%% setPathandFilenames
%Creates the session folder and filenames and adds the different folders
% to the matlab path.
%
%   setPathandFilenames, adds different code folders to the matlab path and
%   creates the session folder using the time-stamp and also the "subjectID",
%   "projectID", "sessionID" inside the "Data" folder.
%
%   All the filenames start with the same name as the folder and depending
%   on their type they will have different suffixes.
%
%   Example:
%       foldername: "projectID_subjectID_sessionID_2012-07-12-T-15-45"
%       error filename: 
%           "projectID_subjectID_sessionID_2012-07-12-T-15-45-errorLog.txt"
%       parameters filename: 
%           "projectID_subjectID_sessionID_2012-07-12-T-15-45-parameters"
%       amplifier information filename: 
%           "projectID_subjectID_sessionID_2012-07-12-T-15-45-ampInfo.txt"
%
%%
global BCIframeworkDir
global errorFilename
global ampInfoFilename
global recordingFilename
global recordingFilename_additional
global parameterFilename

global channelParametersFilename


dataFolderName=[BCIframeworkDir '\Data'];

% file containing the information about the Hardware channel locations,
% Electrode locations and channel Types.
channelParametersFilename='channels.csv';

% creates the Data folder if it doesn't exist.
if exist('Data','dir') ~= 7
    mkdir(dataFolderName);
end

recordingFolder=[projectID '_' subjectID '_' sessionName '_' datestr(now,'yyyy-mm-dd-T-HH-MM')];
success=mkdir([dataFolderName '\' recordingFolder]);

mkdir([dataFolderName '\' recordingFolder '\Additional']);
errorFilename=[dataFolderName '\' recordingFolder '\' recordingFolder '-errorLog.txt'];
recordingFilename=[dataFolderName '\' recordingFolder '\' recordingFolder];
recordingFilename_additional = [dataFolderName '\' recordingFolder '\Additional\' recordingFolder];

parameterFilename=[dataFolderName '\' recordingFolder '\' recordingFolder '-parameters'];

ampInfoFilename = [dataFolderName '\' recordingFolder '\' recordingFolder '-ampInfo.txt'];

