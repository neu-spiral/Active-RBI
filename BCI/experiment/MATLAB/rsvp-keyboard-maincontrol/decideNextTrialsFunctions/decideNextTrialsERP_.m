function [activeFlag,nextSequence ] = decideNextTrialsERP(fullSet,priorProbs,sequenceType,params,enforceFlag)
% Decide on the next sequence ERP to present or empty sequence (if not ERP
% sequence is going to be presented)
         % 
        % Inputs: 
        %       fullSet - All the vocabulary used
        %       priorProbs- Prior Probabilities for each element of the
        %       vocabulary
        %       sequence Type- Type of evidence
        %       params- Additional parameters. 
        %       enforceFlag- Enforce to show a next ERP sequence no matter the
        %       conditions to be shown. 
        % Output:
        %       nextSequence - a structure containing the information on
        %       the next sequence.
        %
        %           nextSequence.trials - the ordered list of trial indices
        %           (vector)
        %
        %           nextSequence.target - the index corresponding to the
        %           target symbol
        %           
        %           activeFlag - boolean indicating if a next sequence ERP
        %           is going to be shown or not. 
        %
activeFlag=0;
nextSequence=[];
sequenceCount=sum(sequenceType==params.typeID);

if sequenceCount<params.Typing.MaximumNumberofSequences || enforceFlag==1
    if(params.sessionID~=1)
        if params.isCalibration && isfield(params,'targetID')
            nextSequence.target=params.targetID;
        end
        switch params.Typing.nextSequenceDecisionRule
            case 'Random'
                nextSequence.trials=fullSet(randperm(length(fullSet),params.Typing.NumberofTrials));
            case 'Posterior'
                [~,sortedTrialIndices]=sort(priorProbs,'descend');
                selectedSet=fullSet(sortedTrialIndices(1:params.Typing.NumberofTrials));
                nextSequence.trials=selectedSet(randperm(length(selectedSet)));
        end
        
        if(params.matrixSpellerMode)
            nextSequence.trials=matrixSequenceGenerator(nextSequence.trials,params.matrixPresentationParadigm,params.matrixSize,params.symbolStructArray);
        end
        if ~isempty(nextSequence.trials)
            activeFlag=1;
        end
    else
        nextSequence.trials=fullSet(randperm(length(fullSet),params.Typing.NumberofTrials));
        nextSequence.target= nextSequence.trials(randperm(length( nextSequence.trials),1));
        
        if(params.matrixSpellerMode)
            nextSequence.trials=matrixSequenceGenerator( nextSequence.trials,params.matrixPresentationParadigm,params.matrixSize,params.symbolStructArray);
        end
        if ~isempty( nextSequence.trials)
            activeFlag=1;
        end
    end
else
    %Nothing...
end








end

