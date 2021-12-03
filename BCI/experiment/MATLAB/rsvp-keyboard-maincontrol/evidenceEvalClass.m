%% evidenceEvalClass
% evidenceClass is the class that handles the
% evidences extracted from featureExtraction (results structure) and decides the next trials to show in presentation
%%


classdef evidenceEvalClass < handle
    %Properties
    
    properties
        trialType 
        likelihoodEvalFunctionHandle
        activeFlag=0;
        nextTrialsFunctionHandle
        enforceTrialsBeforeDecision=0;
       
    end
    
    methods
        %% self = evidenceEvalClass(scoreStruct,params)
        % Constructor for the evidenceEvalClass. This constructor is called
        % from decision class to control the evidenceExtracted
        % The inputs of the constructor
        %         trialType % string indicating the type of evidence {'ERP}or {'FRP'}
        %         activeFlag % boolean indicating if next sequence of the evidence is going to be shown. 
        %         likelihoodFunctionHandle % likelihood function handle
        %         predictFunctionHandle % decide next sequence function handle.
        function self = evidenceEvalClass(trialType,likelihoodFunctionHandle,predictFunctionHandle,activeFlag)
            self.trialType=trialType;
            self.likelihoodEvalFunctionHandle=likelihoodFunctionHandle;
            self.nextTrialsFunctionHandle=predictFunctionHandle;
            if nargin>=4
                 self.activeFlag=activeFlag;
            end
        end
        
        %%  likelihoods=calculateLikelihoods(self,scores,labels)
        % Using the scores in results structure, the likelihoods are
        % computed according to the likelihood function handle
        function likelihoods=calculateLikelihoods(self,scores,trialLabels,orderedVocabLabels,params)
           % trialLabels
            likelihoods=self.likelihoodEvalFunctionHandle(scores,trialLabels,orderedVocabLabels,params);
        end
        
        %% nextTrials=decideNextTrials(self)
        % Decide on the next trials to present according to the predictFunctionHandle
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
        %           nextSequence.trial- the trial Index
        %
        %           activeFlag- boolean indicating if the nextSequence of the corresponding type is
        %           going to be presented. 
        function [activeFlag,nextTrials]=decideNextTrials(self,orderedVocabLabels,priorProbs,sequenceHistory,params,posteriorHistory)
            [activeFlag,nextTrials]=self.nextTrialsFunctionHandle(orderedVocabLabels,priorProbs,posteriorHistory,sequenceHistory,params,self.enforceTrialsBeforeDecision);
            self.activeFlag=activeFlag;
            
            if self.enforceTrialsBeforeDecision ==1
                self.enforceTrialsBeforeDecision=-1;
            end
        end

    end
end
