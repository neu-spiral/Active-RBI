%% RecursiveCalibrationTask
% RecursiveCalibrationTask is the controller class for Recursive Calibration task and it inherits CopyTask. It decides on the next trials to show, decides if the session is
% complete, decides if copying status of a phrase, makes decision, prepares the feedback screen to
% send to the presentation and saves information to be saved.
%
%%
classdef RecursiveCalibrationTask < CopyTask
    %% Constant properties of the RecursiveCalibrationTask class
    properties (Constant)
        % copyPhraseSentencesFile is the name of the txt file containing the list of the sentences to be
        % used in the copyphrase experiment. (string)
        copyPhraseSentencesFile='copyphraseSentences.txt';
        
        % copyPhraseSentencesFile4Simulation is the name of the txt file containing the list of the
        % sentences to be used in the simulation mode for copyphrase task. (string)
        copyPhraseSentencesFile4Simulation='copyphraseSentences4Simulation.txt';
    end
    
    %% Properties of the RecursiveCalibrationTask class
    properties
        % fullPhraseList is a cell vector of structs containing preTarget, target and postTarget
        % fields corresponding to the phrase list to be used.
        fullPhraseList
    end
    
    %% Methods of the RecursiveCalibrationTask class
    methods
        %% self=RecursiveCalibrationTask(symbolStructArray,RSVPKeyboardParams,scoreStruct,operationMode)
        % Constructor for the CopyPhraseTask.
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
        function self=RecursiveCalibrationTask(symbolStructArray,RSVPKeyboardParams,operationMode)
            if(~exist('scoreStruct','var'))
                scoreStruct=[];
            end
            if(~exist('operationMode','var'))
                operationMode=0;
            end
            
