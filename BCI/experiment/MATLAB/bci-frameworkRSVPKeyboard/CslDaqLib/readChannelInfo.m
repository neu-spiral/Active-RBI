%% [success,ampChannelList]=readChannelInfo(filename)
%readChannelInfo(filename) reads the channel information of the amplifiers
%   from a csv (comma separated value) file. This function is called in
%   setupAmplifierParameters function. 
%   
%   [success,ampChannelList]=readChannelInfo(filename)
%
%   The inputs of the function 
%   
%      filename - A string containing the name and the directory of the csv file to be read.
%
%   The outputs of the function
%   
%       success (0/1) -  A flag to show the success of the operation
%
%       ampChannelList - A structure that contains the information about
%       the channels connected to the amplifiers. The members of this
%       structure used in this function are the followings.
%
%           * ampChannelList.channelIndices - A list that contains the
%           indices of channels connected to each amplifier (integer).
%           * ampChannelList.electrodeLocations - A list that contains the
%           physiological locations of the electrodes that are connected to
%           amplifiers (string). 
%           * ampChannelList.channelType- A list that contains the type of
%           the channels connected to the amplifiers (EEG, EMG, etc.)
%
%  See also setupAmplifierParameters
%%



function [success,ampChannelList]=readChannelInfo(filename)


TOTAL_NUMBER_OF_CHANNELS=64; % 64 is the maximum number of channels that could be used by gtec amplifiers. 
%% Initializing the ampChannelList structure


ampChannelList.channelIndices=zeros(TOTAL_NUMBER_OF_CHANNELS,1);
ampChannelList.electrodeLocations=cell(TOTAL_NUMBER_OF_CHANNELS,1);
ampChannelList.channelType=cell(TOTAL_NUMBER_OF_CHANNELS,1);
try
    %% Importing the data and saving the channel indices, channel types and electrode locations in ampChannelList structure.
   
    
    rawChannelListCell=importdata(filename);
    
    currentLine=1;
    channelCounter=1;
    while currentLine<=length(rawChannelListCell)
        if (strncmpi(rawChannelListCell{currentLine},'Master',6) || (strncmpi(rawChannelListCell{currentLine},'Slave',5)))
            for lineNo=currentLine+2:currentLine+17
                temp=textscan(rawChannelListCell{lineNo},'%d%s%s','Delimiter',',');
                ampChannelList.channelIndices(channelCounter)=temp{1};
                ampChannelList.electrodeLocations{channelCounter}=temp{2}{1};
                ampChannelList.channelType{channelCounter}=temp{3}{1};
                channelCounter=channelCounter+1;
            end
            currentLine=lineNo+1;
            
        else
            currentLine=currentLine+1;
        end
    end
    success=1;
catch ME
    logError(ME);
    disp(['Error: ' ME.message]);
    success=0;
end

if(channelCounter<TOTAL_NUMBER_OF_CHANNELS)
    tempStr=['Error: Incorrect formatting of ' filename];
    logError(tempStr)
    disp(tempStr);
    success=0;
end
