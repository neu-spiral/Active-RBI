%% initializeMachineLearning
% initializeMachineLearning is a script that does the initialization of the
% machine learning steps. It initializes triggerPartitioner,
% featureExtraction and decisionMaker. For decisionMaker, an
% RSVPKeyboardTask object is created.
%
% triggerPartitioner partitions the trigger signal into sequences and trials.
%
% featureEtraction applies operations on the EEG trials to classify each
% trial, it creates features to be used in decision making.
% 
% decisionMaker uses the features extracted from featureExtraction and
% utilizes the language model to make a symbol decision. It initializes the
% RSVPKeyboardTask object which initializes the language model and
% a decisionClass object which makes the decisions after the fusion.
% RSVPKeyboardTask object also keeps the progress of the session.
%
%%

%% Loads trial symbol list.
imageStructs=xls2Structs('imageList.xls');

%% Initializes the triggerPartitioner
processingStruct.triggerPartitioner.ERP.firstUnprocessedTimeIndex=1;
processingStruct.triggerPartitioner.ERP.TARGET_TRIGGER_OFFSET= RSVPKeyboardParams.TARGET_TRIGGER_OFFSET;

processingStruct.triggerPartitioner.ERP.pauseID=imageStructs(strcmpi({imageStructs.Name},'Pause')).ID;

processingStruct.triggerPartitioner.FRP=processingStruct.triggerPartitioner.ERP;
processingStruct.triggerPartitioner.ERP.fixationID=imageStructs(strcmpi({imageStructs.Name},'Fixation')).ID;
processingStruct.triggerPartitioner.ERP.windowLengthinSamples=round(RSVPKeyboardParams.windowDuration.ERP*DAQClassObj.fs);
processingStruct.triggerPartitioner.ERP.sequenceEndID=imageStructs(strcmpi({imageStructs.Name},'ERPSequenceEnd')).ID;


processingStruct.triggerPartitioner.FRP.fixationID=imageStructs(strcmpi({imageStructs.Name},'FRPSequenceBegin')).ID;
processingStruct.triggerPartitioner.FRP.windowLengthinSamples=round(RSVPKeyboardParams.windowDuration.FRP*DAQClassObj.fs);
processingStruct.triggerPartitioner.FRP.sequenceEndID=imageStructs(strcmpi({imageStructs.Name},'FRPSequenceEnd')).ID;

%% Initialize the artificial triggers parameters
artificialsTriggersParams.ERP.triggerPartitioner.fixationID=imageStructs(strcmpi({imageStructs.Name},'Fixation')).ID;
%artificialsTriggersParams.ERP.triggerPartitioner.FRPSequenceBegin=imageStructs(strcmpi({imageStructs.Name},'FRPSequenceBegin')).ID;
artificialsTriggersParams.ERP.triggerPartitioner.sequenceEndID=imageStructs(strcmpi({imageStructs.Name},'ERPSequenceEnd')).ID;
artificialsTriggersParams.ERP.TARGET_TRIGGER_OFFSET=RSVPKeyboardParams.TARGET_TRIGGER_OFFSET;

artificialsTriggersParams.FRP.triggerPartitioner.fixationID=imageStructs(strcmpi({imageStructs.Name},'FRPSequenceBegin')).ID;
%artificialsTriggersParams.FRP.triggerPartitioner.FRPSequenceBegin=imageStructs(strcmpi({imageStructs.Name},'FRPSequenceBegin')).ID;
artificialsTriggersParams.FRP.triggerPartitioner.sequenceEndID=imageStructs(strcmpi({imageStructs.Name},'FRPSequenceEnd')).ID;
artificialsTriggersParams.FRP.TARGET_TRIGGER_OFFSET=RSVPKeyboardParams.TARGET_TRIGGER_OFFSET;
% Forms the trialsID in matrixSpeller mode.
if RSVPKeyboardParams.matrixSpellerMode
     trialsID= cell2mat({imageStructs(find(cell2mat({imageStructs.showInMatrix}))).ID});
     RSVPKeyboardParams.imageStructs=imageStructs;
end
%__________________________________________


if(strcmpi(daqStruct.DAQType,'noAmp'))
    amplifierStruct.triggerPartitionerStruct=processingStruct.triggerPartitioner;
end


%% Initializes the featureExtraction and loads the calibration file
% If the session type is not calibration, a calibration file containing the
% trained classifier and kernel density estimators. 
processingStruct.featureExtraction.ERP=[];
processingStruct.featureExtraction.ERP.fs=DAQClassObj.fs;
processingStruct.featureExtraction.ERP.rejectSequenceFlag=0;
processingStruct.featureExtraction.ERP.rejectSequenceInfo=[];
processingStruct.featureExtraction.FRP=processingStruct.featureExtraction.ERP;

if(exist('sessionID','var'))
    processingStruct.featureExtraction.ERP.sessionID=sessionID;
    processingStruct.featureExtraction.FRP.sessionID=sessionID;
end


% Initialize the Evidence Evaluators objects. 
initializeEvidenceEvaluators;

%% Initializes the RSVPKeyboardTask object to be used in decisionMaker.
RSVPKeyboardParams.sessionID = sessionID;
switch sessionID
    case 1    % Calibration
        RSVPKeyboardParams.isCalibration=1;  
        RSVPKeyboardTaskObject=CalibrationTask(imageStructs,RSVPKeyboardParams);
    case 2   % FRPCalibration
        RSVPKeyboardParams.isCalibration=1;
        RSVPKeyboardTaskObject=FRPCalibrationTask(imageStructs,RSVPKeyboardParams);
    case 3    % Spell
        RSVPKeyboardTaskObject=SpellingTask(imageStructs,RSVPKeyboardParams);
    case 4   % CopyPhrase
        RSVPKeyboardTaskObject=CopyPhraseTask(imageStructs,RSVPKeyboardParams);
        RSVPKeyboardTaskObject.currentInfo.showTarget=1;
    case 5   % MasteryTask
        RSVPKeyboardTaskObject=MasteryTask(imageStructs,RSVPKeyboardParams,scoreStruct);
        RSVPKeyboardTaskObject.currentInfo.showTarget=1;
    case 6  % Recursive Calibration
        RSVPKeyboardParams.isCalibration=1;
        RSVPKeyboardTaskObject=RecursiveCalibrationTask(imageStructs,RSVPKeyboardParams);
end



