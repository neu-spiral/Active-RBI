%% simulationResults=simulateTypingPerformance(scoreStruct,imageStructs,sessionType,RSVPKeyboardParams)
% Applies simulation of the copy task to estimate the typing performance. It uses the scores
% obtained after cross validation and their KDEs to sample new score samples for simulation. In
% principle a copy phrase task is performed using the random sampling of scores replacing the EEG
% trials.
%
%   Inputs:
%       scoreStruct - structure containing the KDE objects to be used in the estimation of conditional
%       probability densities and probability thresholds for the scores.
%
%           scoreStruct.conditionalpdf4targetKDE - kde1d object constructed using the scores
%           corresponding to the target symbols
%
%           scoreStruct.conditionalpdf4nontargetKDE - kde1d object constructed using the scores
%           corresponding to the target symbols
%
%           scoreStruct.probThresholdTarget - probability threshold on target KDE to reject a trial as an outlier
%
%           scoreStruct.probThresholdNontarget - probability threshold on nontarget KDE to reject a trial as an outlier
%
%       symbolStructArray - a struct vector containing list of symbols or images used in
%       presentations. Loaded using xls2Structs function called on imageList.xls.
%
%       RSVPKeyboardParams - RSVPKeyboard parameters from the parameter file RSVPKeyboardParameters.m.
%
%   Outputs:
%
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
%%

function simulationResults=simulateTypingPerformance(imageStructs,sessionType,RSVPKeyboardParams,presentationStruct)
%presentationParameters
if(~exist('RSVPKeyboardParams','var') || isempty(RSVPKeyboardParams))
    RSVPKeyboardParameters
end
if(~exist('presentationStruct','var') || isempty(presentationStruct))
    presentationParameters
end
%%%%%%%%%set sessionID%%%%%%%%%%%%%%%%%%%
sessionIDListFilename='sessionIDList.txt';

sessionIDList=zeros(5,1);
sessionIDListfid=fopen(sessionIDListFilename,'r');

sessionID=fscanf(sessionIDListfid,'%d,');
sessionIDCounter=1;

while ~isempty(sessionID)
    sessionIDList(sessionIDCounter)=sessionID;
    sessionName=fscanf(sessionIDListfid,'%s,');
    sessionNameList{sessionIDCounter}=sessionName(1:end-1);
    %fprintf('[%d]: %s\n',sessionIDCounter,sessionNameList{sessionIDCounter});
    sessionID=fscanf(sessionIDListfid,'%d,');
    sessionIDCounter=sessionIDCounter+1;    
end

fclose(sessionIDListfid);

if strcmp(sessionType,'CopyPhraseTask') 
    sessionID=sessionIDList(strcmp(sessionNameList,'CopyPhrase'));
else
    sessionID=sessionIDList(strcmp(sessionNameList,sessionType));
    
end
%sessionName=sessionNameList{sessionIndex};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
initializeEvidenceEvaluators

[simulationGridSearchParameters{1:length(RSVPKeyboardParams.Simulation.HyperparameterValues)}]=ndgrid(RSVPKeyboardParams.Simulation.HyperparameterValues{1:length(RSVPKeyboardParams.Simulation.HyperparameterValues)});

simulationGridSearchParameters = reshape(cat(length(simulationGridSearchParameters)+1,simulationGridSearchParameters{:}),numel(simulationGridSearchParameters{1}),length(RSVPKeyboardParams.Simulation.HyperparameterValues));

simulationGridSearchParameterIndices=zeros(size(simulationGridSearchParameters));
for(hyperparameterIndex=1:size(simulationGridSearchParameters,2))
    [~,simulationGridSearchParameterIndices(:,hyperparameterIndex)]=ismember(simulationGridSearchParameters(:,hyperparameterIndex),RSVPKeyboardParams.Simulation.HyperparameterValues{hyperparameterIndex});
end

% Compute text formatting string
nHyperParameters = numel(RSVPKeyboardParams.Simulation.HyperparameterNames);
textSize = cellfun(@numel, RSVPKeyboardParams.Simulation.HyperparameterNames);

