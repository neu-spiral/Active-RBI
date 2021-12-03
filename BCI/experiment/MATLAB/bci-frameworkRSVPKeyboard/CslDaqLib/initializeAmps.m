%% [success,amplifierStruct,fs,numberOfChannels]=initializeAmps(amplifierStruct)
%Initializes the amplifier(s).
%   Using the setupAmplifierParameters and the paremeters from
%   DAQParameters it sets the parameters for the amplifier(s).
%
%   [success,amplifierStruct,fs,numberOfChannels]=initializeAmps
%   inputs
%       amplifierStruct - The structure containing amplifer objects and
%                         some extra information. (for more information see
%                         detectAmps.
%   returns
%       success (0/1) - a flag to show the success of the operation
%       fs - Data sampling rate
%       numberOfChannels - Total number of data channels in use
%       amplifierStruct - The structure containing amplifer objects and
%                         some extra information. (for more information see
%                         detectAmps.
%
%   See also detectAmps, DAQParameters, setupAmplifierParameters,
%   calibrateAmps

%%

function [success,amplifierStruct,fs,numberOfChannels] = initializeAmps(amplifierStruct)
    try
        DAQParameters;
        fs=daqStruct.fs;
        amplifierStruct.fs=fs;

        [success,amplifierStruct]=setupAmplifierParameters(amplifierStruct,daqStruct);

        numberOfChannels=amplifierStruct.totalNumberOfChannels;

    catch ME
        success = 0;
        logError(ME);
        amplifierStruct = [];
        fs = [];
        numberOfChannels = [];
    end
end
