function [eyeBlinkDrowsinessScore, cleanPercentDisp, freqDrowsinessScore, drowsinessScore] = drowsinessDetection(afterFrontendFilterData, afterFrontendFilterTrigger, drowsinessDetectionParams, channelNames, triggerPartitioner, fs, fileDirectory)
 
%% Drowsiness Detection: function [eyeBlinkDrowsinessScore, cleanPercentDisp, freqDrowsinessScore, drowsinessScore] = drowsinessDetection(afterFrontendFilterData, afterFrontendFilterTrigger, drowsinessDetectionParams, channelNames, triggerPartitioner, fs, fileDirectory)


% Decode trigger
if exist('matrixSequences','var')
    [~,completedSequenceCount,trialSampleTimeIndices,trialTargetness,trialLabels]=triggerDecoder(afterFrontendFilterTrigger,triggerPartitioner,matrixSequences);
else
    [~,completedSequenceCount,trialSampleTimeIndices,trialTargetness,trialLabels]=triggerDecoder(afterFrontendFilterTrigger,triggerPartitioner);
end

% Optional 30Hz filter 
% fc=30;% cut off frequency
% fn=fs/2; %nyquivst frequency = sample frequency/2;
% order = 2; %2nd order filter, low
% [b14, a14]=butter(order,(fc/fn),'low');

% Define beginning (bg) and end of loaded EEG file
bgEEG = trialSampleTimeIndices(1); % start when trail begins
[col, row] = size(afterFrontendFilterData);
endEEG = col; 

% Split continuous EEG data into epochs
EEGlength = (endEEG - bgEEG); 
numEpochs = floor(EEGlength/drowsinessDetectionParams.segmentationLength); % number of epochs to be scored 
lengthDivisable = (numEpochs*drowsinessDetectionParams.segmentationLength); % lengh necessary to have perfectly reshapable matrix 
start = abs(col-lengthDivisable+1);
EEG = afterFrontendFilterData(start:endEEG, :); % new EEG matrix to allow for segmentable matrix

disp(' . ');

%% Eye Blink Calculations

% Find if channels Fp1 and Fp2 exist and their index from channelNames. 
for channelsIndex = 1:length(channelNames)
    channel = sprintf(channelNames{channelsIndex});
    
    Fp1 = 'Fp1';
    Fp2 = 'Fp2';
    
    if strcmp(channel,Fp1)
        fp1 = channelsIndex;
    elseif strcmp(channel,Fp2)
        fp2 = channelsIndex;
    end
    
end

% Check if channels needed for eye-blink calculation are present
if exist('fp1', 'var') && exist('fp2', 'var')
else 
    disp('Channels needed for eye-blink calculation not found')
    return
end

Fp1 = EEG(:,fp1);
Fp2 = EEG(:,fp2); 

% Average to avoid false positives due to noise
averageFps = (Fp1 + Fp2)/2;

% Inversing makes it easier to find peaks associated with blinks 
averageFps = (-averageFps);

% Find the eye blink. Min peak distance and height defined here -- 
[blinksAverage, locationAverage] = findpeaks(averageFps, 'MinPeakDistance', drowsinessDetectionParams.minPeakDistance, 'MinPeakHeight', drowsinessDetectionParams.minPeakHeight);
[sizeLocation, vv] = size(locationAverage); 

% Calculate initial blink rate using drowsinessDetectionParams.countRateCalculation # of blinks, and
% overall blink rate using the length of time elapsed and the number of blinks
for blink = 1:(sizeLocation - drowsinessDetectionParams.countRateCalculation)
    if locationAverage(blink) > bgEEG
        startLocation = blink;
        break
    end
end

if exist('startLocation', 'var')
    active = 1;
else
    startLocation = bgEEG; 
end 

blinkRateInitial = drowsinessDetectionParams.countRateCalculation / (locationAverage(startLocation + drowsinessDetectionParams.countRateCalculation) - locationAverage(startLocation)); 
blinkReducationIntervals = [];

for bli = 1:(sizeLocation-drowsinessDetectionParams.countRateCalculation)
    newBlinkRate = drowsinessDetectionParams.countRateCalculation / (locationAverage(bli + drowsinessDetectionParams.countRateCalculation) - locationAverage(bli));
    bli = bli + drowsinessDetectionParams.countRateCalculation;
    if newBlinkRate < blinkRateInitial
        blinkReducationIntervals = [blinkReducationIntervals bli];
    end
end

% To avoid just random error in blink detection, levels of drowsiness are used based on the percent of time blink reduction is seen in the file
[rows, blinkLength] = size(blinkReducationIntervals);

