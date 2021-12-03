%% function [rejectedTrialsInSequence,availableChannels]= artifactRemoval(dataInBuffer,artifactRemovalInputData,fs,artifactFilteringParams,calibrationArtifactParameters,RSVPKeyboardArtifactFiltering)
% This function is called after each sequence and checks two things:
%
%   1 - Whether a channel was dropped during each sequence.
%   2 - Whether a trial was contaminated during each sequence.
%
%   Inputs : dataInBuffer : a matrix that contains the data in buffer 
%            during a full sequence.
%
%            artifactRemovalInputData : a cube of data that contains the
%            data during a sequence. the dimensions are N*C*T, N being the
%            time samples, C being channels numbers and T the trial numbers
%
%            fs : Sampling frequency
%
%            triggerPartitionerStruct : a dataBuffer class object containing the
%            buffer corresponding to trigger signal
%
%            artifactFilteringParams : A structure that contains the
%            artifact filtering parameters
%
%            RSVPKeyboardArtifactFiltering : A structure that contains the
%            RVSP keyboard parameters corresponding to artifact filtering
%
%            calibrationArtifactParameters : A structure that contains the
%            artifact filtering parameters calculated using calibration
%            data
%
%   Outputs : 
%            availableChannels : this vector shows channel drop. all
%            channels that are dropped are labled as 0 and available 
%            channels are 1 
%            rejectedTrialsInSequence : a vector equal to number of trials
%            in each sequence, rejected trials are labeled as 1 and the
%            rest are labeled as zeros.
%%
function [rejectedTrialsInSequence,availableChannels]= artifactRemoval(dataInBuffer,...
    artifactRemovalInputData,...
    fs,...
    artifactFilteringParams,...
    calibrationArtifactParameters,...
    RSVPKeyboardArtifactFiltering)


%% (1) channel dropped detection
availableChannels = ones(1,size(artifactRemovalInputData,2));

if  RSVPKeyboardArtifactFiltering.channelDropWarning
    
    if ~isempty(dataInBuffer)
        
        totalRMSOfData=sqrt(sum(dataInBuffer.^2)/size(dataInBuffer,1));
        
        OutlierChannelsDropped=union(find(totalRMSOfData<artifactFilteringParams.totalRMSlowerBand),...
            find(totalRMSOfData>artifactFilteringParams.totalRMSupperBand));
        
        availableChannels(OutlierChannelsDropped)=0;
        
    end
    
end


%% (2)Epoch rejection section

rejectedTrialsInSequence=zeros(1,size(artifactRemovalInputData,3));

