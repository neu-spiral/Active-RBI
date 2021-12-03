function [cleanPercentDisp] = artifactRejectionbyFreq(afterFrontendFilterData, fs, artifactRejectionParams) 
%% Noise Parameters: 

    freq=(1:artifactRejectionParams.dataSegmentationLength)*fs/artifactRejectionParams.dataSegmentationLength;

%% Split continuous EEG data into epochs
%   This script does not take into account the start of the RSVP task. 
%   To start segemenation with respect to beginning of task, the correct RSVP trigger decoder will be needed.

    bgEEG = 0;
    [col, row] = size(afterFrontendFilterData);
    endEEG = col; 

    length = (endEEG - bgEEG); 
    numEpochs = floor(length/artifactRejectionParams.dataSegmentationLength); % number of epochs to be inspected 
    lengthDivisable = (numEpochs*artifactRejectionParams.dataSegmentationLength); % length necessary to have perfectly reshapable matrix 
    start = abs(col-lengthDivisable+1);
    EEG = afterFrontendFilterData(start:endEEG, :); % new EEG matrix to allow for segmentable matrix

%% Windowing and Epoching 

    % Calculate a hanning window
    hanning = hann(artifactRejectionParams.dataSegmentationLength, 'symmetric');
    hanning = repmat(hanning,1, artifactRejectionParams.channelNumber);

    % EEG = EEG.*hanning; This is for applying hanning window to whole data set. An alternative to a segemenation approach

    reformatEEG = cell2mat(num2cell(EEG)); 
    ePOCHS = mat2cell(reformatEEG, repmat(artifactRejectionParams.dataSegmentationLength,numEpochs,1), artifactRejectionParams.channelNumber); % creates a new matrix with numEpochs containing segments of determined SegLength, referred to as ePOCHS
    clear bgEEG endEEG start lengthDivisable col  

%% Runs FFT in sequence on the created ePOCHS of length segLength
 
    for i = 1:numEpochs
        windowedEpochs{i} = ePOCHS{i}.*hanning; % apply hanning window
        dataFFT{i} = fft(windowedEpochs{i}, artifactRejectionParams.dataSegmentationLength); % FFT
        dataFFT{i} = mean(dataFFT{i},2);
        power{i} = (abs(dataFFT{i})).^2; % Power
    end 

%% Takes power bands of desired frequencies for Noise Calculation

    disp('Calculating noise...');
    for i = 1:numEpochs
        totalPower{i} = bandpower(power{i},freq, artifactRejectionParams.totalPowerRange, 'psd');  
        noiseBand{i} = bandpower(power{i},freq, artifactRejectionParams.higherPowerRange, 'psd'); 
        gammaBand{i} = bandpower(power{i}, freq, artifactRejectionParams.gammaPowerRange, 'psd');
    end

%% Find Noisy and Clean Epochs

    % Creating empty arrays to append with noisy and clean intervals 
    noise = [];
    clean = [];

    for noiseIndex = 1:numEpochs
        if gammaBand{noiseIndex} > artifactRejectionParams.gammaThreshold
           noise = [noise noiseIndex];
        elseif totalPower{noiseIndex} > artifactRejectionParams.totalPowerThreshold
            noise = [noise noiseIndex];
        elseif noiseBand{noiseIndex} > artifactRejectionParams.higherFrequencyThreshold
            noise = [noise noiseIndex];
        else
           clean = [clean noiseIndex];
        end
    end
    
    % Seperate good and bad arrays
    % cleanArray = power(clean);
    % badArray = power(~clean);

    % Find how many intervals we have left to deal with 
    [startclean, endclean] = size(clean);

    % Display percent of clean data
    cleanEnd = endclean; cleanPercentDisp = num2str(((cleanEnd/i)*100));
    disp([cleanPercentDisp,'% of your data is clean']);
end