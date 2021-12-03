%% Artifact Rejection Parameters

% Artifact Rejection by Freq Parameters
artifactRejectionParams.gammaThreshold = 5E-06;
artifactRejectionParams.higherFrequencyThreshold = 5E-07; 
artifactRejectionParams.totalPowerThreshold = 5.5E-05; 
artifactRejectionParams.dataSegmentationLength = 4000;
artifactRejectionParams.channelNumber = 16;
artifactRejectionParams.totalPowerRange = [.1 128];
artifactRejectionParams.gammaPowerRange = [30 50.75];
artifactRejectionParams.higherPowerRange = [30 128];

% Artifact Rejection by Voltage Parameters
artifactRejectionParams.rawVoltageThreshold = -(1E-7);
artifactRejectionParams.rawDataSegmentationLength = 500;

