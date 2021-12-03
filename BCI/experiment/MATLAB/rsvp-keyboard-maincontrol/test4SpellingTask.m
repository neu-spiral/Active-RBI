

addpath(genpath('.'));
load('testCalibrationFile');
RSVPKeyboardParameters;

imageStructs=xls2Structs('imageList.xls');  %OK


RSVPKeyboardTaskObject=SpellingTask(imageStructs,RSVPKeyboardParams,scoreStruct);
           
           
for(ii=1:4000)
           results.scores=[];
           results.trialLabels=[];
           results.decideNextFlag=true;
           results.completedSequenceCount=1;
           results.duration=5;
           RSVPKeyboardTaskObject.updateDecisionState(results);
           3;
end