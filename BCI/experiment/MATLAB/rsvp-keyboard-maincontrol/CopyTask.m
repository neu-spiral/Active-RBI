%% CopyTask
% CopyTask inherits RSVPKeyboardTask and it is the parent class for the CopyPhraseTask and
% MasteryTask classes. It decides on the next trials to show, decides if the session is
% complete, decides if copying status of a phrase, makes decision, prepares the feedback screen to
%send to the presentation and saves information to be saved.
%
%%
classdef CopyTask < RSVPKeyboardTask
    properties
        targetTrialCounter=0;
        nonTargetTrialCounter=0;
        
    end
    %% Methods of the CopyTask class
    methods
        %% self=CopyTask(symbolStructArray,RSVPKeyboardParams,scoreStruct,operationMode)
        % Constructor for the CopyTask. This constructor is called
        % from individual tasks to make common initializations of CopyTask.
        % The inputs of the constructor
        %   symbolStructArray - a struct vector containing list of symbols
        %   or images used in presentations. Loaded using xls2Structs
        %   function called on imageList.xls.
        %
        %   RSVPKeyboardParams - RSVPKeyboard parameters from the
        %   parameter file RSVPKeyboardParameters.m.
        %
        %   scoreStruct - A calibration file containing the kernel density
        %   estimators.
        %
        %   operationMode - Mode of operation.
        %                   0 : session
        %                   1 : simulation
        %
        function self=CopyTask(symbolStructArray,RSVPKeyboardParams,operationMode)

            self=self@RSVPKeyboardTask(symbolStructArray,RSVPKeyboardParams,operationMode);
            self.pReadSentenceList();
            self.taskHistory=linkedList;
            
        end
        % set the target ID for the next epoch to be used for the
        % artificialPrior obj 
        function setTheTargetID(self)
            self.decisionObj.languageModelWrapperObject.allowBackspace=true;
            imageStructIDList=[self.symbolStructArray.ID];
            if(isempty(self.currentInfo.phrase.incorrectSection))
                if isempty(self.currentInfo.phrase.correctSection)
                    self.decisionObj.languageModelWrapperObject.allowBackspace=false;
                    
                end
               
                tmpLengthTargetPhrase=length(self.currentInfo.phrase.target);
                tmpTargetIndexPhrase= length(self.currentInfo.phrase.correctSection)+1;
                if((tmpTargetIndexPhrase<=tmpLengthTargetPhrase))
                targetSymbolNextEpoch= imageStructIDList(strcmp({self.symbolStructArray.Text},self.currentInfo.phrase.target(length(self.currentInfo.phrase.correctSection)+1)));
                else
                 targetSymbolNextEpoch=randi(randi(length(imageStructIDList),[1])); 
                end
            else %Backspace
                targetSymbolNextEpoch=self.decisionObj.languageModelWrapperObject.backspaceID;
            end
            
            
            self.decisionObj.languageModelWrapperObject.targetID=targetSymbolNextEpoch;
            
            
            
            if sum (strcmp(self.decisionObj.evidenceEvalStruct.evidences,'FRP'))>0
                self.decisionObj.evidenceEvalStruct.nextTrialFunctions.params{strcmp(self.decisionObj.evidenceEvalStruct.evidences,'FRP')}.targetID=self.decisionObj.languageModelWrapperObject.targetID;
            end
        end
        
        %% updateDecisionState(self,results)
        % updateDecisionState updates the decisionClass object which makes
        % decisions using the results obtained from the feature extraction
        % stage. If the current phrase ended it prepares the next phrase and initializes the
        % decisionClass object for the next phrase.
        %
        % Input:
        %       results - a structure containing one dimensional features
        %       corresponding to each trial
        %
        %       results.trialLabels - the labels of the trials (vector of
        %       indices)
        %
        %       results.decideNextFlag - a boolean indicator indicates if a
        %       new sequence is expected to be shown.
        %
        %       results.completedSequenceCount - the number of sequences
        %       completed and contained in the results structure
        %
        %       results.duration - the duration of the sequence(s)
        %
        function updateDecisionState(self,results)
            self.updateDecisionState@RSVPKeyboardTask(results);
            self.pUpdateCurrentPhraseInfo(results);
            if(self.currentInfo.epochEndedFlag)
                self.reformatPresentationData();
            end
            
            if(self.currentInfo.phrase.endedFlag)
                self.pSavePhraseInfo();
                
                self.decisionObj.resetEpochList();
                self.pInitializeCurrentPhraseInfo();
            end
            %%%%%
            if  self.currentInfo.epochEndedFlag
                if isprop(self.decisionObj.languageModelWrapperObject,'isAtrificialPriors') && self.decisionObj.languageModelWrapperObject.isAtrificialPriors
                    self.setTheTargetID();
                    tmp.numberOfTargets=self.targetTrialCounter;
                    tmp.numberOfNonTargets=self.nonTargetTrialCounter;
                    self.decisionObj.getLanguageModelProbabilities(tmp);
                end
            end
            %%%%%
        end
        
         %% nextSequence=decideNextTrials(self)
        % Decide on the next sequence to present.
        % 
        %
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
         function nextSequence=decideNextTrials(self)
            self.reformatPresentationData();
            [nextSequence,nextSequence.Type]=self.decisionObj.decideNextTrials;
            if isprop(self.decisionObj.languageModelWrapperObject,'isAtrificialPriors') && self.decisionObj.languageModelWrapperObject.isAtrificialPriors
                if strcmp(nextSequence.Type,'FRP')
                    if sum(nextSequence.trials==self.decisionObj.languageModelWrapperObject.targetID)>0
                        self.targetTrialCounter=self.targetTrialCounter+1;
                    else
                        self.nonTargetTrialCounter=self.nonTargetTrialCounter+1;
                    end
                end

            end
            if self.matrixSpellerMode
                self.currentMatrixSequences.trials=nextSequence.trials; 
            end
        end
        
        %% checkTaskUpdateCriteria(self)
        % Checks if the phrase ended by reaching one of the stopping criteria or successful
        % completion of the phrase.
        function checkTaskUpdateCriteria(self)
            self.checkTaskUpdateCriteria@RSVPKeyboardTask();
            
            self.currentInfo.phrase.endedFlag=false;
            
            self.currentInfo.phrase.endedFlag=self.currentInfo.phrase.endedFlag | (self.currentInfo.phrase.typingDuration > self.taskUpdateCriteria.MaximumEstimatedPhraseTime);
            
            self.currentInfo.phrase.endedFlag= self.currentInfo.phrase.endedFlag | (self.currentInfo.phrase.sequenceCounter > self.taskUpdateCriteria.AvgMaximumNumberofSequencesperChar*length(self.currentInfo.phrase.target));
            
            self.currentInfo.phrase.endedFlag= self.currentInfo.phrase.endedFlag | self.currentInfo.phrase.successfullyCompletedFlag;
            
            self.currentInfo.phrase.endedFlag= self.currentInfo.phrase.endedFlag | (self.taskUpdateCriteria.MaximumLengthOfIncorrectSection <= length(self.currentInfo.phrase.incorrectSection));
            
            self.currentInfo.phrase.endedFlag = self.currentInfo.phrase.endedFlag & self.currentInfo.epochEndedFlag;
        end
        
        %% reformatPresentationData(self)
        % reformatPresentationData updates the feedback text to be used in presentation.
        function reformatPresentationData(self)
            if(~self.operationMode)
                nextFeedbackIndex=1;
                self.currentInfo.decision.feedback={};
                if(~isempty(self.currentInfo.phrase.preTarget))
                    self.currentInfo.decision.feedback{nextFeedbackIndex}.Type='neutral';
                    self.currentInfo.decision.feedback{nextFeedbackIndex}.Text=self.currentInfo.phrase.preTarget;
                    nextFeedbackIndex=nextFeedbackIndex+1;
                end
                
                self.currentInfo.decision.feedback{nextFeedbackIndex}.Type='positive';
                self.currentInfo.decision.feedback{nextFeedbackIndex}.Text=self.currentInfo.phrase.target;
                nextFeedbackIndex=nextFeedbackIndex+1;
                
                if(~isempty(self.currentInfo.phrase.postTarget))
                    self.currentInfo.decision.feedback{nextFeedbackIndex}.Type='neutral';
                    self.currentInfo.decision.feedback{nextFeedbackIndex}.Text=self.currentInfo.phrase.postTarget;
                    nextFeedbackIndex=nextFeedbackIndex+1;    
                end
                
                self.currentInfo.decision.feedback{nextFeedbackIndex}.Type='neutral';
                self.currentInfo.decision.feedback{nextFeedbackIndex}.Text=['\n' self.currentInfo.phrase.preTarget];
                nextFeedbackIndex=nextFeedbackIndex+1;
                
                if(~isempty(self.currentInfo.phrase.correctSection))
                    self.currentInfo.decision.feedback{nextFeedbackIndex}.Type='positive';
                    self.currentInfo.decision.feedback{nextFeedbackIndex}.Text=self.currentInfo.phrase.correctSection;
                    nextFeedbackIndex=nextFeedbackIndex+1;
                end
                
                if(~isempty(self.currentInfo.phrase.incorrectSection))
                    self.currentInfo.decision.feedback{nextFeedbackIndex}.Type='negative';
                    self.currentInfo.decision.feedback{nextFeedbackIndex}.Text=self.currentInfo.phrase.incorrectSection;
                end
            end
        end
        
        %% sessionInfo=saveTaskHistory(self,saveLocation)
        % Saves the history and information of the task to the output
        % variable and to file if a file to save is given.
        % 
        % Input:
        %       saveLocation - file address to save the information into,
        %       it can be omitted.
        %
        %
        % Output:
        %        sessionInfo - variable form of the information which is to
        %        be saved
        %
        function sessionInfo=saveTaskHistory(self,saveLocation)
            if(~self.currentInfo.taskEndedFlag)
                self.pSavePhraseInfo();
            end
            sessionInfo.taskHistory=self.taskHistory.toCell();
            
            sessionInfo.typingDuration=self.currentInfo.typingDuration;
            sessionInfo.globalSequenceCounter=self.currentInfo.globalSequenceCounter;
            sessionInfo.totalSessionDuration=toc(self.currentInfo.globalTic);
            
            sessionInfo.sessionType=class(self);
           
            matrixSequences=self.matrixSequences;
            if(exist('saveLocation','var'))
                save([saveLocation '\taskHistory.mat'],'sessionInfo','matrixSequences');
            end
           
        end
    end
    
    methods (Access = protected)
        
        %% pInitializeTaskUpdateCriteria(self,copyphraseStoppingCriteria)
        % Initializes task update criteria for the copy tasks. It contains the stopping criteria to
        % pass to the next phrase when it is not successful. It also inherits the task stopping
        % criteria from the parent class RSVPKeyboardTask.
        function pInitializeTaskUpdateCriteria(self,copyphraseStoppingCriteria)
            self.pInitializeTaskUpdateCriteria@RSVPKeyboardTask();
            
            self.taskUpdateCriteria.MaximumEstimatedPhraseTime=copyphraseStoppingCriteria.MaximumEstimatedPhraseTime;
            self.taskUpdateCriteria.SequenceLimitScale=copyphraseStoppingCriteria.SequenceLimitScale;
            self.taskUpdateCriteria.AvgMaximumNumberofSequencesperChar=self.taskUpdateCriteria.SequenceLimitScale * self.decisionObj.decisionStoppingCriteria.MaximumNumberofSequences;
            self.taskUpdateCriteria.MaximumLengthOfIncorrectSection=copyphraseStoppingCriteria.MaximumLengthOfIncorrectSection;
        end
        
        
        %% pInitializeCurrentInfo(self)
        % Sets up the initial values of the currentInfo, which is the information container for the status of the task.
        function pInitializeCurrentPhraseInfo(self)
            self.currentInfo.phrase.typingDuration=0;
            self.currentInfo.phrase.sequenceCounter=0;
            self.currentInfo.phrase.endedFlag=false;
            self.currentInfo.phrase.successfullyCompletedFlag=false;
            self.currentInfo.phrase.correctSection='';
            self.currentInfo.phrase.incorrectSection='';
            self.currentInfo.phrase.typedText='';
            for evidenceIndex=1:length(self.decisionObj.evidenceEvalStruct.evidences)
                self.currentInfo.phrase.(self.decisionObj.evidenceEvalStruct.evidences{evidenceIndex}).globalSequenceCounter = 0;
                self.currentInfo.phrase.(self.decisionObj.evidenceEvalStruct.evidences{evidenceIndex}).typingDuration=0;
            end
            
            self.languageModelWrapperObject.initializeState(self.currentInfo.phrase.preTarget);
            if isprop(self.decisionObj.languageModelWrapperObject,'isAtrificialPriors') && self.decisionObj.languageModelWrapperObject.isAtrificialPriors
                self.setTheTargetID();
                tmp.numberOfTargets=self.targetTrialCounter;
                tmp.numberOfNonTargets=self.nonTargetTrialCounter;
                self.decisionObj.getLanguageModelProbabilities(tmp);
            else
                self.decisionObj.getLanguageModelProbabilities();
            end
        end
        
        %% pReadSentenceList(self)
        % Abstract container function for pReadSentenceList in the subclasses.
        function pReadSentenceList(self)
        end
        
        %% pUpdateCurrentPhraseInfo(self,results)
        % Abstract container function for pUpdateCurrentPhraseInfo in the subclasses.
        function pUpdateCurrentPhraseInfo(self,results)
        end
        
        %% pSavePhraseInfo(self)
        % pSavePhraseInfo prepares current phrase information to be recorded and inserts it into
        % taskHistory. 
        function pSavePhraseInfo(self)
            savedPhrasePacket=self.currentInfo.phrase;
            savedPhrasePacket.epochList=self.decisionObj.epochList.toCell();
            self.taskHistory.insertEnd(savedPhrasePacket);
        end
        
    end
    
end