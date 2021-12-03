%% [success,amplifierStruct]=setupAmplifierParameters(amplifierStruct,daqStruct)
%setupAmplifierParameters(amplifierStruct,daqStruct) reads the channel
%   information from channel parameters file (a comma separated file with user defined
%   channel names and properties) and daqStruct, and accordingly adds channels to
%   the corresponding amplifiers.
%
%   [success,amplifierStruct]=setupAmplifierParameters(amplifierStruct,daqStruct)
%   
%   The inputs of the function
%          amplifierStruct - A structure that contains the amplifier
%          information.
%          daqStruct  - A structure that contains the data acquisition
%          parameters. The following members of this function is used in
%          this function.
%              * daqStruct.fs - Sampling Frequency
%              * daqStruct.ampFilterNdx - Filter Index for using built-in amplifier filters
%              * daqStruct.notchFiltexNdx - A notch filter index for using
%              built-in amplifier filters
%              * daqStruct.ampBufferLengthSec - Amplifier buffer length 
%              * daqStruct.calibrationOn (0/1) - A flag to activate the
%              calibration of the amplifiers
%
%   The outputs of the function
%          success (0/1) - a flag to show the success of the operation
%          
%           amplifierStruct - The following members of this structure
%           is filled in this function.
%
%               * amplifierStruct.numberOfChannels - Number of channels for
%               each amplifier (integer) 
%               * amplifierStruct.totalNumberOfChannels - Total number of
%               channels connected to the system (integer) to be used in getAmpsData()
%               * amplifierStruct.channelBeginIndices - Beginning indices
%               of channels for different amplifiers (integer) to be used in getAmpsData()
%               * amplifierStruct.channelEndIndices - Ending indices of
%               channels for different amplifiers (integer) to be used in getAmpsData()
%               * amplifierStruct.channelNames - active channel names in the order
%               of channel numbers in rawData (data read from the amplifiers)
%
%   See also readChannelInfo, DAQParameters, getAmpsData
%%


function [success,amplifierStruct]=setupAmplifierParameters(amplifierStruct,daqStruct)
    %% Global variables to define the folder and the name of the file that record the channel parameters


global recordingFolder
global channelParametersFilename

try
    %% Reading the channel information file and saving it in the recording folder
    
    
    
    [success,ampChannelList]=readChannelInfo(channelParametersFilename);
    success = copyfile(channelParametersFilename,[recordingFolder '\' recordingFolder '-channelsLog.csv'],'f');
    %% Checking the number of channels connected to each amplifier
    
    tempChannelList = find(~strcmpi(ampChannelList.channelType, 'NC'));
    
    if amplifierStruct.numberOfAmplifiers < ceil(tempChannelList(end)/16)
        tempStr='Error: Not enough amplifiers are connected.';
        logError(tempStr)
        disp(tempStr);
        success=0;
    end
    
    amplifierStruct.numberOfChannels=zeros(amplifierStruct.numberOfAmplifiers,1);
    
    %% Set mode and log filename
    for ampIndex = 1: amplifierStruct.numberOfAmplifiers
        set(amplifierStruct.ai(ampIndex),'Mode','Normal');
        set(amplifierStruct.ai(ampIndex),'LoggingMode','Disk&Memory');
        set(amplifierStruct.ai(ampIndex),'LogToDiskMode','Index');
        
    end
    
    %% Adding channels to each amplifier with prespecified channel names, bandpass and notch filter structures
    
    iChannelCounter = 1;
    for channelIndex = tempChannelList'
        ampIndex = floor((channelIndex-1)/16)+1;
        amplifierStruct.numberOfChannels(ampIndex)=amplifierStruct.numberOfChannels(ampIndex)+1;
        ampChannelIndex = mod(channelIndex,16)+(mod(channelIndex,16)==0)*16;
        
        
        addchannel(amplifierStruct.ai(ampIndex),ampChannelIndex);
        set(amplifierStruct.ai(ampIndex).Channel(amplifierStruct.numberOfChannels(ampIndex)),...
            'BPIndex',daqStruct.ampFilterNdx,...
            'NotchIndex',daqStruct.notchFiltexNdx,...
            'ChannelName',ampChannelList.electrodeLocations{channelIndex});
        amplifierStruct.channelNames{iChannelCounter} = ampChannelList.electrodeLocations{channelIndex};
        iChannelCounter = iChannelCounter + 1;
        
    end
    
    %% Adding the trigger channel to the first amplifier and specifying the input and output range for this channel
    ampIndex = 1;
    addchannel(amplifierStruct.ai(ampIndex),17);
    amplifierStruct.triggerIndex=amplifierStruct.numberOfChannels(ampIndex)+1;
    set(amplifierStruct.ai(ampIndex).Channel(amplifierStruct.triggerIndex),...
        'ChannelName','Trigger',...
        'InputRange',[0 5],...
        'SensorRange',[0 5],...
        'UnitsRange',[0 5]);
    
    %% Setting up the channel properties such as sampling rate, buffering mode and ground and reference specifications
    
    for ampIndex = 1:amplifierStruct.numberOfAmplifiers
        set(amplifierStruct.ai(ampIndex),...
            'SampleRate',daqStruct.fs,...
            'SamplesPerTrigger',daqStruct.ampBufferLengthSec*daqStruct.fs,...
            'BufferingMode','Auto',...
            'GroupAToCommonGround','Enabled','GroupAToCommonReference','Enabled',...
            'GroupBToCommonGround','Enabled','GroupBToCommonReference','Enabled',...
            'GroupCToCommonGround','Enabled','GroupCToCommonReference','Enabled',...
            'GroupDToCommonGround','Enabled','GroupDToCommonReference','Enabled',...
            'Timeout',5);
    end
    
    %% Computing the total number of channels, and beginning and ending indices of channels for different amplifiers
    
    amplifierStruct.totalNumberOfChannels=sum(amplifierStruct.numberOfChannels);
    amplifierStruct.channelBeginIndices=cumsum([1;amplifierStruct.numberOfChannels(1:end-1)]);
    amplifierStruct.channelEndIndices=cumsum(amplifierStruct.numberOfChannels);
    success=1;
catch ME
    logError(ME);
    success=0;
end