if blinkLength/bli >= drowsinessDetectionParams.levelOnelowThreshold && blinkLength/bli <= drowsinessDetectionParams.levelOnehighThreshold
    eyeBlinkDrowsinessScore = 1; 
elseif blinkLength/bli >= drowsinessDetectionParams.levelTwolowThreshold && blinkLength/bli <= drowsinessDetectionParams.levelTwohighThreshold
    eyeBlinkDrowsinessScore = 2; 
elseif blinkLength/bli >= drowsinessDetectionParams.levelThreelowThreshold && blinkLength/bli <= drowsinessDetectionParams.levelThreehighThreshold
    eyeBlinkDrowsinessScore = 3; 
elseif blinkLength/bli >= drowsinessDetectionParams.levelFourlowThreshold && blinkLength/bli <= drowsinessDetectionParams.levelFourhighThreshold
    eyeBlinkDrowsinessScore = 4;
else     
    eyeBlinkDrowsinessScore = 0; 
end 

disp(' .. ');

%% Windowing and Epoching 

% Find if channels Cz, Fz, P1, and P2 exist and their index from channelNames. 
for channelsIndex = 1:length(channelNames)
    channel = sprintf(channelNames{channelsIndex});
    
    Cz = 'Cz';
    Fz = 'Fz';
    P1 = 'P1';
    P2 = 'P2';
    
    if strcmp(channel, Cz)
        cz = channelsIndex;
    elseif strcmp(channel, Fz)
        fz = channelsIndex;
    elseif strcmp(channel, P1)
        p1 = channelsIndex;
    elseif strcmp(channel, P2)
        p2 = channelsIndex;
    end
    
end

% Check if channels needed for drowsiness calculation are present
if exist('cz', 'var') == 1 && exist('fz', 'var') == 1 && exist('p1', 'var') == 1 && exist('p2', 'var') == 1
else 
    disp('Channels needed for drowsiness calculation not found')
    return
end

EEG = EEG(:,[fz, cz, p1, p2]); %NOTE: if changing this, must change channel number Fz, Cz, P1, P2 

% Calculate a hanning window
hanning = hann(drowsinessDetectionParams.segmentationLength, 'symmetric');
hanning = repmat(hanning, 1, drowsinessDetectionParams.channelNumber);

% EEG = EEG.*hanning; This is for applying hanning to whole data set

reformatEEG = cell2mat(num2cell(EEG)); ePOCHS = mat2cell(reformatEEG, repmat(drowsinessDetectionParams.segmentationLength, numEpochs, 1), drowsinessDetectionParams.channelNumber); % creates a new matrix with numEpochs containing segments of determined drowsinessDetectionParams.SegmentationLength, referred to as ePOCHS
clear endEEG start lengthDivisable col  % deletes unnecessary files in workspace 


%% For plotting

N=drowsinessDetectionParams.segmentationLength; freq=(1:N)*fs/N; 

%% Runs FFT in sequence on the created ePOCHS of length drowsinessDetectionParams.segmentationLength
 
numEpochs = floor(EEGlength/drowsinessDetectionParams.segmentationLength);

for i = 1:numEpochs
    windowedEpochs{i} = ePOCHS{i}.*hanning;
    dataFFT{i} = fft(windowedEpochs{i}, drowsinessDetectionParams.segmentationLength); 
    dataFFT{i} = mean(dataFFT{i},2);
    power{i} = (abs(dataFFT{i})).^2;
end 

disp(' ... ');

%% Takes bands of defined frequencies for Noise Calculation

for i = 1:numEpochs
        totalPower{i} = bandpower(power{i},freq, drowsinessDetectionParams.totalPowerFreqRange, 'psd');  
        sixtyCyBand{i} = bandpower(power{i},freq, drowsinessDetectionParams.sixtyCyBandFreqRange, 'psd'); 
        gammaLowBand{i} = bandpower(power{i}, freq, drowsinessDetectionParams.gammaLowBandFreqRange, 'psd');
        gammaHighBand{i} = bandpower(power{i},freq, drowsinessDetectionParams.gammaHighBandFreqRange, 'psd'); 
        noiseBand{i} = bandpower(power{i},freq, drowsinessDetectionParams.noiseBandFreqRange, 'psd');
end

%% Find Noisy and Clean Epochs

% Creating empty arrays to append with noisy and clean intervals 
noise = [];
clean = [];

