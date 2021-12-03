%% [success,amplifierStruct,fs,numberOfChannels]=initializeDAQnoAmp
%initializeDAQnoAmp function sets the variables for simulating data
% aquisition when we are not using amplifiers(for example for offline
% rerun of the session or when we are testing the code with no amplifiers). It
% will set the amplifier parameters with respect to the presentation
% parameters.
%
%   The outputs of the function
%      success - This output is alwayes set to 1. In online process this
%      parameter was responsible for determining if DAQ process has been
%      successful or not but here we will alwayes set it to 1.
%
%      amplifierStruct - This output is a structure of amplifier parameters
%      data.
%
%      fs - This output is a scaler which represents sampling frequency.
%
%      numberOfChannels - This output is a scaler which represents the
%      number of channels. Here it will always set to 16.


%%
function [success,amplifierStruct,fs,numberOfChannels]=initializeDAQnoAmp
DAQParameters
presentationParameters


fs=daqStruct.fs;

[daqFileList,sessionFolder]=uigetfile({'*.daq';'*.mat'},'Please Select the Data Files to be Loaded or Press Escape to Continue with Randomly Generated Signals','MultiSelect', 'on','Data\');
if(daqFileList==0)
    
    numberOfChannels=16;
    amplifierStruct.isFile=0;
    amplifierStruct.numberOfChannels=16;
    amplifierStruct.awaitingTriggers=handleVariable;
    amplifierStruct.channelNames={'Fp1','Fp2','F3','F4','Fz','Fc1','Fc2','Cz','P1','P2','C1','C2','Cp3','Cp4','P5','P6'};
else
    filetype=daqFileList(end-2:end);
    switch filetype
        case 'daq'
            [amplifierStruct.rawData,amplifierStruct.triggerSignal,sampleRate,amplifierStruct.channelNames,filterInfo,daqInfos]=loadSessionData(daqFileList,sessionFolder);
        case 'mat'
            load([sessionFolder '\' daqFileList]);
            
            amplifierStruct.rawData=rawData;
            amplifierStruct.triggerSignal=triggerSignal;
            sampleRate=sampleRate;
            amplifierStruct.channelNames=channelNames;
            filterInfo=filterInfo;
            daqInfos=daqInfos;
            
    end
    amplifierStruct.isFile=1;
    amplifierStruct.currentSampleIndex=handleVariable;
    amplifierStruct.currentSampleIndex.data=1;
    amplifierStruct.sampleInterval=fs;
    numberOfChannels=size(amplifierStruct.rawData,2);
    amplifierStruct.awaitingTriggers=handleVariable;
    
end

amplifierStruct.fs=fs;
amplifierStruct.Duration=presentationStruct.Duration;
amplifierStruct.DutyCycle=presentationStruct.DutyCycle;
success=1;