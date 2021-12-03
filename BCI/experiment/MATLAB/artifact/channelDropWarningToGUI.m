%% function channelDropWarningToGUI(dataBufferObject,remoteGUI,artifactFilteringParams,RSVPKeyboardArtifactFiltering)
% sends warning for channel drop according the new data in buffer to GUI:
%   Inputs : dataBufferObject : an object that stores  data
%            remoteGUI : GUI object
%            artifactFilteringParams : parameters for artifact filtering
%            RSVPKeyboardArtifactFiltering: RSVP keyboard parameters

%%
function channelDropWarningToGUI(dataBufferObject,remoteGUI,artifactFilteringParams,RSVPKeyboardArtifactFiltering)

persistent lastTimeIndex
persistent oldChannelStatuses

if isempty(lastTimeIndex)
    lastTimeIndex=0;
    oldChannelStatuses=ones(1,dataBufferObject.numberofChannels);
end

if ~isempty(remoteGUI) && RSVPKeyboardArtifactFiltering.channelDropWarning
    if lastTimeIndex~=dataBufferObject.lastSampleTimeIndex
        newDataInBuffer=dataBufferObject.getOrderedData(lastTimeIndex,dataBufferObject.lastSampleTimeIndex-1);
        totalRMS=sqrt(sum(newDataInBuffer.^2)/size(newDataInBuffer,1));
        lastTimeIndex=dataBufferObject.lastSampleTimeIndex;
        OutlierChannelsDropped=union(find(totalRMS<artifactFilteringParams.totalRMSlowerBand),...
            find(totalRMS>artifactFilteringParams.totalRMSupperBand));
        
        channelStatuses = ones(1,dataBufferObject.numberofChannels);
        
        if ~isempty(OutlierChannelsDropped)
            
            channelStatuses(OutlierChannelsDropped) = 0;
            
        end
        if(any(channelStatuses~=oldChannelStatuses))
            remoteGUI.setChannelStatuses(channelStatuses);
            oldChannelStatuses=channelStatuses;
        end
    else
        OutlierChannelsDropped=[];
    end
    
end


