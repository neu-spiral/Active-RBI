function [activeFlag, nextSequence] = decideNextTrialsERP(fullSet,priorProbs, posteriorHistory, sequenceType, params, enforceFlag)
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
            
            case '1'
                nextSequence.trials = fullSet(randperm(length(fullSet),params.Typing.NumberofTrials));
                
            case '2'
                params.Typing.querying.lamChangeFlag = 0;
                params.Typing.querying.lam = 0;
                nextSequence.trials = ActiveQuerying(fullSet, priorProbs, posteriorHistory, params);
                
            case '3'
                params.Typing.querying.lamChangeFlag = 0;
                params.Typing.querying.lam = 1;
                nextSequence.trials = ActiveQuerying(fullSet, priorProbs, posteriorHistory, params);
                
            case '4'
                 nextSequence.trials = ActiveQuerying(fullSet, priorProbs, posteriorHistory, params);
                 
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

