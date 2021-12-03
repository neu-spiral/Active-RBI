function [cleanPercentDisp] = artifactRejectionbyVoltage(afterFrontendFilterData, artifactRejectionParams) 

    %% Split continuous EEG data into epochs
    %   This script does not take into account the start of the RSVP task. 
    %   To start segemenation with respect to beginning of task, the correct RSVP trigger decoder will be needed.

    bgEEG = 0; % consider latency of 10-15 seconds or make this changeable
    [col, row] = size(afterFrontendFilterData);
    endEEG = col; 

    length = (endEEG - bgEEG); 
    numEpochs = floor(length/artifactRejectionParams.rawDataSegmentationLength); % number of epochs to be inspected 
    lengthDivisable = (numEpochs*artifactRejectionParams.rawDataSegmentationLength); % length necessary to have perfectly reshapable matrix 
    start = abs(col-lengthDivisable+1);
    EEG = afterFrontendFilterData(start:endEEG, :);

    %% Windowing and Epoching

    reformatEEG = cell2mat(num2cell(EEG)); 
    ePOCHS = mat2cell(reformatEEG, repmat(artifactRejectionParams.rawDataSegmentationLength,numEpochs,1), channelNumber); % creates a new matrix with numEpochs containing segments of determined SegLength, referred to as ePOCHS
    clear bgEEG endEEG start lengthDivisable col  

    %% Find Noisy and Clean Epochs

    % Creating empty arrays to append with noisy and clean intervals 
    noise = [];
    clean = [];

    for noiseIndex = 1:numEpochs
        averagedChannelPerEpoch = mean(ePOCHS{noiseIndex}, 1);
        if averagedChannelPerEpoch > artifactRejectionParams.rawVoltageThreshold
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
    cleanEnd = endclean; cleanPercentDisp = num2str(((cleanEnd/noiseIndex)*100));
    disp([cleanPercentDisp,'% of your data is clean']);

end
