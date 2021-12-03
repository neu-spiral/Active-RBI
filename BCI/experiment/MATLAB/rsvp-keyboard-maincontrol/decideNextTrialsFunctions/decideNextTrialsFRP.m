function [activeFlag,nextSequence] = decideNextTrialsFRP(fullSet,priorProbs,sequenceType,params,enforceFlag)
% Decide on the next sequence ERP to present or empty sequence (if not FRP
% sequence is going to be presented) 
        % 
        % Inputs: 
        %       fullSet - All the vocabulary used
        %       priorProbs- Prior Probabilities for each element of the
        %       vocabulary
        %       sequence Type- Type of evidence
        %       params- Additional parameters. 
        %       enforceFlag- Enforce to show a next FRP sequence no matter the
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
lastIndex=find(sequenceType==params.typeID,1,'last');
if isempty(lastIndex)
    lastIndex=1;
end
decideTrials=1;
enforce=0;
for evidenceIndex=1:length(params.Typing.minMaxRequiredSequenceCount)
    tmpSequenceCount=sum(sequenceType(lastIndex:end)==evidenceIndex);
    decideTrials=decideTrials && (tmpSequenceCount >= params.Typing.minMaxRequiredSequenceCount{evidenceIndex}(1));
    enforce=enforce ||   (tmpSequenceCount >=  params.Typing.minMaxRequiredSequenceCount{evidenceIndex}(2));
end

if  ((decideTrials && sequenceCount<params.Typing.MaximumNumberofSequences)&& ~isempty(sequenceType)) || (isempty(sequenceType) && params.Typing.AllowAsFirstSequence) || enforceFlag==1
    [maxPVal,maxPInd]=max(priorProbs);
    if enforce || (maxPVal>=params.Typing.ConfidenceThreshold) || enforceFlag==1
        nextSequence.trials=fullSet(maxPInd);
        activeFlag=1;
        if isfield(params,'targetID')
            nextSequence.target=params.targetID;
        end
    end
else
    %Nothing...
end


end

