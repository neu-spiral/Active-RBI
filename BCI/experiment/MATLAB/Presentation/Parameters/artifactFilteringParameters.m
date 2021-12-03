%% artifactFilteringParameters
% Parameter file for the artifact filtering.
artifactFilteringParams.standardDeviationCoefficient=4;
artifactFilteringParams.amplitudeThreshold=2.33E-05+artifactFilteringParams.standardDeviationCoefficient*9.46E-06;  % Absolute value for amplitude threshold
artifactFilteringParams.RMSthreshold=1.29E-05+artifactFilteringParams.standardDeviationCoefficient*1.20E-05;    % Absolute value for RMS threshold
artifactFilteringParams.powerDeltaThreshold=4.54E-09+artifactFilteringParams.standardDeviationCoefficient*1.22E-08;    % Absolute value for delta threshold
artifactFilteringParams.powerThetaThreshold=3.76E-09+artifactFilteringParams.standardDeviationCoefficient*6.62E-09;    % Absolute value for theta threshold
artifactFilteringParams.powerAlphaThreshold=2.07E-0+artifactFilteringParams.standardDeviationCoefficient*3.43E-09;    % Absolute value for alpha threshold
artifactFilteringParams.powerBetaThreshold=9.99E-09+artifactFilteringParams.standardDeviationCoefficient*5.14E-08;    % Absolute value for beta threshold
artifactFilteringParams.powerGammaThreshold=7.51E-09+artifactFilteringParams.standardDeviationCoefficient*2.91E-08;    % Absolute value for gamma threshold
artifactFilteringParams.totalRMSlowerBand=1e-6;    % lower band for channels energy for chennel drop
artifactFilteringParams.totalRMSupperBand=200e-6;    % upper band for channels energy for chennel drop
artifactFilteringParams.nfft=256;  % FFT bins for frequency threshold calculations








