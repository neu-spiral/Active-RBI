%% RSVPKeyboardTask
% RSVPKeyboardTask is the parent class for all the task classes. It keeps
% the properties and functions which are generic to all tasks. Examples of
% subclasses are CalibrationTask, SpellingTask, CopyTask.
%%

classdef RSVPKeyboardTask < handle
    %% Properties of the RSVPKeyboardTask class
    properties
        % taskHistory keeps a history of the task. Actively used by just
        % CopyTask, as a linkedList.
        taskHistory
        
        % decisionObj is a decisionClass object that handles the decision
        % making.
        decisionObj
        
        % languageModelWrapperObject is a languageModelWrapper object handles
        % access to the language model.
        languageModelWrapperObject
        
        % taskUpdateCriteria is a struct of criteria indicating when a task
        % should be updated. It can contain different fields for different
        % tasks. For example, it may contain stopping criteria for the
        % calibration task or phrase changing criteria for the copy tasks.
        taskUpdateCriteria
        
        % symbolStructArray is a struct vector containing list of symbols
        % or images used in presentations. Loaded using xls2Structs
        % function called on imageList.xls.
        symbolStructArray
        
        % currentInfo is a structure that keeps the current status. Examples
        % of its fields are globalSequenceCounter, decision, typingDuration.
        currentInfo
        
        %   operationMode - Mode of operation.
        %                   0 : session
        %                   1 : simulation
        operationMode
        
        % nextSequenceInfoStruct is a structure that keeps the decision rule
        % for the next sequence and some more additional information
        % depending on the task.
        nextSequenceInfoStruct
        
        % matrixSequences keeps the history of presented sequences in matrix mode.       
        matrixSequences
        
        % matrixSpellerMode is a flag which defines if the system is
        % working in matrix mode or not.
        matrixSpellerMode
        
        % presentationParadigm defines the presentation pradigm in matrix mode. 
        presentationParadigm
        
        % currentMatrixSequences holds the current sequence to be
        % presented.
        currentMatrixSequences
        
        % matrixSize holds the values for matrix size in matrix mode.
        matrixSize
    end
    
    %% Methods of RSVPKeyboardTask class
    methods
        %% self=RSVPKeyboardTask(symbolStructArray,RSVPKeyboardParams,scoreStruct,operationMode)
        % Constructor for the RSVPKeyboardTask. This constructor is called
        % from individual tasks to make common initializations.
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
        function self=RSVPKeyboardTask(symbolStructArray,RSVPKeyboardParams,operationMode)
            self.symbolStructArray=symbolStructArray;
            
            self.pInitializeLanguageModel(symbolStructArray,RSVPKeyboardParams);
            self.pInitializeCurrentInfo(RSVPKeyboardParams);
            
            self.operationMode=operationMode;
            
%             self.decisionObj = DecisionClass(self.languageModelWrapperObject,scoreStruct,RSVPKeyboardParams.Typing,RSVPKeyboardParams.FusionRule,RSVPKeyboardParams.matrixSpellerMode,RSVPKeyboardParams.matrixPresentationParadigm,RSVPKeyboardParams.evidenceEval);
            self.decisionObj = DecisionClass(self.languageModelWrapperObject,RSVPKeyboardParams.Typing,RSVPKeyboardParams.FusionRule,RSVPKeyboardParams.matrixSpellerMode,RSVPKeyboardParams.matrixPresentationParadigm,RSVPKeyboardParams.evidenceEval,RSVPKeyboardParams.sessionID);
