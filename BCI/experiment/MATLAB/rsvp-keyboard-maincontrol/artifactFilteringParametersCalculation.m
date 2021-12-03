%%
% This script calculates the relative values for artifact filtering from
% calibration data. It calculates the threshold for:
%   1 - amplitude threshold
%   2 - RMS threshold
%   3 - power spectral density for each of eeg bands 

%%
frequencyRange = fs/2*linspace(0,1,artifactFilteringParams.nfft/2+1);
trialFFT=zeros(artifactFilteringParams.nfft,size(trialData,2),size(trialData,3));
for(trialIndex=1:size(trialData,3))
    for(channelIndex=1:size(trialData,2))
        trialFFT(:,channelIndex,trialIndex)=fft(trialData(:,channelIndex,trialIndex),artifactFilteringParams.nfft);
    end
end
amplitudeMean=mean(abs(trialData),1);
calibrationArtifactParameters.amplitudeThreshold=mean(amplitudeMean(:))+artifactFilteringParams.standardDeviationCoefficient*std(amplitudeMean(:));

totalRMS=sqrt(sum(trialData.^2)/size(trialData,1));
calibrationArtifactParameters.RMSthreshold=mean(totalRMS(:))+artifactFilteringParams.standardDeviationCoefficient*std(totalRMS(:));

deltaPower = sum(abs(trialFFT(frequencyRange>=0 & frequencyRange<4,:,:)).^2)/artifactFilteringParams.nfft;
thetaPower = sum(abs(trialFFT(frequencyRange>=4 & frequencyRange<8,:,:)).^2)/artifactFilteringParams.nfft;
alphaPower = sum(abs(trialFFT(frequencyRange>=8 & frequencyRange<13,:,:)).^2)/artifactFilteringParams.nfft;
betaPower = sum(abs(trialFFT(frequencyRange>=13 & frequencyRange<30,:,:)).^2)/artifactFilteringParams.nfft;
gammaPower = sum(abs(trialFFT(frequencyRange>=30 & frequencyRange<45,:,:)).^2)/artifactFilteringParams.nfft;

calibrationArtifactParameters.powerDeltaThreshold=mean(deltaPower,3)+artifactFilteringParams.standardDeviationCoefficient*std(deltaPower,0,3);
calibrationArtifactParameters.powerThetaThreshold=mean(thetaPower,3)+artifactFilteringParams.standardDeviationCoefficient*std(deltaPower,0,3);
calibrationArtifactParameters.powerAlphaThreshold=mean(alphaPower,3)+artifactFilteringParams.standardDeviationCoefficient*std(deltaPower,0,3);
calibrationArtifactParameters.powerBetaThreshold=mean(betaPower,3)+artifactFilteringParams.standardDeviationCoefficient*std(deltaPower,0,3);
calibrationArtifactParameters.powerGammaThreshold=mean(gammaPower,3)+artifactFilteringParams.standardDeviationCoefficient*std(deltaPower,0,3);

clear trialFFT
% calib.ampMean=mean(amplitudeMean(:));
% calib.ampVar=std(amplitudeMean(:));
% calib.energyMean=mean(totalRMS(:));
% calib.energyVar=std(totalRMS(:));
% calib.delMean=mean(deltaPower(:));
% calib.delVar=std(deltaPower(:));
% calib.thetMean=mean(thetaPower(:));
% calib.thetVar=std(thetaPower(:));
% calib.alphMean=mean(alphaPower(:));
% calib.alphVar=std(alphaPower(:));
% calib.gammaMean=mean(gammaPower(:));
% calib.gammaVar=std(gammaPower(:));
% calib.betaMean=mean(betaPower(:));
% calib.betaVar=std(betaPower(:));
% save('calib','calib')







