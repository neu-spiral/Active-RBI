%% DecisionClass
% DecisionClas is the class that handles decision making. It uses the
% features extracted from featureExtraction (results structure) and
% language model (via languageModelWrapper class), and makes decisions
% after applying the corresponding fusion. It also keeps track of
% decisions.
%%

classdef DecisionClass < handle
    %% Properties of the DecisionClass
    properties
        % decisionHistory keeps a history of the decisions. It is a
        % linkedList of currentInfo structure.
        decisionHistory
        
        % epochList is a linkedList of decisions. It has the same structure
        % as decisionHistory, however it might be resetted in CopyTask if
        % the phrase changes.
        epochList
        
        % decisionStoppingCriteria is a struct of criteria indicating when a
        % decision should be made. It contains the fields of Typing from
        % RSVPKeyboard parameters, e.g confidenceThreshold,
        % confidenceFunction, maximumNumberofSequences.
        decisionStoppingCriteria
        
        % languageModelWrapperObject is a languageModelWrapper object handles
        % access to the language model.
        languageModelWrapperObject
        
        % trialIDs is vector of symbol IDs which are allowed to be
        % stimulus.
        trialIDs
        
        % scoreStruct - A calibration file containing the kernel density
        % estimators.
        %scoreStruct
        
        % currentInfo is a structure that keeps the current status. Examples
        % of its fields are decided, LMprobs, posteriorProbs,
        % localSequenceCounter.
        currentInfo
        
        % fusionRule
        % scalar representing which fusion rule should be applied.
        % 1: Fusion rule defined in (Orhan, Umut, et al. "RSVP keyboard: An
        % EEG based typing interface." Acoustics, Speech and Signal Processing (ICASSP), 2012 IEEE International Conference on. IEEE, 2012.)
        %
        % 2: A new proposed fusion rule with cleaner assumptions
        %
        fusionRule
        
        isMatrix
        
        matrixPP
        
        % evidenceEvaluatorObjs
        % cellArray which off evidence evaluation objects which are
        % instanses of evidenceEvalCalss.
        
        evidenceEvaluatorObjs
        evidenceEvalStruct
        
        % Shows the sessionID is used to adjust session specific rules.
        sessionID
    end
    
    %% Methods of DecisionClass
    methods
        %% self = DecisionClass(languageModelWrapperObject,scoreStruct,decisionStoppingParams,fusionRule)
        % Constructor for the DecisionClass. This constructor is called
        % from RSVPKeyboardTask class to control the decision making.
        % The inputs of the constructor
        %   languageModelWrapperObject - languageModelWrapper object handles
        %   access to the language model.
        %
        %   scoreStruct - A calibration file containing the kernel density
        %   estimators.
        %
        %   decisionStoppingCriteria - struct of criteria of when a decision
        %   should be made. It contains the fields of Typing from
        %   RSVPKeyboard parameters, e.g confidenceThreshold,
        %   confidenceFunction, maximumNumberofSequences.
        function self = DecisionClass(languageModelWrapperObject,decisionStoppingParams,fusionRule,isMatrix,matrixPresentationParadigm,evidenceEvalStruct,sessionID)
            self.languageModelWrapperObject=languageModelWrapperObject;
            
%             if(exist('scoreStruct','var'))
%                 %self.scoreStruct=scoreStruct;
%             else
%                 %self.scoreStruct=[];
%             end
            
            if(exist('sessionID','var'))
                self.sessionID=sessionID;
            else
                self.sessionID=[];
            end           


            self.trialIDs = self.languageModelWrapperObject.trialIDs;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if nargin>4
                self.isMatrix=isMatrix;
                if nargin>5
                    self.matrixPP=matrixPresentationParadigm;
                else
                    self.matrixPP='Single';
                end
            else
                self.isMatrix=false;
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            self.evidenceEvalStruct=evidenceEvalStruct;
            self.pInitializeCurrentInfo();
            self.pSetupDecisionStoppingCriteria(decisionStoppingParams);
            
            self.decisionHistory=linkedList;
            self.epochList=linkedList;
            self.fusionRule=fusionRule;
            
            % inizialize the evidenceEvaluatorObjs
            if nargin>=6
                self.decisionStoppingCriteria.MaximumNumberofSequences=0;
                self.evidenceEvaluatorObjs={};
                for evidenceIndex=1: length(evidenceEvalStruct.evidences)
                    self.evidenceEvaluatorObjs=[self.evidenceEvaluatorObjs,...
                        {evidenceEvalClass(evidenceEvalStruct.evidences{evidenceIndex},...
                        self.evidenceEvalStruct.likelihoodEvalFunctions.Handle{evidenceIndex},...
                        self.evidenceEvalStruct.nextTrialFunctions.Handle{evidenceIndex})}];
                    
                    self.decisionStoppingCriteria.MaximumNumberofSequences = ...
                        self.decisionStoppingCriteria.MaximumNumberofSequences + ...
                        evidenceEvalStruct.nextTrialFunctions.params{evidenceIndex}.Typing.MaximumNumberofSequences;
                    %self.evidenceEvalStruct.initialActiveFalgs(evidenceIndex),...
                end
                
            end
            
        end
        
        %% [tempDecision,epochEndedFlag]=makeDecision(self,results)
        % makeDecision updates the current status using the results structure,
        % checks the decision making criteria, if the epoch ended it
        % makes a decision.
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
        % Outputs:
        %       tempDecision - a structure containing the decision
        %       information.
        %
        %       tempDecision.decided - index of the decided symbol or empty
        %       if epoch didn't end.
        %
        %       epochEndedFlag - boolean indicating if the epoch finished, i.e
        %       a decision is made, or not.
        %
        function [tempDecision,epochEndedFlag]=makeDecision(self,results)
            self.updateCurrentInfo(results);
            epochEndedFlag=self.checkDecisionStoppingCriteria();
            if(epochEndedFlag)
                tempDecision.posteriorProbs=self.currentInfo.posteriorProbs;
                [~, tempDecision.decided]=max(tempDecision.posteriorProbs);
                
                self.currentInfo.decided=tempDecision.decided;
                
                self.pSaveCurrentInfo();
                
                self.pFinalizeEpoch(tempDecision);
                
                self.pInitializeCurrentInfo();
            else
                tempDecision.posteriorProbs=self.currentInfo.posteriorProbs;
                tempDecision.decided=[];
            end
        end
        
        %% getLanguageModelProbabilities(self)
        % getLanguageModelProbabilities queries the language model
        % probabilities via languageModelWrapper object and updates
        % currentInfo property.
        function getLanguageModelProbabilities(self,params4ArtificialPriors)
            if nargin>1
                self.currentInfo.LMprobs = self.languageModelWrapperObject.getProbs(params4ArtificialPriors);
            else
                self.currentInfo.LMprobs = self.languageModelWrapperObject.getProbs();
            end
            self.currentInfo.posteriorProbs=self.currentInfo.LMprobs;
        end
        
        %% resetEpochList(self)
        % Resets the epochList property
        function resetEpochList(self)
            self.epochList=linkedList;
            
        end
        %%
        function [nextTrials,trialType]=decideNextTrials(self,trialType)
            %self.currentInfo.sequenceHistory
             for evidenceIndex=1: length(self.evidenceEvalStruct.evidences)
                self.evidenceEvaluatorObjs{evidenceIndex}.activeFlag=0;
            end
            if nargin>1
                [activeEvidenceDetected,nextTrials] = ...
                    self.evidenceEvaluatorObjs{...
                    self.evidenceEvalStruct.priorities(evidenceIndex)}...
                    .decideNextTrials(self.trialIDs,...
                    self.currentInfo.posteriorProbs,...
                    self.currentInfo.sequenceHistory,...
                    self.evidenceEvalStruct.nextTrialFunctions.params...
                    {self.evidenceEvalStruct.priorities(evidenceIndex)},...
                    self.currentInfo.posteriorHistory);
            else
                activeEvidenceDetected=0;
                evidenceIndex=0;
                while ~activeEvidenceDetected && evidenceIndex<length(self.evidenceEvalStruct.priorities) && evidenceIndex<length(self.evidenceEvalStruct.evidences)
                    evidenceIndex=evidenceIndex+1;
                    
                    [activeEvidenceDetected,nextTrials] = ...
                        self.evidenceEvaluatorObjs{...
                        self.evidenceEvalStruct.priorities(evidenceIndex)}...
                        .decideNextTrials(self.trialIDs,...
                        self.currentInfo.posteriorProbs,...
                        self.currentInfo.sequenceHistory,...
                        self.evidenceEvalStruct.nextTrialFunctions.params...
                        {self.evidenceEvalStruct.priorities(evidenceIndex)},...
                        self.currentInfo.posteriorHistory);
                end
                trialType=self.evidenceEvalStruct.evidences{self.evidenceEvalStruct.priorities(evidenceIndex)};
            end
           % self.checkDecisionStoppingCriteria;
        end
    end
    
    methods (Access = private)
        %% pInitializeCurrentInfo(self)
        % Initializes the epoch's information container, currentInfo
        % property, at the beginning of an epoch.
        function pInitializeCurrentInfo(self)
            %self.currentInfo.localSequenceCounter = 0;
            self.getLanguageModelProbabilities();
            self.currentInfo.decided=[];
            self.currentInfo.posteriorHistory = [];
            for evidenceIndex=1: length(self.evidenceEvalStruct.evidences)
                self.currentInfo.evidence{evidenceIndex}.Type=self.evidenceEvalStruct.evidences{evidenceIndex};
                self.currentInfo.evidence{evidenceIndex}.localSequenceCounter = 0;
                self.currentInfo.evidence{evidenceIndex}.repetitionCounts=zeros(length(self.trialIDs),1);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            self.currentInfo.trialLogCondpdf4Target(length(self.trialIDs))=linkedList;
            self.currentInfo.trialLogCondpdf4Nontarget(length(self.trialIDs))=linkedList;
            self.currentInfo.sequenceHistory=[];
            %self.currentInfo.repetitionCounts=zeros(length(self.trialIDs),1);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        
        %% pFinalizeEpoch(self,decision)
        % After an epoch ends, it updates the language model and clears the
        % linkedList objects.
        function pFinalizeEpoch(self,decision)
            for(symbolIndex=1:length(self.trialIDs))
                self.currentInfo.trialLogCondpdf4Target(symbolIndex).empty();
                self.currentInfo.trialLogCondpdf4Nontarget(symbolIndex).empty();
            end
            
            self.languageModelWrapperObject.update(decision);
            
            for evidenceIndex=1:length(self.evidenceEvalStruct.evidences)
                self.evidenceEvaluatorObjs{evidenceIndex}.enforceTrialsBeforeDecision=0;
            end
            self.currentInfo.posteriorHistory = [];
        end
        
        %% pSetupDecisionStoppingCriteria(self,decisionStoppingParams)
        % Initializes decision stopping criteria according to the input
        % structure which should be passed from RSVPKeyboardParams.Typing
        function pSetupDecisionStoppingCriteria(self,decisionStoppingParams)
            self.decisionStoppingCriteria=decisionStoppingParams;
        end
        
        %% pSaveCurrentInfo(self)
        % Reformats currentInfo and updates corresponding histories.
        % (decisionHistory an epocList)
        function pSaveCurrentInfo(self)
            output=self.pReformatCurrentInfo2Save();
            self.decisionHistory.insertEnd(output);
            self.epochList.insertEnd(output);
        end
        
        %% output=pReformatCurrentInfo2Save(self)
        % Reformats currentInfo by converting linkedList objects to cell
        % vectors.
        %
        % output - structure containing the same information as
        % currentInfo, with linkedLists replaced by cell vectors.
        function output=pReformatCurrentInfo2Save(self)
            output = self.currentInfo;
            output.trialLogCondpdf4Target=cell(length(self.trialIDs),1);
            output.trialLogCondpdf4Nontarget=cell(length(self.trialIDs),1);
            for(symbolIndex=1:length(self.trialIDs))
                output.trialLogCondpdf4Target{symbolIndex} = cell2mat(self.currentInfo.trialLogCondpdf4Target(symbolIndex).toCell);
                output.trialLogCondpdf4Nontarget{symbolIndex} = cell2mat(self.currentInfo.trialLogCondpdf4Nontarget(symbolIndex).toCell);
            end
        end
        
        %% updateCurrentInfo(self,results)
        % Using the scores obtained from ERP classification, the
        % probabilistic information is updated.
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
        function updateCurrentInfo(self,results)
            % check for all functions
            addTrialFlag=0;
            for evidenceIndex=1:length(self.evidenceEvalStruct.evidences)
                addTrialFlag=addTrialFlag|| (~isempty(self.evidenceEvalStruct.likelihoodEvalFunctions.params{evidenceIndex}.scoreStruct));
            end
            if addTrialFlag
                self.addTrials(results);
            end
            self.computePosteriorProbs();
            self.currentInfo.posteriorHistory = [self.currentInfo.posteriorHistory,  self.currentInfo.posteriorProbs];
           
        end
        
        %% addTrials(self,results)
        % Using the scores in results structure, conditional pdf estimate
        % history is updated.
        function addTrials(self,results)
            for evidenceIndex=1:length(self.evidenceEvalStruct.evidences)
                if (isfield(results.(self.evidenceEvalStruct.evidences{evidenceIndex}),'completedSequenceCount') && (results.(self.evidenceEvalStruct.evidences{evidenceIndex}).completedSequenceCount>0))
                    
                    self.evidenceEvalStruct.likelihoodEvalFunctions.params{evidenceIndex}.sessionID = self.sessionID;
                                    
                    logLs=self.evidenceEvaluatorObjs{evidenceIndex}.calculateLikelihoods(results.(self.evidenceEvalStruct.evidences{evidenceIndex}).scores,results.(self.evidenceEvalStruct.evidences{evidenceIndex}).trialLabels,self.trialIDs,self.evidenceEvalStruct.likelihoodEvalFunctions.params{evidenceIndex});
                    pTIndexesWithValue=find(~isnan(logLs(:,1)));
                    % pNIndexesWithValue=find(~isnan(logLs(:,2)));
                    for trialCounter=1:length(pTIndexesWithValue)
                        self.currentInfo.trialLogCondpdf4Target(self.trialIDs(pTIndexesWithValue(trialCounter))).insertEnd(logLs(pTIndexesWithValue(trialCounter),1));
                        self.currentInfo.trialLogCondpdf4Nontarget(self.trialIDs(pTIndexesWithValue(trialCounter))).insertEnd(logLs(pTIndexesWithValue(trialCounter),2));
                    end
                    
                    for(trialIndex=1:length(results.(self.evidenceEvalStruct.evidences{evidenceIndex}).trialLabels))
                        currentTrialID=results.(self.evidenceEvalStruct.evidences{evidenceIndex}).trialLabels(trialIndex);
                        
                       
                        if self.isMatrix && iscell(currentTrialID)
                            currentTrialID=currentTrialID{1};
                                                        
                            for trialIds=1:length(currentTrialID)
                                self.currentInfo.evidence{activeEvidenceIndex}.repetitionCounts(currentTrialID(trialIds))=self.currentInfo.evidence{evidenceIndex}.repetitionCounts(currentTrialID(trialIds))+1;
                            end
                            
                            
                        else
                            
                            if(results.(self.evidenceEvalStruct.evidences{evidenceIndex}).trialLabels(trialIndex)<=length(self.trialIDs))
                                self.currentInfo.evidence{evidenceIndex}.repetitionCounts(currentTrialID)=self.currentInfo.evidence{evidenceIndex}.repetitionCounts(currentTrialID)+1;
                                
                            end
                        end
                    end
                    self.currentInfo.evidence{evidenceIndex}.localSequenceCounter=self.currentInfo.evidence{evidenceIndex}.localSequenceCounter+results.(self.evidenceEvalStruct.evidences{evidenceIndex}).completedSequenceCount;
                    self.currentInfo.sequenceHistory=[ self.currentInfo.sequenceHistory,evidenceIndex];
                end
            end
        end
        
        %% computePosteriorProbs(self)
        % Using the current conditional pdf estimate history and the
        % language model probabilities, the fusion is made and posterior
        % probabilities are calculated. The result is stored in currentInfo
        % property.
        function computePosteriorProbs(self)
            logP=zeros(length(self.trialIDs),1);
            switch self.fusionRule
                case 1
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if self.isMatrix
                        
                        switch self.matrixPP
                            case {'RC','Single'}
                                
                                for(symbolIndex=1:length(self.trialIDs))
                                    logP(symbolIndex)=sum(cell2mat(self.currentInfo.trialLogCondpdf4Target(symbolIndex).toCell)-cell2mat(self.currentInfo.trialLogCondpdf4Nontarget(symbolIndex).toCell))+...
                                        log(self.currentInfo.LMprobs(symbolIndex))-log(1-self.currentInfo.LMprobs(symbolIndex));
                                end
                                
                            case {'Hoffman'}
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    else
                        for(symbolIndex=1:length(self.trialIDs))
                            logP(symbolIndex)=sum(cell2mat(self.currentInfo.trialLogCondpdf4Target(symbolIndex).toCell)-cell2mat(self.currentInfo.trialLogCondpdf4Nontarget(symbolIndex).toCell))+...
                                log(self.currentInfo.LMprobs(symbolIndex))-log(1-self.currentInfo.LMprobs(symbolIndex));
                        end
                    end
                case 2
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if self.isMatrix
                        
                        switch self.matrixPP
                            case {'RC','Single'}
                                
                                for(symbolIndex=1:length(self.trialIDs))
                                    logP(symbolIndex)=sum(cell2mat(self.currentInfo.trialLogCondpdf4Target(symbolIndex).toCell)-cell2mat(self.currentInfo.trialLogCondpdf4Nontarget(symbolIndex).toCell))+...
                                        log(self.currentInfo.LMprobs(symbolIndex));
                                end
                                
                            case {'Hoffman'}
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    else
                        
                        for(symbolIndex=1:length(self.trialIDs))
                            logP(symbolIndex)=sum(cell2mat(self.currentInfo.trialLogCondpdf4Target(symbolIndex).toCell)-cell2mat(self.currentInfo.trialLogCondpdf4Nontarget(symbolIndex).toCell))+...
                                log(self.currentInfo.LMprobs(symbolIndex));
                        end
                    end
            end
            logP(logP==Inf)=log(realmax('double'));
            
            posteriorProbs=exp(logP-max(logP));
            self.currentInfo.posteriorProbs=posteriorProbs/sum(posteriorProbs);
        end
        
        %% epochEndedFlag=checkDecisionStoppingCriteria(self)
        % Check if the epoch ended, by checking decision stoppping criteria
        % with the currentInfo.
        %
        % Output:
        %       epochEndedFlag - boolean indicating if the epoch finished, i.e
        %       a decision is made, or not.
        function epochEndedFlag=checkDecisionStoppingCriteria(self)
            self.decideNextTrials;
            epochEndedFlag=false;
            tmpFlagActive=1;
            
            tmpFlagMinSequences=1;
            enforceTrialFlag=0;
             for evidenceIndex=1:length(self.evidenceEvalStruct.evidences)
                tmpFlagActive=tmpFlagActive && ~self.evidenceEvaluatorObjs{evidenceIndex}.activeFlag;
                tmpFlagMinSequences=tmpFlagMinSequences && (sum(self.currentInfo.sequenceHistory==evidenceIndex) >= self.evidenceEvalStruct.nextTrialFunctions.params{evidenceIndex}.Typing.MinimumNumberofSequences);  
            end
            
            epochEndedFlag = epochEndedFlag | tmpFlagActive ;
            epochEndedFlag = epochEndedFlag | (feval(self.decisionStoppingCriteria.ConfidenceFunction,self.currentInfo.posteriorProbs)>self.decisionStoppingCriteria.ConfidenceThreshold);
            epochEndedFlag=epochEndedFlag && tmpFlagMinSequences ;
            enforcedEvCounter=0;
            enforcableEvCounter=0;
            if epochEndedFlag
                for evidenceIndex=1:length(self.evidenceEvalStruct.evidences)
                    if isfield(self.evidenceEvalStruct.nextTrialFunctions.params{evidenceIndex}.Typing, 'enforceBeforeDecision') && self.evidenceEvalStruct.nextTrialFunctions.params{evidenceIndex}.Typing.enforceBeforeDecision 
                        if (self.currentInfo.sequenceHistory(end) ~= evidenceIndex)
                        enforcableEvCounter=enforcableEvCounter+1;
                        if (self.evidenceEvaluatorObjs{evidenceIndex}.enforceTrialsBeforeDecision~=-1)
                            self.evidenceEvaluatorObjs{evidenceIndex}.enforceTrialsBeforeDecision=1;
                            enforceTrialFlag=1;
                        else
                            enforcedEvCounter=enforcedEvCounter+1;
                            
                        end
                        else
                            self.evidenceEvaluatorObjs{evidenceIndex}.enforceTrialsBeforeDecision=-1;
                        end
                    end
                    
                end
                
            end
            epochEndedFlag=epochEndedFlag && ~enforceTrialFlag;
            epochEndedFlag=epochEndedFlag || ((enforcedEvCounter==enforcableEvCounter) && enforcableEvCounter~=0) ;
            
        end
    end
end
