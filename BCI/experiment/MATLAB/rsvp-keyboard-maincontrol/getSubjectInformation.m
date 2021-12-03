%% subjectID = getSubjectInformation
% Get subject information: subjectID    
%
%  Reads the list of the subjects from _subjectList.txt_ and queries the experimenter to select the
%  index corresponding to a subject ID or enter a name for the subject.
%       subjectList.txt - a txt file which contains information of subject
%       
%   Output:
%       subjectID - ID of the subject of the session

function subjectID=getSubjectInformation(appendFlag,Str2Append)

subjectListFilename=which('subjectList.txt');


subjectListfid=fopen(subjectListFilename,'r');

subjectList=textscan(subjectListfid,'%s');

for subjectIndex=1:length(subjectList{1})
    fprintf('[%d]: %s\n',subjectIndex,subjectList{1}{subjectIndex});
end

fclose(subjectListfid);

subjectInput=input('Please select the number of the subject or enter an ID for a new subject:','s');

subjectIndex=str2double(subjectInput);
if(isnan(subjectIndex))
    subjectID=subjectInput;
    
    if(~any(strcmpi(subjectID,subjectList{1})))
        if appendFlag
          subjectID=[subjectID,Str2Append]; 
            
        end
    subjectListfid=fopen(subjectListFilename,'a');
    fprintf(subjectListfid,'%s\n',subjectID);
    fclose(subjectListfid);
    end
else
    subjectID=subjectList{1}{subjectIndex};
end


