%% [sessionID,sessionName]=getSessionInformation
% Get session information: sessionID,sessionName
%
%   Inputs:
%       sessionIDList.txt - a txt file which contains information of  4 sessions
%
%   Outputs:
%       sessionID - index of session (defined in sessionIDList.txt)
%       sessionName - type of session ('Calibration','Spell','CopyPhrase','MasteryTask')

function [sessionID,sessionName]=getSessionInformation

sessionIDListFilename='sessionIDList.txt';

sessionIDList=zeros(6,1);

sessionIDListfid=fopen(sessionIDListFilename,'r');

sessionID=fscanf(sessionIDListfid,'%d,');
sessionIDCounter=1;

while ~isempty(sessionID)
    sessionIDList(sessionIDCounter)=sessionID;
    sessionName=fscanf(sessionIDListfid,'%s,');
    sessionNameList{sessionIDCounter}=sessionName(1:end-1);
    fprintf('[%d]: %s\n',sessionIDCounter,sessionNameList{sessionIDCounter});
    sessionID=fscanf(sessionIDListfid,'%d,');
    sessionIDCounter=sessionIDCounter+1;    
end

fclose(sessionIDListfid);

sessionIndex=str2double(input('Please select the session type:','s'));
sessionID=sessionIDList(sessionIndex);
sessionName=sessionNameList{sessionIndex};



