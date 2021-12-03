%% [success,rawData,triggerData]=getAmpsData(amplifierStruct)
%getAmpsData(amplifierStruct) fetches the data from the amplifier(s) and
%   returns the data acquired since the last call of getAmpsData. It separately extracts
%   the raw data and the trigger signal. It requires the startAmps function to
%   be called at least once to be successful.
%
%   [success,rawData,triggerData]=getAmpsData(amplifierStruct)
%
%   The inputs of the function
%          amplifierStruct - A structure that contains the amplifier
%          information.
%
%   The outputs of the function
%          success (0/1) - a flag to show the success of the operation
%
%          rawData - an NxM matrix where N is the number of samples
%          acquired since the last call of getAmpsData function and M is
%          the number of non-trigger channels. It contains the raw data
%          corresponding to non-trigger channels.
%
%          triggerData - an Nx1 vector where N is the number of samples
%          acquired since the last call of getAmpsData function. It
%          contains the trigger signal.
%
%   See also getImpedance, startAmps, stopAmps
%%

function [success,rawData,triggerData]=getAmpsData(amplifierStruct)

try
    %% Fetching the data and trigger signal
    
    %% The first amplifier is the master amplifier. The number of samples available for fetching is queried from the master amplifier.
    ampIndex=1;
    %if(isfield(amplifierStruct,'ai'))
    numberOfSamplesAvailable = amplifierStruct.ai(ampIndex).SamplesAvailable;
    
    if numberOfSamplesAvailable
        %% If there exists at least one sample to be fetched, fetch the data and extract the non-trigger portion for the master amplifier.
        rawData=zeros(numberOfSamplesAvailable,amplifierStruct.totalNumberOfChannels);
        temp=getdata(amplifierStruct.ai(ampIndex),numberOfSamplesAvailable);
        rawData(:,amplifierStruct.channelBeginIndices(ampIndex):amplifierStruct.channelEndIndices(ampIndex))=temp(:,1:end-1);
        
        %% Extract the trigger portion of the data of the master amplifier and scale it to convert it to expected recording values.
        triggerData=round(temp(:,end)*1e6);
        
        %% If there exists more than one amplifier, fetch the data from them. Currently it is assumed that there is no trigger channel enabled for slave amplifiers.
        for ampIndex = 2: amplifierStruct.numberOfAmplifiers
            rawData(:,amplifierStruct.channelBeginIndices(ampIndex):amplifierStruct.channelEndIndices(ampIndex))...
                =getdata(amplifierStruct.ai(ampIndex),numberOfSamplesAvailable);
        end
    else
        %% If there exists no sample to be fetched, return empty data matrix and trigger vector.
        rawData =[];
        triggerData = [];
    end
    
%     else
%      rawData =[];
%         triggerData = [];
%     end
        
    success = 1;
catch ME
    logError(ME);
    success=0;
    rawData=[];
    triggerData=[];
end