if RSVPKeyboardArtifactFiltering.rejectSequence
    
    
    if ~isempty(calibrationArtifactParameters)
        
        amplitudeThreshold=min(artifactFilteringParams.amplitudeThreshold,calibrationArtifactParameters.amplitudeThreshold);
        RMSthreshold=min(artifactFilteringParams.RMSthreshold,calibrationArtifactParameters.RMSthreshold);
        powerDeltaThreshold=zeros(1,size(artifactRemovalInputData,2));
        powerThetaThreshold=zeros(1,size(artifactRemovalInputData,2));
        powerAlphaThreshold=zeros(1,size(artifactRemovalInputData,2));
        powerBetaThreshold=zeros(1,size(artifactRemovalInputData,2));
        powerGammaThreshold=zeros(1,size(artifactRemovalInputData,2));
        
        for channelCount=1:size(artifactRemovalInputData,2)
            
            powerDeltaThreshold(channelCount)=min(artifactFilteringParams.powerDeltaThreshold,calibrationArtifactParameters.powerDeltaThreshold(channelCount));
            powerThetaThreshold(channelCount)=min(artifactFilteringParams.powerThetaThreshold,calibrationArtifactParameters.powerThetaThreshold(channelCount));
            powerAlphaThreshold(channelCount)=min(artifactFilteringParams.powerAlphaThreshold,calibrationArtifactParameters.powerAlphaThreshold(channelCount));
            powerBetaThreshold(channelCount)=min(artifactFilteringParams.powerBetaThreshold,calibrationArtifactParameters.powerBetaThreshold(channelCount));
            powerGammaThreshold(channelCount)=min(artifactFilteringParams.powerGammaThreshold,calibrationArtifactParameters.powerGammaThreshold(channelCount));
            
        end
        
    else
        amplitudeThreshold=artifactFilteringParams.amplitudeThreshold;
        RMSthreshold=artifactFilteringParams.RMSthreshold;
        
        powerDeltaThreshold=repmat(artifactFilteringParams.powerDeltaThreshold,1,size(artifactRemovalInputData,2));
        powerThetaThreshold=repmat(artifactFilteringParams.powerThetaThreshold,1,size(artifactRemovalInputData,2));
        powerAlphaThreshold=repmat(artifactFilteringParams.powerAlphaThreshold,1,size(artifactRemovalInputData,2));
        powerBetaThreshold=repmat(artifactFilteringParams.powerBetaThreshold,1,size(artifactRemovalInputData,2));
        powerGammaThreshold=repmat(artifactFilteringParams.powerGammaThreshold,1,size(artifactRemovalInputData,2));
    end
    
    
    frequencyRange = fs*(0:artifactFilteringParams.nfft-1)/artifactFilteringParams.nfft;
    trialFFT=zeros(artifactFilteringParams.nfft,size(artifactRemovalInputData,2),size(artifactRemovalInputData,3));
    for(trialIndex=1:size(artifactRemovalInputData,3))
        for(channelIndex=1:size(artifactRemovalInputData,2))
            trialFFT(:,channelIndex,trialIndex)=fft(artifactRemovalInputData(:,channelIndex,trialIndex),artifactFilteringParams.nfft);
        end
    end
    deltaPower = sum(abs(trialFFT(frequencyRange>=0 & frequencyRange<4,:,:)).^2)/artifactFilteringParams.nfft;
    thetaPower = sum(abs(trialFFT(frequencyRange>=4 & frequencyRange<=8,:,:)).^2)/artifactFilteringParams.nfft;
    alphaPower = sum(abs(trialFFT(frequencyRange>8 & frequencyRange<=13,:,:)).^2)/artifactFilteringParams.nfft;
    betaPower = sum(abs(trialFFT(frequencyRange>=13 & frequencyRange<30,:,:)).^2)/artifactFilteringParams.nfft;
    gammaPower = sum(abs(trialFFT(frequencyRange>=30 & frequencyRange<45,:,:)).^2)/artifactFilteringParams.nfft;
    
    
    for trialCount=1:size(artifactRemovalInputData,3)
        
        if  ~isempty(find(abs(artifactRemovalInputData(:,availableChannels==1,trialCount))>amplitudeThreshold, 1)) && ...
                ~isempty(find(sqrt(sum(artifactRemovalInputData(:,availableChannels==1,trialCount).^2)/size(artifactRemovalInputData,1))>RMSthreshold, 1))
            
            rejectedTrialsInSequence(trialCount)=1;
            
        end
        
        goodChannels=find(availableChannels==1);
        
        for channelCount=1:length(goodChannels)        
                    
            if ~isempty(find(deltaPower(:,goodChannels(channelCount),trialCount)>powerDeltaThreshold(goodChannels(channelCount)), 1)) && ...
                    ~isempty(find(thetaPower(:,goodChannels(channelCount),trialCount)>powerThetaThreshold(goodChannels(channelCount)), 1)) && ...
                    ~isempty(find(alphaPower(:,goodChannels(channelCount),trialCount)>powerAlphaThreshold(goodChannels(channelCount)), 1)) && ...
                    ~isempty(find(betaPower(:,goodChannels(channelCount),trialCount)>powerBetaThreshold(goodChannels(channelCount)), 1)) && ...
                    ~isempty(find(gammaPower(:,goodChannels(channelCount),trialCount)>powerGammaThreshold(goodChannels(channelCount)), 1))
                
                
                rejectedTrialsInSequence(trialCount)=1;
                
                
            end
            
        end
    end
    
end


