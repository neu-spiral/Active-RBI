%% fetchData
% Obtains the data from the data acquisition source. 

switch daqStruct.DAQType
    %%%%
    case 'gUSBAmp'
        %[success,rawData,triggerData] = getAmpsData(amplifierStruct);
        [rawData,triggerData]=DAQClassObj.GetData;
    case 'noAmp'
        if(amplifierStruct.isFile)
            oldLoc = amplifierStruct.currentSampleIndex.data;
            amplifierStruct.currentSampleIndex.data=oldLoc+amplifierStruct.sampleInterval;
            try
                rawData=amplifierStruct.rawData(oldLoc:amplifierStruct.currentSampleIndex.data-1,:);
                triggerData=amplifierStruct.triggerSignal(oldLoc:amplifierStruct.currentSampleIndex.data-1);
            catch ME
                rawData=[];
                triggerData=[];
            end

        else
            dt=toc(amplifierStruct.lastAcquisitionTimeStamp.data);
            amplifierStruct.lastAcquisitionTimeStamp.data=tic;
            sampleCount=round(dt*amplifierStruct.fs);
            rawData=20e-6*randn(sampleCount,amplifierStruct.numberOfChannels);
            if(sampleCount>size(amplifierStruct.awaitingTriggers.data,1))
                triggerData=[amplifierStruct.awaitingTriggers.data;zeros(sampleCount-size(amplifierStruct.awaitingTriggers.data,1),1)];
                amplifierStruct.awaitingTriggers.data=[];
            else
                triggerData=amplifierStruct.awaitingTriggers.data(1:sampleCount);
                amplifierStruct.awaitingTriggers.data=amplifierStruct.awaitingTriggers.data(sampleCount+1:end);
            end
        end
        success = true;
        
        
end