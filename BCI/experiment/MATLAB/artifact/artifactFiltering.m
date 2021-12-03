%% function [featureExtractionStruct,availableChannels]=artifactFiltering(amplifierStruct,dataBufferObject,fs,triggerPartitionerStruct,featureExtractionStruct,artifactFilteringParams,RSVPKeyboardArtifactFiltering,remoteGUI,calibrationArtifactParameters)
% This function is called at each main loop and sends data to artifact
% removal after each sequence.
%   Inputs : amplifierStruct : A structure that contains the amplifier
%            information
%
%            dataBufferObject : an object that stores  data
%
%            fs : Sampling frequency
%
%            triggerPartitionerStruct : a dataBuffer class object containing the
%            buffer corresponding to trigger signal
%
%            featureExtractionStruct : A structure that contains the
%            feature extraction information
%
%            artifactFilteringParams : A structure that contains the
%            artifact filtering parameters
%
%            RSVPKeyboardArtifactFiltering : A structure that contains the
%            RVSP keyboard parameters corresponding to artifact filtering
%
%            remoteGUI : GUI object
%
%            calibrationArtifactParameters : A structure that contains the
%            artifact filtering parameters calculated using calibration
%            data
%
%   Outputs : 
%            availableChannels : this vector shows channel drop. all
%            channels that are dropped are labled as 0 and available 
%            channels are 1 
%            featureExtractionStruct : A structure that contains the
%            feature extraction information

%%
function [featureExtractionStruct,availableChannels]=artifactFiltering(channelNames,...
                                                                       dataBufferObject,...
                                                                       fs,...
                                                                       triggerPartitionerStruct,...
                                                                       featureExtractionStruct,...
                                                                       artifactFilteringParams,...
                                                                       RSVPKeyboardArtifactFiltering,...
                                                                       remoteGUI,...
                                                                       calibrationArtifactParameters)


if RSVPKeyboardArtifactFiltering.enabled
    
    
      channelDropWarningToGUI(dataBufferObject,remoteGUI,artifactFilteringParams,RSVPKeyboardArtifactFiltering);
        
    if featureExtractionStruct.completedSequenceCount > 0 
        
        trialData=zeros(triggerPartitionerStruct.windowLengthinSamples,dataBufferObject.numberofChannels,length(featureExtractionStruct.trialSampleTimeIndices));
        dataInBuffer=dataBufferObject.getOrderedData(featureExtractionStruct.trialSampleTimeIndices(1),featureExtractionStruct.trialSampleTimeIndices(end)+triggerPartitionerStruct.windowLengthinSamples-1);
        for trialIndex=1:length(featureExtractionStruct.trialSampleTimeIndices)
            trialData(:,:,trialIndex) = dataBufferObject.getOrderedData(featureExtractionStruct.trialSampleTimeIndices(trialIndex),featureExtractionStruct.trialSampleTimeIndices(trialIndex)+triggerPartitionerStruct.windowLengthinSamples-1);
        end
        [rejectedTrialsInSequence,availableChannels] = artifactRemoval(dataInBuffer,...
            trialData,...
            fs,...
            artifactFilteringParams,...
            calibrationArtifactParameters,...
            RSVPKeyboardArtifactFiltering);
        
%         availableChannels = false(1,length(channelNames));
%         availableChannels(:,[10,11]) = true;
        
        featureExtractionStruct.rejectedTrialsInSequence=rejectedTrialsInSequence;
    else
    availableChannels = true(1,length(channelNames));
%     availableChannels = false(1,length(channelNames));
%     availableChannels(:,[10,11]) = true;
    
    featureExtractionStruct.rejectedTrialsInSequence=zeros(1,length(featureExtractionStruct.trialSampleTimeIndices));
    
    end

else
    availableChannels = true(1,length(channelNames));
%     availableChannels = false(1,length(channelNames));
%     availableChannels(:,[10,11]) = true;

    featureExtractionStruct.rejectedTrialsInSequence=zeros(1,length(featureExtractionStruct.trialSampleTimeIndices));
    
end
