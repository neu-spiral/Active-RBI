% //  Parameters for Drowsiness Detection
% // EEG Parameters
drowsinessDetectionParams.segmentationLength = 4000;
drowsinessDetectionParams.channelNumber = 4;

% // Eye Blink and Drowsiness Percent Level Thresholds
drowsinessDetectionParams.levelOnehighThreshold = .449999999;
drowsinessDetectionParams.levelOnelowThreshold = .3;

drowsinessDetectionParams.levelTwohighThreshold = .5999999999;
drowsinessDetectionParams.levelTwolowThreshold = .45;

drowsinessDetectionParams.levelThreehighThreshold = .6;
drowsinessDetectionParams.levelThreelowThreshold = .749999999;

drowsinessDetectionParams.levelFourhighThreshold = 1;
drowsinessDetectionParams.levelFourlowThreshold = .75;

% // Eye Blink Parameters
drowsinessDetectionParams.countRateCalculation = 10;
drowsinessDetectionParams.minPeakHeight = .00004;
drowsinessDetectionParams.minPeakDistance = 100;

% // Freq Ranges:

% // Noise
drowsinessDetectionParams.totalPowerFreqRange = [.1 50];
drowsinessDetectionParams.sixtyCyBandFreqRange = [51 69.75];
drowsinessDetectionParams.gammaLowBandFreqRange = [30 50.75];
drowsinessDetectionParams.gammaHighBandFreqRange = [70 90.75];
drowsinessDetectionParams.noiseBandFreqRange = [91 128]; 
drowsinessDetectionParams.noiseThreshold = 5E-06;
drowsinessDetectionParams.percentCleanDataCutoff = 70; 

% // Drowsiness 
drowsinessDetectionParams.deltaBandFreqRange = [.1 3.75];
drowsinessDetectionParams.thetaBandFreqRange = [4 7.75]; 
drowsinessDetectionParams.alphaBandFreqRange = [8 12.75];
drowsinessDetectionParams.beta1BandFreqRange = [13 17.75];
drowsinessDetectionParams.beta2BandFreqRange = [18 29.75]; 

% // Drowsiness change parameters
drowsinessDetectionParams.significantAlphaChangePercent = .15;
drowsinessDetectionParams.significantThetaChangePercent = .15;

% // Drowsiness alert parameters
drowsinessDetectionParams.alertThreshold = 2