%            self.nextSequenceInfoStruct.Rule = RSVPKeyboardParams.Typing.nextSequenceDecisionRule;
            
            self.matrixSpellerMode=RSVPKeyboardParams.matrixSpellerMode;
            self.matrixSize=RSVPKeyboardParams.matrixSize;
            if self.matrixSpellerMode
                self.presentationParadigm=RSVPKeyboardParams.matrixPresentationParadigm;
                self.currentMatrixSequences=[];
            end
            
        end
        
        %% checkTaskUpdateCriteria(self)
        % Check if the session is completed.
        function checkTaskUpdateCriteria(self)
            self.currentInfo.taskEndedFlag=self.currentInfo.globalSequenceCounter>=self.taskUpdateCriteria.maximumNumberofSequences;
        end
        
        %% updateDecisionState(self,results)
        % updateDecisionState updates the decisionClass object which makes
        % decisions using the results obtained from the feature extraction
        % stage.
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
        function updateDecisionState(self,results) %
            [decision,epochEndedFlag]=self.decisionObj.makeDecision(results);
            self.pUpdateCurrentInfo(results,decision,epochEndedFlag);
        end
        
    end
    
    methods (Access = protected)
        %% pInitializeLanguageModel(self,symbolStructArray,RSVPKeyboardParams)
        % Initializes the language model server if it is not running and
        % creates corresponding language model wrapper object.
        function pInitializeLanguageModel(self,symbolStructArray,RSVPKeyboardParams)
            if isfield(RSVPKeyboardParams,'isCalibration') && RSVPKeyboardParams.isCalibration
                self.languageModelWrapperObject=artificialPriors(symbolStructArray,RSVPKeyboardParams.artificialPriors);
            else
                if(RSVPKeyboardParams.languageModelOld)
                    [a,b]=dos('tasklist /fi "imagename eq btlmserv.exe"');
                    if(strcmp(b(1:8),'INFO: No'))
                        dos(['btlmserver\btlmserv.exe btlmserver\models\' RSVPKeyboardParams.languageModel ' &']);
                    end
                    languageModelClient=btlm;
                    languageModelClient.initRemote;
                    languageModelClient.alloc;
                else
                    % TODO: Change it to a relative path
                    s = dos(RSVPKeyboardParams.dockerScriptPath)
                   
                    languageModelClient=lm('192.168.99.100');
                    languageModelClient.init();
                end
                self.languageModelWrapperObject=languageModelWrapper(languageModelClient,symbolStructArray,RSVPKeyboardParams.languageModelWrapper);
                
            end
        end
        
        %% pInitializeCurrentInfo(self)
        % Sets up the initial values of the currentInfo.
        function pInitializeCurrentInfo(self,RSVPKeyboardParams)
            self.currentInfo.globalSequenceCounter = 0;
            self.currentInfo.globalTic = tic;
            self.currentInfo.typingDuration=0;
            self.currentInfo.taskEndedFlag = false;
            self.matrixSequences=[];
            if nargin>1
            for evidenceIndex=1:length(RSVPKeyboardParams.evidenceEval.evidences)
                self.currentInfo.(RSVPKeyboardParams.evidenceEval.evidences{evidenceIndex}).globalSequenceCounter = 0;
                self.currentInfo.(RSVPKeyboardParams.evidenceEval.evidences{evidenceIndex}).typingDuration=0;
            end
            end

        end
        
        %% pInitializeTaskUpdateCriteria(self,calibrationParams)
        % Initializes the generic task update criteria.
        function pInitializeTaskUpdateCriteria(self)
            self.taskUpdateCriteria.maximumNumberofSequences = Inf;
        end
        
        %% pUpdateCurrentInfo(self,results,decision,epochEndedFlag)
        % After each attempt to decision making updates the current status
        % according to the current states.
        %
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
        %       decision - a structure containing the decision information.
        %
        %       decision.posteriorProbs - a vector of the current posterior probabilities
        %
        %       decision.decided - the index of the decided symbol if a
        %       decision is made, otherwise it is empty.
        %
        %       epochEndedFlag - a boolean flag indicating if the epoch
        %       finished or not.
        %              true - finished, i.e a decision is made
        %              false - continuing
        %
        function pUpdateCurrentInfo(self,results,decision,epochEndedFlag)
            evidenceNames=fieldnames(results);
            currentInfo4typingDuration=0;
            currentInfo4globalSequenceCounter=0;
            for evidenceIndex=1:length(evidenceNames)
                if isfield(self.currentInfo,evidenceNames{evidenceIndex})
                    self.currentInfo.(evidenceNames{evidenceIndex}).typingDuration=self.currentInfo.(evidenceNames{evidenceIndex}).typingDuration+results.(evidenceNames{evidenceIndex}).duration;
                    self.currentInfo.(evidenceNames{evidenceIndex}).globalSequenceCounter=self.currentInfo.(evidenceNames{evidenceIndex}).globalSequenceCounter+results.(evidenceNames{evidenceIndex}).completedSequenceCount;
                    currentInfo4typingDuration=currentInfo4typingDuration+results.(evidenceNames{evidenceIndex}).duration;
                    currentInfo4globalSequenceCounter=currentInfo4globalSequenceCounter+results.(evidenceNames{evidenceIndex}).completedSequenceCount;
                end
            end
            
            
            self.currentInfo.decision.posteriorProbs=decision.posteriorProbs;
            
            
            
            self.currentInfo.typingDuration=self.currentInfo.typingDuration+currentInfo4typingDuration;
            self.currentInfo.globalSequenceCounter=self.currentInfo.globalSequenceCounter+currentInfo4globalSequenceCounter;
            self.currentInfo.decision.posteriorProbs=decision.posteriorProbs;
            self.currentInfo.decision.decided=decision.decided;
            self.currentInfo.epochEndedFlag=epochEndedFlag;

            if ~isstruct(self.matrixSequences)
                if isstruct(self.currentMatrixSequences)
                    self.matrixSequences.trials=self.currentMatrixSequences.trials;
                end
            else
                if isstruct(self.currentMatrixSequences)
                    self.matrixSequences(end+1).trials=self.currentMatrixSequences.trials;
                end
            end
            
        end
        
        %% pSaveTaskHistory(self,saveLocation)
        % Abstract container function for pSaveTaskHistory in the subclasses.
        function pSaveTaskHistory(self,saveLocation)
            
        end
        
    end
    
    
    
end