% Convert sizes to an array to put them in format string
textSize = mat2cell(num2str(textSize'),ones(1,length(textSize)));
textFormatString = ['| %10.2f %% |' cell2mat(strcat('| %-', textSize, 'd |')')];

firstIterationBool=true;
for(repetition=1:RSVPKeyboardParams.Simulation.MonteCarloRepetitionCount)
    tic;
    
    % Print hyperparameter name table and delimeter
    disp(['Simulation ' num2str(repetition) ' starting:']);
    fprintf(['| Percent done |' repmat('| %s |', 1, nHyperParameters) '\n'], RSVPKeyboardParams.Simulation.HyperparameterNames{:});
    
    for(simulationIndex=1:size(simulationGridSearchParameters,1))
        for(hyperparameterIndex=1:size(simulationGridSearchParameters,2))
            eval(['RSVPKeyboardParams.' RSVPKeyboardParams.Simulation.HyperparameterNames{hyperparameterIndex} '=' num2str(simulationGridSearchParameters(simulationIndex,hyperparameterIndex)) ';']);
        end
        %!!!Updated--------------------------------------------------------------
        RSVPKeyboardTaskObject=feval(sessionType,imageStructs,RSVPKeyboardParams,1);
        
        imageStructIDList=[imageStructs.ID];
        deleteCharacterID=imageStructIDList(strcmp({imageStructs.Name},'DeleteCharacter'));
        for evidenceIndex=1:length(RSVPKeyboardParams.evidenceEval.evidences)
            results.(RSVPKeyboardParams.evidenceEval.evidences{evidenceIndex}).decideNextFlag=1;
            results.(RSVPKeyboardParams.evidenceEval.evidences{evidenceIndex}).trialLabels=[];
            results.(RSVPKeyboardParams.evidenceEval.evidences{evidenceIndex}).completedSequenceCount=0;
            results.(RSVPKeyboardParams.evidenceEval.evidences{evidenceIndex}).duration=0;
        end
        [~,decision]=decisionMaker(results,RSVPKeyboardTaskObject);
        
        continueMainLoop=true;
        while continueMainLoop
            
            if(isempty(RSVPKeyboardTaskObject.currentInfo.phrase.incorrectSection))
                targetSymbol=imageStructIDList(strcmp({imageStructs.Text},RSVPKeyboardTaskObject.currentInfo.phrase.target(length(RSVPKeyboardTaskObject.currentInfo.phrase.correctSection)+1)));
                
            else %Backspace
                targetSymbol=deleteCharacterID;
            end
            if strcmp(decision.nextSequence.Type, 'ERP') && RSVPKeyboardParams.matrixSpellerMode
            
                resultTargetness=[];
                %%%%%%%%%%%%%%%%%%%%%% MatrixFormat %%%%%%%%%%%%%%%%%%%%%%%%%%
                            tmpSequence=decision.nextSequence.trials;
                            for j=1:length(tmpSequence)
                                trialLabels{j}=imageStructIDList(find(str2num(tmpSequence{j}(:))));
                                tmp=find(trialLabels{j}==targetSymbol);
                                if sum(tmp)>0
                                    resultTargetness(j)=true;
                                else
                                    resultTargetness(j)=false;
                                end
                            end
                            
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
            else
%                 decision.nextSequence.trials
%                 targetSymbol
                resultTargetness=decision.nextSequence.trials==targetSymbol;
            end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             evidenceIndex=find(strcmp(RSVPKeyboardParams.evidenceEval.evidences,decision.nextSequence.Type));
             
             
            if  evidenceIndex>0 && (RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.params{evidenceIndex}.scoreStruct.trialRejectionProbability>0)
                acceptedTrials=rand(length(resultTargetness),1)>=RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.params{evidenceIndex}.scoreStruct.trialRejectionProbability;
            elseif evidenceIndex>0
                acceptedTrials=true(length(resultTargetness),1);
            end
            switch decision.nextSequence.Type
                case 'ERP'
                    if  RSVPKeyboardParams.matrixSpellerMode
                        results.(decision.nextSequence.Type).duration=length(resultTargetness)*presentationStruct.Duration.ERPMatrixTrial+presentationStruct.Duration.Fixation;
                    else
                        results.(decision.nextSequence.Type).duration=length(resultTargetness)*presentationStruct.Duration.ERPTrial+presentationStruct.Duration.Fixation;
                    end
                case 'FRP'
                    results.(decision.nextSequence.Type).duration=length(resultTargetness)*presentationStruct.Duration.FRPTrial+presentationStruct.Duration.SequenceBegin;
            end
            

            resultTargetness=resultTargetness(acceptedTrials);
            targetCount=sum(resultTargetness);
            if strcmp(decision.nextSequence.Type, 'ERP') && RSVPKeyboardParams.matrixSpellerMode
                results.(decision.nextSequence.Type).trialLabels=trialLabels(acceptedTrials);
            else
                results.(decision.nextSequence.Type).trialLabels=decision.nextSequence.trials(acceptedTrials);
            end
            results.(decision.nextSequence.Type).scores=zeros(length(resultTargetness),1);
            results.(decision.nextSequence.Type).scores(find(resultTargetness))=RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.params{evidenceIndex}.scoreStruct.conditionalpdf4targetKDE.getSample(targetCount);
            results.(decision.nextSequence.Type).scores(find(~resultTargetness))=RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.params{evidenceIndex}.scoreStruct.conditionalpdf4nontargetKDE.getSample(length(resultTargetness)-targetCount);
            results.(decision.nextSequence.Type).completedSequenceCount=1;
            
            [continueMainLoop,decision]=decisionMaker(results,RSVPKeyboardTaskObject);
        end
        
        sessionInfo = RSVPKeyboardTaskObject.saveTaskHistory();
        
        if(firstIterationBool)
            simulationResults.successfullyCompletedFlag=zeros([RSVPKeyboardParams.Simulation.MonteCarloRepetitionCount,length(sessionInfo.taskHistory),cellfun(@length,RSVPKeyboardParams.Simulation.HyperparameterValues)]);
            simulationResults.sequenceCounter=simulationResults.successfullyCompletedFlag;
            simulationResults.typingDuration=simulationResults.successfullyCompletedFlag;
            for evidenceIndex=1:length(RSVPKeyboardParams.evidenceEval.evidences)
                simulationResults.(RSVPKeyboardParams.evidenceEval.evidences{evidenceIndex}).sequenceCounter=simulationResults.successfullyCompletedFlag;
                simulationResults.(RSVPKeyboardParams.evidenceEval.evidences{evidenceIndex}).typingDuration=simulationResults.successfullyCompletedFlag;
            end
            simulationResults.targetPhraseLength=zeros(length(sessionInfo.taskHistory),1);
            for(phraseIndex=1:length(sessionInfo.taskHistory))
                simulationResults.targetPhraseLength(phraseIndex)=length(sessionInfo.taskHistory{phraseIndex}.target);
            end
            firstIterationBool=false;
        end
        
        for(phraseIndex=1:length(sessionInfo.taskHistory))
            resultLocation=num2cell([repetition,phraseIndex,simulationGridSearchParameterIndices(simulationIndex,:)]);
            simulationResults.successfullyCompletedFlag(resultLocation{:})=sessionInfo.taskHistory{phraseIndex}.successfullyCompletedFlag;
            simulationResults.sequenceCounter(resultLocation{:})=sessionInfo.taskHistory{phraseIndex}.sequenceCounter;
            simulationResults.typingDuration(resultLocation{:})=sessionInfo.taskHistory{phraseIndex}.typingDuration;
            for evidenceIndex=1:length(RSVPKeyboardParams.evidenceEval.evidences)
                simulationResults.(RSVPKeyboardParams.evidenceEval.evidences{evidenceIndex}).sequenceCounter(resultLocation{:})=sessionInfo.taskHistory{phraseIndex}.(RSVPKeyboardParams.evidenceEval.evidences{evidenceIndex}).globalSequenceCounter;
                simulationResults.(RSVPKeyboardParams.evidenceEval.evidences{evidenceIndex}).typingDuration(resultLocation{:})=sessionInfo.taskHistory{phraseIndex}.(RSVPKeyboardParams.evidenceEval.evidences{evidenceIndex}).typingDuration;
            end
            
        end
        
        % Compute percent done
        deltaPercent = 100*(simulationIndex)/size(simulationGridSearchParameters,1);
        
        % Print hyperparameter values
        fprintf([textFormatString '\n'], [deltaPercent simulationGridSearchParameters(simulationIndex,:)]);
    end
    disp(['Simulation ' num2str(repetition) '/' num2str(RSVPKeyboardParams.Simulation.MonteCarloRepetitionCount) ' completed in ' num2str(toc) ' seconds.']);
end
end