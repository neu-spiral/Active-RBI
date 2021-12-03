%% statistics2display=calculateSimulationResultStatistics(simulationResults)
% calculateSimulationResultStatistics calculates the simulation statistics to be shown in the screen
% which is shown after the offline analysis. It prepares a more compact summary of simulations.
%
%   Input:
%       simulationResults - structure containing the results of the simulation
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
%   Output: 
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
%
%%

function statistics2display=calculateSimulationResultStatistics(simulationResults)
    s=size(simulationResults.sequenceCounter); 

    statistics2display.probabilityofSuccessfulPhraseCompletion=squeeze(sum(sum(simulationResults.successfullyCompletedFlag,1),2))/(size(simulationResults.successfullyCompletedFlag,1)*size(simulationResults.successfullyCompletedFlag,2));
    statistics2display.meanTotalTypingDuration=squeeze(mean(sum(simulationResults.typingDuration,2),1));
    statistics2display.stdTotalTypingDuration=squeeze(std(sum(simulationResults.typingDuration,2),0,1));
    
    s1=s;
    s2=ones(size(s));
    s1(2)=1;
    s2(2)=s(2);
    temp=sum(simulationResults.sequenceCounter./repmat(reshape(simulationResults.targetPhraseLength,s2),s1),2)/size(simulationResults.sequenceCounter,2);
    statistics2display.meanNumberOfSequencesPerTarget=squeeze(mean(temp,1));
    statistics2display.stdNumberOfSequencesPerTarget=squeeze(std(temp,0,1));
    statistics2display.NumberOfSequencesPerTatget=temp;
end