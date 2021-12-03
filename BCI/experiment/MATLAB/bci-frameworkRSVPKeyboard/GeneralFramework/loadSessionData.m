%% [rawData,triggerSignal,sampleRate,channelNames,filterInfo,daqInfos]=loadSessionData(daqFileList)
%loadSessionData(sessionFolder) loads offline the data obtained in a
%   session. The daq files (data acquisition files) recorded for each amplifier are read through this
%   function. 
% 
%   [rawData,triggerSignal,sampleRate,channelNames,filterInfo,daqInfos]=loadSessionData(daqFileList)
%   reads loads the data obtained durind a session. 
%
%       The inputs of the function 
%            daqFileList - The list of file paths to be loaded as a cell of strings. If
%            a list is not pre-specified, a pop up window asks you to
%            locate the files.
%
%       The outputs of the function
%           rawData - A matrix containing the eeg data. Each column
%           corresponds to a different channel.
%           triggerSignal - A vector containing the trigger data.
%           sampleRate - The sampling frequency.
%           channelNames - A vector containing the channel names used in the experiment.
%           filterInfo - A structure containing the information about the
%           filter used in the amplifiers during the data acquisition. The
%           followings are the elements of this structure.
%                * filterInfo.BPLow - The lower cut off frequency of the
%                bandpass filter. 
%                * filterInfo.BPHigh - The higher cutoff frequency of the
%                bandpass filter.
%                * filterInfo.Notch - The frequency of the notch filter. 
%           daqInfos - A structure containing the information about the
%           data acquisiton file and the process. For more information
%           please see daqread in the data acquisition toolbox.
%               
%           
%%




function [rawData,triggerSignal,sampleRate,channelNames,filterInfo,daqInfos,sessionFolder]=loadSessionData(daqFileList,sessionFolder)
%% Obtaining the information about the session folder.


if(nargin<1)
    [daqFileList,sessionFolder]=uigetfile('*.daq','Please Select the Data Recording Files','MultiSelect', 'on','Data\');
end
if(~iscell(daqFileList))
    daqFileList={daqFileList};
end

%% Obtaining information about the amplfiers and data acquisition set up

noOfAmplifiers=size(daqFileList,1);
chanInfos=cell(noOfAmplifiers,1);
noOfSamplesAcquired=zeros(noOfAmplifiers,1);

daqInfos=cell(noOfAmplifiers,1);
for(filei=1:noOfAmplifiers)
    filepath=[sessionFolder daqFileList{filei}];
    daqInfos{filei} = daqread(filepath, 'info');
    chanInfos{filei} = daqInfos{filei}.ObjInfo.Channel;
    noOfSamplesAcquired(filei)=daqInfos{filei}.ObjInfo.SamplesAcquired;
end

channelCounts=cellfun('length',chanInfos);
totalChannelCount=sum(channelCounts)-1;

channelNames=cell(1,totalChannelCount);

minNoOfSamplesAcquired=min(noOfSamplesAcquired);
rawData=zeros(minNoOfSamplesAcquired,totalChannelCount);

ampIndex=1;
filterInfo.BPLow=chanInfos{ampIndex}(1).BPLow;
filterInfo.BPHigh=chanInfos{ampIndex}(1).BPHigh;
filterInfo.Notch=chanInfos{ampIndex}(1).Notch;
sampleRate=daqInfos{ampIndex}.ObjInfo.SampleRate;

%% Reading the daq files for each amplifier and saving the eeg and trigger data 

filepath=[sessionFolder daqFileList{ampIndex}];
temp=daqread(filepath);
channelIndex=0;
for(ampChannelIndex=1:channelCounts(ampIndex)-1)
    channelNames{channelIndex+ampChannelIndex}=chanInfos{ampIndex}(ampChannelIndex).ChannelName;
end

rawData(:,1:(channelCounts(ampIndex)-1))=temp(1:minNoOfSamplesAcquired,1:(channelCounts(ampIndex)-1));
triggerSignal=round(temp(1:minNoOfSamplesAcquired,channelCounts(ampIndex))*1e6);
channelIndex=channelCounts(ampIndex)-1;
for(ampIndex=2:noOfAmplifiers)
    filepath=[sessionFolder daqFileList{ampIndex}];
    temp=daqread(filepath);
    rawData(:,channelIndex+1:(channelIndex+channelCounts(ampIndex)))=temp(1:minNoOfSamplesAcquired,:);
    for(ampChannelIndex=1:channelCounts(ampIndex))
        channelNames{channelIndex+ampChannelIndex}=chanInfos{ampIndex}(ampChannelIndex).ChannelName;
    end
    channelIndex=channelIndex+channelCounts(ampIndex);
end
isRawData=1;
EEGfileName=daqFileList{1}; 
save([sessionFolder '/' EEGfileName(1:end-3)  '.mat'],'isRawData','rawData','triggerSignal','sampleRate','channelNames','filterInfo','daqInfos')