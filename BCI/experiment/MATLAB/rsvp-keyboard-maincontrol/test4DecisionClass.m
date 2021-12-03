

addpath(genpath('.'));
load('testCalibrationFile');
RSVPKeyboardParameters;

imageStructs=xls2Structs('imageList.xls');  %OK


dos(['btlmserver\btlmserv.exe btlmserver\models\' RSVPKeyboardParams.languageModel ' &']);
           languageModelClient=btlm;
           languageModelClient.initRemote;
           languageModelClient.alloc;
           languageModelWrapperObject=languageModelWrapper(languageModelClient,imageStructs,RSVPKeyboardParams.languageModelWrapper);
           
           
           testObj=DecisionClass(languageModelWrapperObject,scoreStruct,RSVPKeyboardParams.Typing);
           
           
           
           for(ii=1:4*10)
           results.scores=[];
           results.trialLabels=[];
           results.decideNextFlag=true;
           results.completedSequenceCount=1;
           [tempDecision,epochEndedFlag]=makeDecision(testObj,results);
           end