for noiseIndex = 1:numEpochs
    if gammaLowBand{noiseIndex} > (drowsinessDetectionParams.noiseThreshold)
       noise = [noise noiseIndex];
    elseif gammaHighBand{noiseIndex} > (drowsinessDetectionParams.noiseThreshold)
       noise = [noise noiseIndex];
    elseif noiseBand{noiseIndex} > (drowsinessDetectionParams.noiseThreshold)
        noise = [noise noiseIndex];
    elseif sixtyCyBand{noiseIndex} > (drowsinessDetectionParams.noiseThreshold)
        noise = [noise noiseIndex];
    else
       clean = [clean noiseIndex];
    end
end

% Find how many intervals we have left to deal with 
cleanArray = power(clean);
badArray = power(~clean);
[startclean, endclean] = size(clean);

% Display percent of clean data
cleanEnd = endclean; cleanPercentDisp = ((cleanEnd/i)*100);
% fprintf('Clean Data Percent: %s \n', num2str(cleanPercentDisp));

% If enough data is clean, continue script and display message
if cleanPercentDisp < drowsinessDetectionParams.percentCleanDataCutoff
    disp('*** Noise Too High ***')
    return
elseif cleanPercentDisp > drowsinessDetectionParams.percentCleanDataCutoff
    disp('*** Drowsiness Calculations ***')
end

%% Loop through the clean intervals and determine alertness/ drowsiness

for r = 1:endclean
    totalPower{r} = bandpower(cleanArray{r},freq, drowsinessDetectionParams.totalPowerFreqRange, 'psd');
    deltaBand{r} = bandpower(cleanArray{r},freq, drowsinessDetectionParams.deltaBandFreqRange, 'psd');
    thetaBand{r} = bandpower(cleanArray{r},freq, drowsinessDetectionParams.thetaBandFreqRange, 'psd'); 
    alphaBand{r} = bandpower(cleanArray{r},freq, drowsinessDetectionParams.alphaBandFreqRange, 'psd');
    beta1Band{r} = bandpower(cleanArray{r},freq, drowsinessDetectionParams.beta1BandFreqRange, 'psd'); 
    beta2Band{r} = bandpower(cleanArray{r},freq, drowsinessDetectionParams.beta2BandFreqRange, 'psd');   
end

startingTheta = thetaBand{1} + (thetaBand{1} * drowsinessDetectionParams.significantThetaChangePercent); % looks for a 15% increase in theta
startingAlpha = alphaBand{1} - (alphaBand{1} * drowsinessDetectionParams.significantAlphaChangePercent); % looks for a 15% decrease in alpha


significantChangeinState1 = [];
significantChangeinState2 = [];

for drowsyTest = 1:endclean
    if startingTheta < thetaBand{drowsyTest} && startingAlpha < alphaBand{drowsyTest}
        significantChangeinState1 = [significantChangeinState1 drowsyTest];
    elseif startingAlpha < alphaBand{drowsyTest}
        significantChangeinState2 = [significantChangeinState2 drowsyTest];
    end 
end

[rows, stateChange] = size(significantChangeinState1);
[rows, stateChange2] = size(significantChangeinState2);

stateChange = stateChange + stateChange2; 

if stateChange/cleanEnd >= drowsinessDetectionParams.levelOnelowThreshold && stateChange/cleanEnd <= drowsinessDetectionParams.levelOnehighThreshold
    freqDrowsinessScore = 1; 
elseif stateChange/cleanEnd >= drowsinessDetectionParams.levelTwolowThreshold && stateChange/cleanEnd <= drowsinessDetectionParams.levelTwohighThreshold
    freqDrowsinessScore = 2; 
elseif stateChange/cleanEnd >= drowsinessDetectionParams.levelThreelowThreshold && stateChange/cleanEnd <= drowsinessDetectionParams.levelThreehighThreshold
    freqDrowsinessScore = 3; 
elseif stateChange/cleanEnd >= drowsinessDetectionParams.levelFourlowThreshold && stateChange/cleanEnd <= drowsinessDetectionParams.levelFourhighThreshold
    freqDrowsinessScore = 4;
else     
    freqDrowsinessScore = 0; 
end 


% [[% TO-DO %]] Look for the anteriorization of alpha (Occiptal) ---> (Central and
% Frontal) and at median power frequency 

%% Calculate Drowsiness Score

% average score for normal user
drowsinessScore = num2str((eyeBlinkDrowsinessScore + freqDrowsinessScore)/2); 

fprintf('Drowsiness Score: %s \n', drowsinessScore);
fprintf('Frequency Score: %d \n', freqDrowsinessScore);
fprintf('Eye Blink Rate Score: %x \n', eyeBlinkDrowsinessScore);

end

% [[% TO-DO %]] weight scores differently depending on different user
% arch at start