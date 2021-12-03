%% function results = featureExtraction(dataBufferObject,triggerPartitionerStruct,featureExtractionStruct)
% Extracts the feature(s) from the data.
%   Inputs : dataBufferObject : an object that stores  data
%            triggerPartitionerStruct :
%            featureExtractionStruct : a struct for feature extraction
%
%   Outputs : results : a struct with following properties :
%             scores :
%             trialLabels : the label for each trial
%             completedSequenceCount : number of completed sequence
%             decideNextflag : a flag that can tell whether
%                              completedSequenceCount >0
%%
function [results,scoreStruct] = featureExtraction(...
    dataBufferObject,...
    triggerPartitionerStruct,...
    featureExtractionStruct,...
    channelStateChanged,...
    availableChannels,...
    RSVPKeyboardParams,...
    calibrationDataStruct...
    )

scoreStruct = [];

% availableChannels = false(1,length(availableChannels));
% availableChannels(:,[10,11]) = true;

% If there are any available channels, then perform the feature extraction
if any(availableChannels)
    
    if(featureExtractionStruct.sessionID == 1) || (strcmp(featureExtractionStruct.featureType,'FRP') && featureExtractionStruct.sessionID==2)
        results.scores = [];
        results.trialLabels = [];
        %if (strcmp(featureExtractionStruct.featureType,'FRP') && featureExtractionStruct.sessionID==2)
        results.duration=0;
        %end
    else
        if featureExtractionStruct.completedSequenceCount > 0 && ((isfield(featureExtractionStruct,'rejectedTrialsInSequence') && length(find(featureExtractionStruct.rejectedTrialsInSequence==0))>1)|| ~isfield(featureExtractionStruct,'rejectedTrialsInSequence') )
            
            trialData=zeros(triggerPartitionerStruct.windowLengthinSamples,dataBufferObject.numberofChannels,length(featureExtractionStruct.trialSampleTimeIndices));
            for(trialIndex=1:length(featureExtractionStruct.trialSampleTimeIndices))
                trialData(:,:,trialIndex) = dataBufferObject.getOrderedData(featureExtractionStruct.trialSampleTimeIndices(trialIndex),featureExtractionStruct.trialSampleTimeIndices(trialIndex)+triggerPartitionerStruct.windowLengthinSamples-1);
            end
            
            if (isfield(featureExtractionStruct,'rejectedTrialsInSequence'))
                trialData(:,:,featureExtractionStruct.rejectedTrialsInSequence==1)=[];
                featureExtractionStruct.trialLabels(featureExtractionStruct.rejectedTrialsInSequence==1)=[];
                featureExtractionStruct.trialTargetness(featureExtractionStruct.rejectedTrialsInSequence==1)=[];
            end
            
            
            %% In the event of a channel state change, retrain the classifier with data from the available channels.
            % Check if the channel state has changed, and if there is calibration data available.
            if and(channelStateChanged,~isempty(calibrationDataStruct))
                
                % Calculate the scores for the calibration data using the available channels.
                crossValidationObject = crossValidation(RSVPKeyboardParams.CrossValidation);
                calibrationScores = crossValidationObject.apply(featureExtractionStruct.Flow,calibrationDataStruct.trialData(:,availableChannels,:),calibrationDataStruct.trialTargetness);
                
                % Determine the target and nontarget scores.
                targetScores = calibrationScores(calibrationDataStruct.trialTargetness == 1);
                nontargetScores = calibrationScores(calibrationDataStruct.trialTargetness == 0);
                
                % Update the score struct probability densities.
                scoreStruct.conditionalpdf4targetKDE = kde1d(targetScores);
                scoreStruct.conditionalpdf4nontargetKDE = kde1d(nontargetScores);
                scoreStruct.probThresholdTarget = scoreThreshold(targetScores,scoreStruct.conditionalpdf4targetKDE.kernelWidth,0.99);
                scoreStruct.probThresholdNontarget = scoreThreshold(nontargetScores,scoreStruct.conditionalpdf4nontargetKDE.kernelWidth,0.99);
                
                % Retrain the classifier.
                featureExtractionStruct.Flow.learn(calibrationDataStruct.trialData(:,availableChannels,:),calibrationDataStruct.trialTargetness);
                
            end
            
            % Update the resultant scores and trial labels.
            results.scores = featureExtractionStruct.Flow.operate(trialData(:,availableChannels,:));
            results.trialLabels = featureExtractionStruct.trialLabels;
            %%
            
        else
            results.scores=[];
            results.trialLabels=[];
            results.duration=0;
        end
        
    end
    
    % if(featureExtractionStruct.completedSequenceCount>0 || featureExtractionStruct.rejectSequenceFlag==1)
    
    
else
    
    results.scores=[];
    results.trialLabels=[];
    results.duration=0;
    
end
results.completedSequenceCount=featureExtractionStruct.completedSequenceCount;
if(featureExtractionStruct.completedSequenceCount > 0)
    results.decideNextFlag=true;
    results.duration=(featureExtractionStruct.trialSampleTimeIndices(length(featureExtractionStruct.trialSampleTimeIndices))-featureExtractionStruct.trialSampleTimeIndices(1)+triggerPartitionerStruct.windowLengthinSamples)/featureExtractionStruct.fs;
else
    results.decideNextFlag=false;
end
