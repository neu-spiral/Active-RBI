%% MasteryTask
% MasteryTask is the controller class for mastery task and it inherits CopyTask. It decides on the next trials to show, decides if the session is
% complete, decides if copying status of a phrase, makes decision, prepares the feedback screen to
% send to the presentation and saves information to be saved.
%
%%
classdef MasteryTask < CopyTask
    %% Constant properties of the MasteryTask class
    properties (Constant)
        % masterySentencesFile is the name of the xlsx file containing the list of the sentences to be
        % used in the mastery task experiment with their level and set information. (string)
        masterySentencesFile='masteryTaskSentences.xlsx';
    end
    
    %% Properties of the MasteryTask class
    properties
        % fullPhraseList is a cell vector of cell vector of cell vector of structs containing preTarget, target and postTarget
        % fields corresponding to the phrase list to be used.
        % Example; fullPhraseLevelList{3}{2}{1}.preTarget corresponds to the third level, second
        % set, first sentence, part of the sentence before target.
        fullPhraseLevelList
    end
    
    %% Methods of the MasteryTask class
    methods
        %% self=MasteryTask(symbolStructArray,RSVPKeyboardParams,scoreStruct,operationMode,initialLevelIndex,initialSetIndex)
        % Constructor for the MasteryTask. Queries for starting level and set if not entered.
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
        %   initialLevelIndex - index of the starting level
        %
        %   initialSetIndex - index of the starting set
        %
        function self=MasteryTask(symbolStructArray,RSVPKeyboardParams,scoreStruct,operationMode,initialLevelIndex,initialSetIndex)
%             if(~exist('scoreStruct','var'))
%                 scoreStruct=[];
%             end
            if(~exist('operationMode','var'))
                operationMode=0;
            end
            
%             self=self@CopyTask(symbolStructArray,RSVPKeyboardParams,scoreStruct,operationMode);
            self=self@CopyTask(symbolStructArray,RSVPKeyboardParams,operationMode);
            self.pInitializeTaskUpdateCriteria(RSVPKeyboardParams.copyphrase.StoppingCriteria,RSVPKeyboardParams.masteryTask);
            
            if(exist('initialLevelIndex','var'))
                self.currentInfo.levelIndex=initialLevelIndex;
            else
                self.currentInfo.levelIndex=str2double(input(['Please select the starting level [1:' num2str(length(self.fullPhraseLevelList)) ']:'],'s'));
                
            end
            
            if(exist('initialSetIndex','var'))
                self.currentInfo.setIndex=initialSetIndex;
            else
                self.currentInfo.setIndex=str2double(input(['Please select the starting set [1:' num2str(length(self.fullPhraseLevelList{self.currentInfo.levelIndex})) ']:'],'s'));
            end
            
            self.currentInfo.sentenceIndex=1;
            
            self.currentInfo.successfulPhraseCountinSet=0;
            self.currentInfo.levelSuccessfulFlag=false;
            
            self.pInitializeCurrentPhraseInfo();
            self.reformatPresentationData();
            
            %self.nextSequenceInfoStruct.Rule = RSVPKeyboardParams.Typing.nextSequenceDecisionRule;
            %self.nextSequenceInfoStruct.NumberofTrials=RSVPKeyboardParams.Typing.NumberofTrials;
        end
        
        %% checkTaskUpdateCriteria(self)
        % checkTaskUpdateCriteria checks if a level is successfully completed or a set is
        % unsuccessfully completed, and if the session is finished by completing all the levels.
        % It also inherits the corresponding function from the parent class, CopyTask.
        function checkTaskUpdateCriteria(self)
            self.checkTaskUpdateCriteria@CopyTask();
            
            self.currentInfo.levelSuccessfulFlag=false;
            if(self.currentInfo.phrase.endedFlag)
                self.currentInfo.successfulPhraseCountinSet = self.currentInfo.successfulPhraseCountinSet + self.currentInfo.phrase.successfullyCompletedFlag;
                self.currentInfo.levelSuccessfulFlag=((self.currentInfo.successfulPhraseCountinSet / length(self.fullPhraseLevelList{self.currentInfo.levelIndex}{self.currentInfo.setIndex})) >= self.taskUpdateCriteria.LevelCompletionThreshold);
                if(self.currentInfo.levelSuccessfulFlag)
                    if(length(self.fullPhraseLevelList)==self.currentInfo.levelIndex)
                        self.currentInfo.taskEndedFlag=true;
                    else
                        self.currentInfo.levelIndex=self.currentInfo.levelIndex+1;
                        self.currentInfo.setIndex=1;
                        self.currentInfo.sentenceIndex=1;
                        self.currentInfo.successfulPhraseCountinSet=0;
                    end
                else
                    if(self.currentInfo.sentenceIndex==length(self.fullPhraseLevelList{self.currentInfo.levelIndex}{self.currentInfo.setIndex}))
                        if(self.currentInfo.setIndex==length(self.fullPhraseLevelList{self.currentInfo.levelIndex}))
                            self.currentInfo.setIndex=1;
                        else
                            self.currentInfo.setIndex=self.currentInfo.setIndex+1;
                        end
                        self.currentInfo.sentenceIndex=1;
                        self.currentInfo.successfulPhraseCountinSet=0;
                    else
                        self.currentInfo.sentenceIndex=self.currentInfo.sentenceIndex+1;
                    end
                end
            end
        end
    end
    
    methods (Access = protected)
        %% pInitializeTaskUpdateCriteria(self,copyphraseStoppingCriteria,masteryTaskUpdateCriteria)
        % Initializes mastery task level change criteria and inherits the task update criteria from the copyTask class.
        %
        % Inputs:
        %       copyphraseStoppingCriteria - the structure containing the copytask stopping criteria as its
        %       fields. (RSVPKeyboardParams.copyphrase.StoppingCriteria)
        %
        %       masteryTaskUpdateCriteria - the structure containing the mastery task stopping criteria as its
        %       fields. (RSVPKeyboardParams.masteryTask.StoppingCriteria)
        %
        function pInitializeTaskUpdateCriteria(self,copyphraseStoppingCriteria,masteryTaskUpdateCriteria)
            self.pInitializeTaskUpdateCriteria@CopyTask(copyphraseStoppingCriteria);
            self.taskUpdateCriteria.LevelCompletionThreshold=masteryTaskUpdateCriteria.LevelCompletionThreshold;
        end
        
        %% pInitializeCurrentPhraseInfo(self)
        % Initializes the next phrase to be copied by loading the phrase from the fullPhraseList.
        function pInitializeCurrentPhraseInfo(self)
            if(~self.currentInfo.taskEndedFlag)
                self.currentInfo.phrase.preTarget=self.fullPhraseLevelList{self.currentInfo.levelIndex}{self.currentInfo.setIndex}{self.currentInfo.sentenceIndex}.preTarget;
                self.currentInfo.phrase.target=self.fullPhraseLevelList{self.currentInfo.levelIndex}{self.currentInfo.setIndex}{self.currentInfo.sentenceIndex}.target;
                self.currentInfo.phrase.postTarget=self.fullPhraseLevelList{self.currentInfo.levelIndex}{self.currentInfo.setIndex}{self.currentInfo.sentenceIndex}.postTarget;
                
                self.pInitializeCurrentPhraseInfo@CopyTask();
            end
        end
        
        %% pReadSentenceList(self)
        % Reads the phrase list from the respective sentence list file and initializes the
        % fullPhraseList property.
        function pReadSentenceList(self)
            [rawLevelInfo,rawSentenceInfo]=xlsread('masteryTaskSentences.xlsx');
            rawSentenceInfo=rawSentenceInfo(2:end,3);
            self.fullPhraseLevelList=cell(max(rawLevelInfo(:,1)),1);
            
            for(levelIndex=1:length(self.fullPhraseLevelList))
                
                levelIndexLogicals=find(rawLevelInfo(:,1)==levelIndex);
                levelSentences=rawSentenceInfo(levelIndexLogicals);
                self.fullPhraseLevelList{levelIndex}=cell(max(rawLevelInfo(levelIndexLogicals,2)),1);
                
                
                for(setIndex=1:length(self.fullPhraseLevelList{levelIndex}))
                    setSentences=levelSentences(rawLevelInfo(levelIndexLogicals,2)==setIndex);
                    self.fullPhraseLevelList{levelIndex}{setIndex}=cell(length(setSentences),1);
                    
                    for(sentenceIndex=1:length(setSentences))
                        sentence=setSentences{sentenceIndex};
                        temp=find(sentence=='"');
                        phrase2copyBeginIndex=temp(1);
                        phrase2copyEndIndex=temp(2);
                        phrase.preTarget=sentence(1:phrase2copyBeginIndex-1);
                        phrase.target=sentence((phrase2copyBeginIndex+1):(phrase2copyEndIndex-1));
                        phrase.postTarget=sentence((phrase2copyEndIndex+1):end);
                        self.fullPhraseLevelList{levelIndex}{setIndex}{sentenceIndex}=phrase;
                    end
                end
            end
        end
        
        %% pUpdateCurrentPhraseInfo(self,results)
        % Updates the status and information of the phrase, i.e updates phrase field of the
        % currentInfo property, and checks the task update criteria.
        function pUpdateCurrentPhraseInfo(self,results)