%             self=self@CopyTask(symbolStructArray,RSVPKeyboardParams,scoreStruct,operationMode);
            self=self@CopyTask(symbolStructArray,RSVPKeyboardParams,operationMode);
            self.pInitializeTaskUpdateCriteria(RSVPKeyboardParams.copyphrase.StoppingCriteria);
            
            self.currentInfo.phraseIndex=1;
            self.pInitializeCurrentPhraseInfo();
            self.reformatPresentationData();
            %self.nextSequenceInfoStruct.Rule = RSVPKeyboardParams.Typing.nextSequenceDecisionRule;
            %self.nextSequenceInfoStruct.NumberofTrials=RSVPKeyboardParams.Typing.NumberofTrials;
        end
        
        %% checkTaskUpdateCriteria(self)
        % checkTaskUpdateCriteria checks if the session is ended by reaching the end of the sentence
        % list. It also inherits the corresponding function from the parent class, CopyTask.
        function checkTaskUpdateCriteria(self)
            self.checkTaskUpdateCriteria@CopyTask();
            
            if(self.currentInfo.phrase.endedFlag)
                if(self.currentInfo.phraseIndex==length(self.fullPhraseList))
                    self.currentInfo.taskEndedFlag=true;
                else
                    self.currentInfo.phraseIndex = self.currentInfo.phraseIndex+1;
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
        function sessionInfo=saveTaskHistory(self,saveLocation,...
                featureExtractionProcessFlow,scoreStruct,...
                calibrationDataStruct,calibrationArtifactParameters)
            
            % call CopyTask.saveTaskHistory(self,saveLocation)
            saveTaskHistory@CopyTask(self,saveLocation);
            
            evidenceType='ERP';
            save([saveLocation '\RecursiveCalibrationFileERP.mat'],...
                'featureExtractionProcessFlow','scoreStruct',...
                'calibrationDataStruct','calibrationArtifactParameters','evidenceType');            
        end
                
    end
    
    methods (Access = protected)
        %% pInitializeTaskUpdateCriteria(self,copyphraseStoppingCriteria)
        % Inherits the task update criteria from the copyTask class.
        %
        % Input:
        %       copyphraseStoppingCriteria - the structure containing the stopping criteria as its
        %       fields. (RSVPKeyboardParams.copyphrase.StoppingCriteria)
        function pInitializeTaskUpdateCriteria(self,copyphraseStoppingCriteria)
            self.pInitializeTaskUpdateCriteria@CopyTask(copyphraseStoppingCriteria);
        end
        
        %% pInitializeCurrentPhraseInfo(self)
        % Initializes the next phrase to be copied by loading the phrase from the fullPhraseList.
        function pInitializeCurrentPhraseInfo(self)
            if(~self.currentInfo.taskEndedFlag)
                self.currentInfo.phrase.preTarget=self.fullPhraseList{self.currentInfo.phraseIndex}.preTarget;
                self.currentInfo.phrase.target=self.fullPhraseList{self.currentInfo.phraseIndex}.target;
                self.currentInfo.phrase.postTarget=self.fullPhraseList{self.currentInfo.phraseIndex}.postTarget;
                self.pInitializeCurrentPhraseInfo@CopyTask();
            end
        end
        
        %% pReadSentenceList(self)
        % Reads the phrase list from the respective sentence list file and initializes the
        % fullPhraseList property.
        function pReadSentenceList(self)
            tempSentenceList=linkedList;
            if(self.operationMode)
                fid=fopen(self.copyPhraseSentencesFile4Simulation);
            else
                fid=fopen(self.copyPhraseSentencesFile);
            end
            sentence=fscanf(fid,'%s,');
            while(~isempty(sentence))
                temp=find(sentence=='"');
                phrase2copyBeginIndex=temp(1);
                phrase2copyEndIndex=temp(2);
                phrase.preTarget=sentence(1:phrase2copyBeginIndex-1);
                phrase.target=sentence((phrase2copyBeginIndex+1):(phrase2copyEndIndex-1));
                phrase.postTarget=sentence((phrase2copyEndIndex+1):end-1);
                tempSentenceList.insertEnd(phrase);
                sentence=fscanf(fid,'%s,');
            end
            fclose(fid);
            self.fullPhraseList=tempSentenceList.toCell();
        end
        
        %% pUpdateCurrentPhraseInfo(self,results)
        % Updates the status and information of the phrase, i.e updates phrase field of the
        % currentInfo property, and checks the task update criteria.
        function pUpdateCurrentPhraseInfo(self,results)
            
            evidenceNames=fieldnames(results);
            currentInfo4typingDuration=0;
            currentInfo4globalSequenceCounter=0;
            for evidenceIndex=1:length(evidenceNames)
                if isfield(self.currentInfo.phrase,evidenceNames{evidenceIndex})
                    self.currentInfo.phrase.(evidenceNames{evidenceIndex}).typingDuration=self.currentInfo.phrase.(evidenceNames{evidenceIndex}).typingDuration+results.(evidenceNames{evidenceIndex}).duration;
                    self.currentInfo.phrase.(evidenceNames{evidenceIndex}).globalSequenceCounter=self.currentInfo.phrase.(evidenceNames{evidenceIndex}).globalSequenceCounter+results.(evidenceNames{evidenceIndex}).completedSequenceCount;
                    currentInfo4typingDuration=currentInfo4typingDuration+results.(evidenceNames{evidenceIndex}).duration;
                    currentInfo4globalSequenceCounter=currentInfo4globalSequenceCounter+results.(evidenceNames{evidenceIndex}).completedSequenceCount;
                end
            end
            
            
            self.currentInfo.phrase.typingDuration=self.currentInfo.phrase.typingDuration+currentInfo4typingDuration;
            self.currentInfo.phrase.sequenceCounter=self.currentInfo.phrase.sequenceCounter+currentInfo4globalSequenceCounter;
            
            self.currentInfo.phrase.typedText=self.languageModelWrapperObject.getText();
            [self.currentInfo.phrase.successfullyCompletedFlag,self.currentInfo.phrase.correctSection,self.currentInfo.phrase.incorrectSection]=checkTypingCorrectness(self.currentInfo.phrase.target,self.currentInfo.phrase.typedText);
            
            self.checkTaskUpdateCriteria();
            
        end
        
    end
    
    
end