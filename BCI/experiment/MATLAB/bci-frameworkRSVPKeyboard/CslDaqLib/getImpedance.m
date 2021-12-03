%% [success,impedances]=getImpedance(amplifierStruct)
%getImpedance(amplifierStruct) fetches the impedance information from the amplifier(s) and
%   returns the it. Each call returns the acquires one impedance value for
%   each channel including the reference channels. Currently, there is no option of
%   querying the impedance value for a subset of channels.
%
%   [success,impedances]=getImpedance(amplifierStruct)
%
%   The inputs of the function
%          amplifierStruct - A structure that contains the amplifier
%          information.
%
%   The outputs of the function
%          success (0/1) - a flag to show the success of the operation
%          
%           impedances - a cell vector containing a structure corresponding
%           to each amplifier as its elements. The structures have the
%           following fields,
%
%               * impedances{ampIndex}.value - An Mx1 vector (double) containing the
%               impedance value of non-trigger channels and 4
%               reference channels for amplifier with the index ampIndex, where M is the number of channels including the references. 
%               * impedances{ampIndex}.hwChannels - An Mx1 vector (integer in [1,20])
%               containing the list of hardware channel connections, where
%               M is the number of channels including the references.
%               Channel 17-20 correspond to reference channels.
%               * impedances{ampIndex}.hwChannels - An Mx1 cell array
%               containing the electrode locations corresponding to each channel as strings, where
%               M is the number of channels including the references.
%
%   See also getAmpsData, startAmps, stopAmps
%%

function [success,impedances]=getImpedance(amplifierStruct)

try
    %% Retrieves the impedance value for each channel for each amplifier.
    impedances=cell(amplifierStruct.numberOfAmplifiers,1);
    for ampIndex = 1: amplifierStruct.numberOfAmplifiers
        %% Acquiring the non-trigger hardware channel indices for each channel.
        tempM=amplifierStruct.ai(ampIndex).Channel.HwChannel;
        %Handling the single channel case
        if(iscell(tempM))
            hwChannels=cell2mat(tempM);
        else
            hwChannels=tempM;
        end
        analogChannels=hwChannels<=16;
        hwChannels=hwChannels(analogChannels);
        
        %% Setting the mode to impedance and queries the impedance values.
        set(amplifierStruct.ai(ampIndex),'Mode','Impedance');
        z = gUSBampImpedance(amplifierStruct.ai(ampIndex).DeviceSerial);
        
        %% Selecting the impedance values corresponding to connected channels and the reference channel
        impedances{ampIndex}.value=[z(hwChannels);z(17:20)];
        
        %% Setting up the hardware channel indices.
        impedances{ampIndex}.hwChannels=[hwChannels;(17:20)'];
        
        %% Setting up the channel locations.
        temp=amplifierStruct.ai(ampIndex).Channel.ChannelName;
        impedances{ampIndex}.locations=[temp(analogChannels);{'Ref1';'Ref2';'Ref3';'Ref4'}];
    end
    success = 1;
catch ME
    logError(ME);
    success=0;
    impedances=[];
end