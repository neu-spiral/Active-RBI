

addpath(genpath('.'));
load('testCalibrationFile');
RSVPKeyboardParameters;

imageStructs=xls2Structs('imageList.xls');  %OK


%RSVPKeyboardTaskObject=MasteryTask(imageStructs,RSVPKeyboardParams,scoreStruct);

RSVPKeyboardTaskObject=feval('MasteryTask',imageStructs,RSVPKeyboardParams,scoreStruct);

for(ii=1:400)
    if(RSVPKeyboardTaskObject.currentInfo.taskEndedFlag)
        break;
    end
    results.scores=[];
    results.trialLabels=[];
    results.decideNextFlag=true;
    results.completedSequenceCount=1;
    results.duration=5;
    RSVPKeyboardTaskObject.updateDecisionState(results);
    
end