%             self.currentInfo.phrase.typingDuration=self.currentInfo.phrase.typingDuration+results.duration;
%             self.currentInfo.phrase.sequenceCounter=self.currentInfo.phrase.sequenceCounter+results.completedSequenceCount;
            evidenceNames=fieldnames(results);
            currentInfo4typingDuration=0;
            currentInfo4globalSequenceCounter=0;
            for evidenceIndex=1:length(evidenceNames)
                self.currentInfo.phrase.(evidenceNames{evidenceIndex}).typingDuration=self.currentInfo.phrase.(evidenceNames{evidenceIndex}).typingDuration+results.(evidenceNames{evidenceIndex}).duration;
                self.currentInfo.phrase.(evidenceNames{evidenceIndex}).globalSequenceCounter=self.currentInfo.phrase.(evidenceNames{evidenceIndex}).globalSequenceCounter+results.(evidenceNames{evidenceIndex}).completedSequenceCount;
                currentInfo4typingDuration=currentInfo4typingDuration+results.(evidenceNames{evidenceIndex}).duration;
                currentInfo4globalSequenceCounter=currentInfo4globalSequenceCounter+results.(evidenceNames{evidenceIndex}).completedSequenceCount;
            end
            
            self.currentInfo.phrase.typingDuration=self.currentInfo.phrase.typingDuration+currentInfo4typingDuration;
            self.currentInfo.phrase.sequenceCounter=self.currentInfo.phrase.sequenceCounter+currentInfo4globalSequenceCounter;
            
            
            self.currentInfo.phrase.typedText=self.languageModelWrapperObject.getText();
            [self.currentInfo.phrase.successfullyCompletedFlag,self.currentInfo.phrase.correctSection,self.currentInfo.phrase.incorrectSection]=checkTypingCorrectness(self.currentInfo.phrase.target,self.currentInfo.phrase.typedText);
            self.checkTaskUpdateCriteria();
        end
        
        
    end
    
    
end