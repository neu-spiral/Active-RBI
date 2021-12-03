function [ simulationResults,statistics2display ] = runSimulation( RSVPKeyboardParams )
% conducts a simulation study to estimate the typing performances for different copyphrase scenario. For simulations, EEG scores are sampled and used from the
% conditional kernel density estimators.

%% Outputs
%   simulationResults - structure containing the results of the simulation
%
%             simulationResults.successfullyCompletedFlag - h+2 dimensional tensor containing
%             booleans indicating the successful completion (h is the number of hyperparameters to
%             search over). First dimension is for different Monte Carlo simulations, second
%             dimension is for different phrases, the rest of the dimensions are for the
%             hyperparameters being searched over.
%
%             simulationResults.sequenceCounter - the number of sequences that was shown for each
%             phrase (same dimensionality as simulationResults.successfullyCompletedFlag)
%
%             simulationResults.typingDuration - the estimated duration for each phrase (same dimensionality as simulationResults.successfullyCompletedFlag)
%
%             simulationResults.targetPhraseLength - one dimensional vector containing the length of
%             phrases to be used in simulation.
%
%       statistics2display - the structure containing the information to present in the offlineAnalysisScreen
%
%             statistics2display.probabilityofSuccessfulPhraseCompletion - probability of successful
%             phrase completion for each scenario from the hyperparameters.
%
%             statistics2display.meanTotalTypingDuration - mean total estimated typing duration
%             calculated for each scenario according to hyperparameters.
%
%             statistics2display.meanNumberOfSequencesPerTarget - mean number of sequences per
%             target calculated for each scenario according to hyperparameters.

%%
% Loading required parameters.
addpath(genpath('.'))
if nargin<1
    RSVPKeyboardParameters
end
% Load the imageList.xls file.
imageStructs = xls2Structs('imageList.xls');
simulationResults=simulateTypingPerformance(imageStructs,'CopyPhraseTask',RSVPKeyboardParams);
statistics2display=calculateSimulationResultStatistics(simulationResults);

if RSVPKeyboardParams.Simulation.ExportToExcel.Enabled
    
    if isempty(RSVPKeyboardParams.Simulation.ExportToExcel.Filename)
        excelFileName = [fileDirectory 'simulationResults' datestr(now, 'yyyymmddHHMM') '.xls'];
    elseif isempty(RSVPKeyboardParams.Simulation.ExportToExcel.Folder)
        excelFileName = [fileDirectory RSVPKeyboardParams.Simulation.ExportToExcel.Filename];
    else
        excelFileName = [RSVPKeyboardParams.Simulation.ExportToExcel.Folder '\' RSVPKeyboardParams.Simulation.ExportToExcel.Filename];
    end
    
    status = exportToExcel(excelFileName , ...
        RSVPKeyboardParams.Simulation.HyperparameterNames, ...
        RSVPKeyboardParams.Simulation.HyperparameterValues, statistics2display);
    
    if ~status
        error('Failed to write Excel sheet');
    end
end
end

