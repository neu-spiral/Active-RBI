%% initializeOfflineAnalysis
% Prepare the presentation for offline analysis.
%
%%

% Load the inputFilterCoef.mat file.
load 'inputFilterCoef.mat';

% Load the paramters of the program.
RSVPKeyboardParameters
signalProcessingParameters

% Load the imageList.xls file.
imageStructs = xls2Structs('imageList.xls');

% Initialize the triggerPartitioner struct.
triggerPartitioner.TARGET_TRIGGER_OFFSET = RSVPKeyboardParams.TARGET_TRIGGER_OFFSET;
triggerPartitioner.sequenceEndID = imageStructs(strcmpi({imageStructs.Name},'ERPSequenceEnd')).ID;
triggerPartitioner.pauseID = imageStructs(strcmpi({imageStructs.Name},'Pause')).ID;
triggerPartitioner.fixationID = imageStructs(strcmpi({imageStructs.Name},'Fixation')).ID;
triggerPartitioner.windowLengthinSamples = round(RSVPKeyboardParams.windowDuration.ERP*fs);
triggerPartitioner.firstUnprocessedTimeIndex = 1;

if strfind(fileName,'FRP')
triggerPartitioner.sequenceEndID = imageStructs(strcmpi({imageStructs.Name},'FRPSequenceEnd')).ID;
triggerPartitioner.fixationID = imageStructs(strcmpi({imageStructs.Name},'FRPSequenceBegin')).ID;
triggerPartitioner.windowLengthinSamples = round(RSVPKeyboardParams.windowDuration.FRP*fs);
RSVPKeyboardParams.SupervisedProccesses.optimizationMode=2;

end

% Initialise the frontendFilteringFlag variable.
frontendFilteringFlag = mainBuffer.frontendFilteringFlag;

% Set the value of the featureExtractionProcessFlow variable to a new processFlow object.
if RSVPKeyboardParams.formRecursiveProcessflow
    UnsupervisedProcessFlow = formProcessFlow(RSVPKeyboardParams.RecursiveUnsupervisedProccesses);
else
    UnsupervisedProcessFlow = formProcessFlow(RSVPKeyboardParams.UnsupervisedProccesses);
end

% UnsupervisedProcessFlow = processFlow;
% % Iterate over the length of the RSVPKeyboardParams.FeatureExtraction.operatorHandles variable.
% for processNodeIndex = 1:length(RSVPKeyboardParams.UnsupervisedProccesses.operatorHandles)
%     
%     % Check if the RSVPKeyboardParams.FeatureExtraction.operationParameters{processNodeIndex} variable is empty.
%     if isempty(RSVPKeyboardParams.UnsupervisedProccesses.operationParameters{processNodeIndex})
%         
%         % Set the value of the tempNode variable to a new processNode object.
%         tempNode = processNode(RSVPKeyboardParams.UnsupervisedProccesses.operatorHandles{processNodeIndex},RSVPKeyboardParams.UnsupervisedProccesses.operationModes(processNodeIndex));
%         
%     else
%         
%         % Set the value of the tempNode variable to a new processNode object.
%         tempNode = processNode(RSVPKeyboardParams.UnsupervisedProccesses.operatorHandles{processNodeIndex},RSVPKeyboardParams.UnsupervisedProccesses.operationModes(processNodeIndex),RSVPKeyboardParams.UnsupervisedProccesses.operationParameters{processNodeIndex});
%         
%     end
%     
%     % Append the tempNode variable to the featureExtractionProcessFlow object.
%     UnsupervisedProcessFlow.add(tempNode);
%     
% end


%SupervisedProcessFlow = formProcessFlow(RSVPKeyboardParams.SupervisedProccesses);
% processFlow;
% 
% % Iterate over the length of the RSVPKeyboardParams.FeatureExtraction.operatorHandles variable.
% for processNodeIndex = 1:length(RSVPKeyboardParams.SupervisedProccesses.operatorHandles)
%     
%     % Check if the RSVPKeyboardParams.FeatureExtraction.operationParameters{processNodeIndex} variable is empty.
%     if isempty(RSVPKeyboardParams.SupervisedProccesses.operationParameters{processNodeIndex})
%         
%         % Set the value of the tempNode variable to a new processNode object.
%         tempNode = processNode(RSVPKeyboardParams.SupervisedProccesses.operatorHandles{processNodeIndex},RSVPKeyboardParams.SupervisedProccesses.operationModes(processNodeIndex));
%         
%     else
%         
%         % Set the value of the tempNode variable to a new processNode object.
%         tempNode = processNode(RSVPKeyboardParams.SupervisedProccesses.operatorHandles{processNodeIndex},RSVPKeyboardParams.SupervisedProccesses.operationModes(processNodeIndex),RSVPKeyboardParams.SupervisedProccesses.operationParameters{processNodeIndex});
%         
%     end
%     
%     % Append the tempNode variable to the featureExtractionProcessFlow object.
%     SupervisedProcessFlow.add(tempNode);
%     
% end




% Set the value of the crossValidationObject variable to a new crossValidation object.
crossValidationObject = crossValidation(RSVPKeyboardParams.CrossValidation);