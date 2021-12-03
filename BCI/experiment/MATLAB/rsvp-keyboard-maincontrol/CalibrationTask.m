%% CalibrationTask
% CalibrationTask inherits RSVPKeyboardTask and it controls the calibration
% session. It decides on the next trials to show, if the session is
% complete, prepares the feedback screen to send to the presentation and
% saves information to be saved.
%
%%
classdef CalibrationTask < RSVPKeyboardTask
    properties
       
    end
    %% Methods of the CalibrationTask class
    methods
        %% self=CalibrationTask(symbolStructArray, RSVPKeyboardParams, scoreStruct, operationMode)
        % Constructor for the CalibrationTask.
        % The inputs of the constructor
        %   symbolStructArray - a struct vector containing list of symbols
        %   or images used in presentations. Loaded using xls2Structs
        %   function called on imageList.xls.
        %
        %   RSVPKeyboardParams - RSVPKeyboard parameters from the
        %   parameter file RSVPKeyboardParameters.m.
        %
        %   scoreStruct - A calibration file containing the kernel density
        %   estimators. It can be used for calibration as well in the future. It should
        %   be empty for now.
        %
        %   operationMode - Mode of operation.
        %                   0 : session
        %                   1 : simulation
        %
        function self=CalibrationTask(symbolStructArray, RSVPKeyboardParams, operationMode)
%             if(~exist('scoreStruct','var'))
%                 scoreStruct=[];
%             end
            if(~exist('operationMode','var'))
                operationMode=0;
            end
            
%             self=self@RSVPKeyboardTask(symbolStructArray,RSVPKeyboardParams,scoreStruct,operationMode);
            self=self@RSVPKeyboardTask(symbolStructArray,RSVPKeyboardParams,operationMode);
            self.pInitializeTaskUpdateCriteria(RSVPKeyboardParams.Calibration);
            self.nextSequenceInfoStruct.NumberofTrials=RSVPKeyboardParams.Calibration.NumberofTrials;
           
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
        function updateDecisionState(self,results)
             [decision,epochEndedFlag]=self.decisionObj.makeDecision(results);
            self.pUpdateCurrentInfo(results,decision,epochEndedFlag);
            self.reformatPresentationData();
            self.checkTaskUpdateCriteria();
        end
        
        %% reformatPresentationData(self)
        % reformatPresentationData updates the feedback text to be used in presentation. 
        function reformatPresentationData(self)
            if(~self.operationMode)
                self.currentInfo.decision.feedback{1}.Text=[num2str(self.currentInfo.globalSequenceCounter+1) '/' num2str(self.taskUpdateCriteria.maximumNumberofSequences)];
                self.currentInfo.decision.feedback{1}.Type='neutral';
            end     
        end
        
        %% checkTaskUpdateCriteria(self)
        % Check if the calibration session is completed.
        function checkTaskUpdateCriteria(self)
            self.checkTaskUpdateCriteria@RSVPKeyboardTask();
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
%       
%         
         function nextSequence=decideNextTrials(self)
            [nextSequence,nextSequence.Type]=self.decisionObj.decideNextTrials;
            if self.matrixSpellerMode
                self.currentMatrixSequences.trials=nextSequence.trials;
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
            sessionInfo.taskHistory.epochList=self.decisionObj.epochList.toCell();
            sessionInfo.taskHistory.typedText=self.languageModelWrapperObject.getText;
            
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
        %% pInitializeTaskUpdateCriteria(self,calibrationParams)
        % Initializes the task update criteria, which is the ending
        % criteria for the calibration task.
        function pInitializeTaskUpdateCriteria(self,calibrationParams)
            self.pInitializeTaskUpdateCriteria@RSVPKeyboardTask();
            self.taskUpdateCriteria.maximumNumberofSequences=calibrationParams.NumberofSequences;
        end
        
    end
end