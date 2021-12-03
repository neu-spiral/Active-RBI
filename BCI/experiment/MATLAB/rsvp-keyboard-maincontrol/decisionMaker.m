%% decisionMaker
% decisionMaker controls the progress of the session, makes decisions and communicates with the
% presentation.
%
% [continueFlag,decision]=decisionMaker(results,RSVPKeyboardTaskObject,main2presentationCommObjectStruct,BCIPacketStruct)
%
% Inputs:
%      results - a structure containing one dimensional features corresponding to each trial
%
%           results.trialLabels - the labels of the trials (vector of indices)
%
%           results.decideNextFlag - a boolean indicator indicates if a new sequence is expected to be shown.
%
%           results.completedSequenceCount - the number of sequences completed and contained in the results structure
%
%           results.duration - the duration of the sequence(s)
%
%       RSVPKeyboardTaskObject - the RSVPKeyboardTask object that controls the session
%
%       main2presentationCommObjectStruct - Struct, contains the communication object.
%
%       BCIPacketStruct - Struct, contains data about the communication protocols.
%
% Outputs:
%       continueFlag - boolean flag controls the continuation of the session: true
%       (continue)/false(end session)
%
%       decision - decision structure. If a decision is not made decision is empty, otherwise it has the
%       following structure.
%
%           decision.decided - the symbol index corresponding to the decided symbol
%
%           decision.nextSequence - the vector of symbol indices corresponding to the next sequence
%
%           decision.posteriorProbs - vector of posterior probabilities
%


function [continueFlag,decision] = decisionMaker(results,RSVPKeyboardTaskObject,main2presentationCommObjectStruct,BCIPacketStruct)

if (isfield(results,'ERP')&& results.ERP.decideNextFlag) || (isfield(results,'FRP') && results.FRP.decideNextFlag)
    if(~isa(RSVPKeyboardTaskObject,'CalibrationTask'))  %Remove in future when calibration has the ability to make decisions
        canMakeDecision=1;
        
        while(canMakeDecision)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(RSVPKeyboardTaskObject,'MasteryTask')
                pLI=RSVPKeyboardTaskObject.currentInfo.levelIndex;
                pSI=RSVPKeyboardTaskObject.currentInfo.setIndex;
                pScI=RSVPKeyboardTaskObject.currentInfo.sentenceIndex;
            end
            if isa(RSVPKeyboardTaskObject,'CopyPhraseTask')
                pPhr=RSVPKeyboardTaskObject.currentInfo.phraseIndex;
                
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            RSVPKeyboardTaskObject.updateDecisionState(results);
            evidenceNames=fieldnames(results);
            for evidenceIndex=1:length(evidenceNames)
                results.(evidenceNames{evidenceIndex}).completedSequenceCount=0;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(RSVPKeyboardTaskObject,'MasteryTask')
                if(pLI~=RSVPKeyboardTaskObject.currentInfo.levelIndex) || (pSI~=RSVPKeyboardTaskObject.currentInfo.setIndex) || (pScI~=RSVPKeyboardTaskObject.currentInfo.sentenceIndex)
                    RSVPKeyboardTaskObject.currentInfo.showTarget=1;
                end
            end
            if isa(RSVPKeyboardTaskObject,'CopyPhraseTask')
                if (pPhr~=RSVPKeyboardTaskObject.currentInfo.phraseIndex)
                    RSVPKeyboardTaskObject.currentInfo.showTarget=1;
                end
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isa(RSVPKeyboardTaskObject,'MasteryTask') || isa(RSVPKeyboardTaskObject,'CopyPhraseTask')
                if( isfield(RSVPKeyboardTaskObject.currentInfo,'showTarget') )
                    if( isfield(RSVPKeyboardTaskObject.currentInfo,'decision') && ~isempty(RSVPKeyboardTaskObject.currentInfo.decision))
                        RSVPKeyboardTaskObject.currentInfo.decision.showTarget=RSVPKeyboardTaskObject.currentInfo.showTarget;
                    end
                end
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            if( isfield(RSVPKeyboardTaskObject.currentInfo.decision,'decided') && ~isempty(RSVPKeyboardTaskObject.currentInfo.decision))
                
                decision=RSVPKeyboardTaskObject.currentInfo.decision;
                if(~RSVPKeyboardTaskObject.operationMode)
                    sendDecisionPacket(decision,main2presentationCommObjectStruct,BCIPacketStruct);
                    
                    
                end
                if ~RSVPKeyboardTaskObject.operationMode && isa(RSVPKeyboardTaskObject,'MasteryTask') && RSVPKeyboardTaskObject.currentInfo.levelSuccessfulFlag
                    
                    decision=RSVPKeyboardTaskObject.currentInfo.decision;
                    decision.decided=0;
                    decision.levelUp=1;
                    
                    sendDecisionPacket(decision,main2presentationCommObjectStruct,BCIPacketStruct);
                    
                end
            end
            
            if(RSVPKeyboardTaskObject.currentInfo.taskEndedFlag)
                canMakeDecision=false;
            else
                canMakeDecision= RSVPKeyboardTaskObject.currentInfo.epochEndedFlag;
            end
            
            
        end
    else
        RSVPKeyboardTaskObject.updateDecisionState(results);
        decision=RSVPKeyboardTaskObject.currentInfo.decision;
    end
    
    if(~RSVPKeyboardTaskObject.currentInfo.taskEndedFlag)
        temp=RSVPKeyboardTaskObject.decideNextTrials();
        decision=RSVPKeyboardTaskObject.currentInfo.decision;
        decision.nextSequence=temp;
        
        if(~RSVPKeyboardTaskObject.operationMode)
            sendDecisionPacket(decision,main2presentationCommObjectStruct,BCIPacketStruct);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        RSVPKeyboardTaskObject.currentInfo.showTarget=0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
else
    decision=[];
end
continueFlag=~RSVPKeyboardTaskObject.currentInfo.taskEndedFlag;

end