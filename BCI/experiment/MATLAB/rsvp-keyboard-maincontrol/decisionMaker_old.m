function [decision,quitFlag]=decisionMaker(results,decisionMakerStruct)

quitFlag=false;

%
%Mastery Task
masteryTaskLevelUpFlag=0;
%


if(results.decideNextFlag) % This will stay here% 
            decisionMakerStruct.sequenceCounter.data=decisionMakerStruct.sequenceCounter.data+1; % Global sequence counter: Increase Task sequence counter.  OK
% taskObject.currentInfo.globalSequenceCounter=taskObject.currentInfo.globalSequenceCounter+1;
% taskObject.decisionObj.currentInfo.localSequenceCounter=taskObject.decisionObj.currentInfo.localSequenceCounter+1;
% Moved these to RKClass and DecisionClass
    if(decisionMakerStruct.sessionID~=1) % Remove this condition
        
        canMakeDecision=1; % This will stay here
        
      
        while(canMakeDecision) % This will stay here
            
            %
            %Moved to addTrials function of the DecisionClass  OK
            if(results.completedSequenceCount>0)   
            for(trialIndex=1:length(results.trialLabels))
                
                pT=decisionMakerStruct.scoreStruct.conditionalpdf4targetKDE.probs(results.scores(trialIndex));
                pN=decisionMakerStruct.scoreStruct.conditionalpdf4nontargetKDE.probs(results.scores(trialIndex));
                
                if(results.trialLabels(trialIndex)<=length(decisionMakerStruct.trialIDs))
                decisionMakerStruct.epochRepetitionCounts.data(results.trialLabels(trialIndex))=decisionMakerStruct.epochRepetitionCounts.data(results.trialLabels(trialIndex))+1;
                
                if(decisionMakerStruct.scoreStruct.probThresholdTarget < pT || decisionMakerStruct.scoreStruct.probThresholdNontarget < pN)
                    
                    decisionMakerStruct.trialLogCondpdf4Target(results.trialLabels(trialIndex)).insertEnd(log(pT));
                    decisionMakerStruct.trialLogCondpdf4Nontarget(results.trialLabels(trialIndex)).insertEnd(log(pN));
                end
                end
            end
            end
            %
            
            
            %
            %Moved to computePosteriorProbs of the DecisionClass   OK
            logP=zeros(length(decisionMakerStruct.trialIDs),1);
            
            for(symbolIndex=1:length(decisionMakerStruct.trialIDs))
                logP(symbolIndex)=sum(cell2mat(decisionMakerStruct.trialLogCondpdf4Target(symbolIndex).toCell)-cell2mat(decisionMakerStruct.trialLogCondpdf4Nontarget(symbolIndex).toCell))+...
                    log(decisionMakerStruct.LMprobs.data(symbolIndex))-log(1-decisionMakerStruct.LMprobs.data(symbolIndex));
            end
            logP(logP==Inf)=log(realmax('double'));
            posteriorProbs=exp(logP-max(logP));
            posteriorProbs=posteriorProbs/sum(posteriorProbs);
            %
            
            %
            % Moved this to DecisonClass
            decisionMakerStruct.TypingControl.currentEpochNumberofSeqs.data=decisionMakerStruct.TypingControl.currentEpochNumberofSeqs.data+results.completedSequenceCount; % Local sequence counter: Increase DecisionClass' sequence counter.
             %           
             results.completedSequenceCount=0; % This will stay here

            
            decision.decided=[]; % This will stay here, 
            
            %
            %Moved to DecisionClass
            epochEndedFlag=checkEpochEnd(posteriorProbs,decisionMakerStruct.TypingControl);
            if(epochEndedFlag)
                epochInfo.repetitionCounts=decisionMakerStruct.epochRepetitionCounts.data;
                decisionMakerStruct.epochRepetitionCounts.data=zeros(size(decisionMakerStruct.epochRepetitionCounts.data));
                
                tempDecision.posteriorProbs=posteriorProbs;
                [~, tempDecision.decided]=max(posteriorProbs);
                for(symbolIndex=1:length(decisionMakerStruct.trialLogCondpdf4Target))
                    decisionMakerStruct.trialLogCondpdf4Target(symbolIndex).empty;
                    decisionMakerStruct.trialLogCondpdf4Nontarget(symbolIndex).empty;
                end
                decisionMakerStruct.languageModelWrapper.update(tempDecision);
                decisionMakerStruct.LMprobs.data=decisionMakerStruct.languageModelWrapper.getProbs;
                decisionMakerStruct.TypingControl.currentEpochNumberofSeqs.data=0;
                
                decision.decided=tempDecision.decided;
                
                epochInfo.decision=decision.decided;
                
                decisionMakerStruct.epochList.insertEnd(epochInfo);
                %decision.text=decisionMakerStruct.languageModelWrapper.getText;
            end
            %
            
            %
            %RSVPKeyboardTask
            decisionMakerStruct.typingDuration.data=decisionMakerStruct.typingDuration.data + results.duration; 
            %
            
            switch decisionMakerStruct.sessionID
                case 2 %SPELL
                    %
                    %Reformat Feedback text to send to presentation
                    decision.feedback{1}.Type='neutral';
                    decision.feedback{1}.Text=decisionMakerStruct.languageModelWrapper.getText;
                    %

                    
                case {3,4} %COPYPHRASE
                    %
                    %Reformat Feedback text to send to presentation  OK for
                    %Copyphrase
                    nextFeedbackIndex=1;
                    decision.feedback={};
                    if(~isempty(decisionMakerStruct.copyphrase.sentenceNodeHandle.data.Data.preTarget))


                    decision.feedback{nextFeedbackIndex}.Type='neutral';
                    decision.feedback{nextFeedbackIndex}.Text=decisionMakerStruct.copyphrase.sentenceNodeHandle.data.Data.preTarget;
                    nextFeedbackIndex=nextFeedbackIndex+1;
                    
                    end
                    
                    decision.feedback{nextFeedbackIndex}.Type='positive';
                    decision.feedback{nextFeedbackIndex}.Text=decisionMakerStruct.copyphrase.sentenceNodeHandle.data.Data.target;
                                        nextFeedbackIndex=nextFeedbackIndex+1;

                    
                    if(~isempty(decisionMakerStruct.copyphrase.sentenceNodeHandle.data.Data.postTarget))
                    decision.feedback{nextFeedbackIndex}.Type='neutral';
                    decision.feedback{nextFeedbackIndex}.Text=[decisionMakerStruct.copyphrase.sentenceNodeHandle.data.Data.postTarget];
                                        nextFeedbackIndex=nextFeedbackIndex+1;

                    end
                    
                    decision.feedback{nextFeedbackIndex}.Type='neutral';
                    decision.feedback{nextFeedbackIndex}.Text=['\n' decisionMakerStruct.copyphrase.sentenceNodeHandle.data.Data.preTarget];
                    nextFeedbackIndex=nextFeedbackIndex+1;
                    %
                    
                    %
                    %For each phrase in copyphrase & masteryTask update
                    %sequence counter OK for copyphrase
                    decisionMakerStruct.copyphrase.currentPhraseSequenceCount.data=decisionMakerStruct.copyphrase.currentPhraseSequenceCount.data+results.completedSequenceCount;
                    %
                    
                    %
                    %Get current text typed OK for copyphrase
                    decisionMakerStruct.copyphrase.typedText=decisionMakerStruct.languageModelWrapper.getText;
                    %
                    
                    %
                    %Check the correctness of the typed text  OK for
                    %copyphrase
                    [decisionMakerStruct.copyphrase.phraseCompletedFlag,correctSection,incorrectSection]=checkTypingCorrectness(decisionMakerStruct.copyphrase.sentenceNodeHandle.data.Data.target,decisionMakerStruct.languageModelWrapper.getText);
                    %
                    
                    %
                    %Mark correct section of the typed text as green OK for
                    %copyphrase
                    if(~isempty(correctSection))
                        decision.feedback{nextFeedbackIndex}.Type='positive';
                        decision.feedback{nextFeedbackIndex}.Text=correctSection;
                        nextFeedbackIndex=nextFeedbackIndex+1;
                    end
                    %
                    
                    %
                    %Mark incorrect section of the typed text as red OK for
                    %copyphrase
                    if(~isempty(incorrectSection))
                        decision.feedback{nextFeedbackIndex}.Type='negative';
                        decision.feedback{nextFeedbackIndex}.Text=incorrectSection;
                    end
                    %
                    
                    %
                    %Check if the phrase is finished OK for copyphrase
                    decisionMakerStruct.copyphrase.phraseTime=decisionMakerStruct.typingDuration.data;  %Will be unnecessary in the new RSVPKeyboardTask structure
                    phraseEndedFlag=checkPhraseEnd(decisionMakerStruct.copyphrase);
                    %
                    
                    
                    if(phraseEndedFlag && epochEndedFlag)
                        decisionMakerStruct.copyphrase.sentenceNodeHandle.data.Data.epochs = cell2mat(decisionMakerStruct.epochList.toCell); %OK for copyphrase
                        decisionMakerStruct.copyphrase.sentenceNodeHandle.data.Data.typedText=decisionMakerStruct.copyphrase.typedText;   %OK for copyphrase
                        decisionMakerStruct.copyphrase.sentenceNodeHandle.data.Data.phraseTime=decisionMakerStruct.typingDuration.data;   %OK for copyphrase
                        
                        if(decisionMakerStruct.sessionID==3)
                        decisionMakerStruct.copyphrase.sentenceNodeHandle.data=decisionMakerStruct.copyphrase.sentenceNodeHandle.data.Next; %OK
                        else
                            pastMasteryTaskLevelIndex=decisionMakerStruct.masteryTask.currentLevelIndex.data;
                            quitFlag=updateMasteryTaskSentenceInformation(decisionMakerStruct.masteryTask,decisionMakerStruct.copyphrase.phraseCompletedFlag);
                            masteryTaskLevelUpFlag=(decisionMakerStruct.masteryTask.currentLevelIndex.data>pastMasteryTaskLevelIndex);
                            
                            if(~quitFlag)
                                try
                                decisionMakerStruct.copyphrase.phraseList.insertEnd(decisionMakerStruct.masteryTask.levels{decisionMakerStruct.masteryTask.currentLevelIndex.data}{decisionMakerStruct.masteryTask.currentSetIndex.data}{decisionMakerStruct.masteryTask.currentSentenceIndex.data}); 
                                catch ME
                                    3;
                                end
                                decisionMakerStruct.copyphrase.sentenceNodeHandle.data=decisionMakerStruct.copyphrase.sentenceNodeHandle.data.Next;
                            end
                        end
                        
                        if(isempty(decisionMakerStruct.copyphrase.sentenceNodeHandle.data))  %OK for copyphrase
                            quitFlag=true;
                        else
                        
                        
                            
                        decisionMakerStruct.languageModelWrapper.initializeState(decisionMakerStruct.copyphrase.sentenceNodeHandle.data.Data.preTarget); %OK for copyphrase
                        
                        decisionMakerStruct.copyphrase.currentPhraseSequenceCount.data=0; %OK for copyphrase
                        %
                        
                        decisionMakerStruct.typingDuration.data=0;  %OK for copyphrase
                        decisionMakerStruct.copyphrase.AvgMaximumNumberofSequencesperChar=decisionMakerStruct.copyphrase.StoppingCriteria.SequenceLimitScale*decisionMakerStruct.TypingControl.MaximumNumberofSequences;  %Bullshit
                        decisionMakerStruct.LMprobs.data=decisionMakerStruct.languageModelWrapper.getProbs;  % OK done in decisionClass
                        end
                    end
                        results.completedSequenceCount=0; %Leave it in the while loop

            end
            
            if(isfield(decision,'decided') && ~isempty(decision.decided))
                sendDecisionPacket(decision);
                %----------------------
                if masteryTaskLevelUpFlag
                  decision.decided=31;
                  sendDecisionPacket(decision);
                end
                %-----------------------
                 
            end
            
            %
            %Leave it in the while loop
            if(quitFlag) % quitFlag = taskEndedFlag
               canMakeDecision=false; 
            else
               canMakeDecision= epochEndedFlag;
            end
            %
            
        end
        
        
        %         unsentDecisions=cell2mat(unsentDecisionList.toCell);
        %         if(~isempty(unsentDecisions))
        %         decision.decided=unsentDecisions;
        %         end
        %         decision=[];
        %         switch decisionMakerStruct.sessionID
        %             case 2 %SPELL
        %                 decision.feedback{1}.Type='neutral';
        %                 decision.feedback{1}.Text=decisionMakerStruct.languageModelWrapper.getText;
        %             case 3 %
        %                 decision.feedback{1}.Type='neutral';
        %                 decision.feedback{1}.Text=decisionMakerStruct.copyphrase.sentenceNodeHandle.data.Data.preTarget;
        %                 decision.feedback{2}.Type='positive';
        %                 decision.feedback{2}.Text=decisionMakerStruct.copyphrase.sentenceNodeHandle.data.Data.target;
        %                 decision.feedback{3}.Type='neutral';
        %                 decision.feedback{3}.Text=[decisionMakerStruct.copyphrase.sentenceNodeHandle.data.Data.postTarget];
        %
        %                 decision.feedback{4}.Type='neutral';
        %                 decision.feedback{4}.Text=['\n' decision.feedback{1}.Text];
        %         end
        
    else
        decision=[];
        decision.feedback{1}.Text=[num2str(decisionMakerStruct.sequenceCounter.data) '/' num2str(decisionMakerStruct.Calibration.NumberofSequences)];
        decision.feedback{1}.Type='neutral';
    end
    
    decision.decided=[];
          
    decision.nextSequence=decideNextTrials(decisionMakerStruct);
    if(~quitFlag)
    sendDecisionPacket(decision);
    end
    
    
   
    
else
    decision=[];
end


% if(~isempty(decision))
% finalDecision2send=decision;
% if(isfield(decision,'decided'))
%         for(decisionIndex=1:length(decision.decided))
%             tempDecision=[];
%             tempDecision.decided=decision.decided(decisionIndex);
%             sendDecisionPacket(tempDecision);
%         end
%         rmfield(finalDecision2send,'decided');
% end
%     sendDecisionPacket(finalDecision2send);
% end
%else
%    decision=[];
%end

% if(isempty(results))
%     decision=[];
% else
% decision.nextSequence=decideNextTrials(decisionMakerStruct);
% sendDecisionPacket(decision);
% end
% decision.

%logDecisions(decision)
