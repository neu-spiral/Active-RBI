function [attentionMonitoringStruct]=attentionMonitoring(attentionMonitoringEnabled,...
    useArtifactFilteredData,...
    windowLength,...
    fs,...
    dataBufferObject,...
    cleanDataBufferObject,...
    artifactFilteringEnabled,...
    channelNames)

 persistent lastProcessedSampleTimeIndex;


if attentionMonitoringEnabled==1
    
    if isempty(lastProcessedSampleTimeIndex),
        lastProcessedSampleTimeIndex=1;
    end
    
    
    if useArtifactFilteredData && artifactFilteringEnabled
        
        if (cleanDataBufferObject.lastSampleTimeIndex-lastProcessedSampleTimeIndex)>=windowLength*fs
                      
            trialData(:,:) = cleanDataBufferObject.getOrderedData(lastProcessedSampleTimeIndex,cleanDataBufferObject.lastSampleTimeIndex);
            lastProcessedSampleTimeIndex=cleanDataBufferObject.lastSampleTimeIndex;
            [attentionMonitoringStruct.thetaPower,attentionMonitoringStruct.alphaPower,attentionMonitoringStruct.lateralEyeMovement,attentionMonitoringStruct.eyeBlinkRate]=calculateVigilanceMeasures(trialData,channelNames,fs);
            attentionMonitoringStruct.show=true;
            
        else
            
            attentionMonitoringStruct.show=false;
            
        end
        
        
    else  %% means if useArtifactFilteredData=0 and we want to use dataBuffer
        if (dataBufferObject.lastSampleTimeIndex-lastProcessedSampleTimeIndex)>=windowLength*fs
            
             trialData(:,:) = dataBufferObject.getOrderedData(lastProcessedSampleTimeIndex,dataBufferObject.lastSampleTimeIndex);
            lastProcessedSampleTimeIndex=dataBufferObject.lastSampleTimeIndex;
            [attentionMonitoringStruct.thetaPower,attentionMonitoringStruct.alphaPower,attentionMonitoringStruct.lateralEyeMovement,attentionMonitoringStruct.eyeBlinkRate]=calculateVigilanceMeasures(trialData,channelNames,fs);
            attentionMonitoringStruct.show=true;
            
        else
            
            attentionMonitoringStruct.show=false;


        end
        
        
        
    end
else
    
    attentionMonitoringStruct.show=0;
    
end
