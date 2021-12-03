%% artificialPriors Class
% artificialPrior sets up the priors probabilities to be used in fusion. 
% It sets up the priors probabilities, for a target letter and for a non
% target letter and rest sets up with uniform distribution. 
% The artificialPrior Class is used for the FRP Calibration

classdef artificialPriors < handle
    %% Properties of the languageModelWrapper Class
    properties
        %%
        % languageModelClient is the btlm object. It is the Matlab interface for the language model.
        %languageModelClient
        
        %%
        % trialIDs is the vector of symbol IDs corresponding to trial symbols.
        trialIDs
        
        %%
        % trialNames is the cell vector of symbol names corresponding to trial symbols.
        trialNames
        
        %%
        % trialTexts is the cell vector of symbol text. It contains the outcome text corresponding
        % to each symbol.
        trialTexts
        
        %%Target
        targetID
        
        %%nonTargetID
        nonTargetID

        typingQueue
        
        %% initialPriors probabilities for target and non target letter. 
        targetProb=.4;
        nonTargetProb=.4;
        
        
        probAdjustStep=.05;
        
        allowBackspace=false;
        
        backspaceID=27;
        
        % total of Target Samples and non Target Samples
        numberOfTargetSamples;
        numberOfNonTargetSamples;
        
        % Indicator if is artificial prior. 
        isAtrificialPriors=1;
    end
    
    methods
        function self=artificialPriors(imageStructs,artificialPriorsParams)
           
            if nargin>1
                if isfield(artificialPriorsParams,'probAdjustStep')
                    self.probAdjustStep=artificialPriorsParams.probAdjustStep;
                end
                if isfield(artificialPriorsParams,'targetInitialProb')
                    self.targetProb=artificialPriorsParams.targetInitialProb;
                end
                if isfield(artificialPriorsParams,'nonTargetInitialProb')
                    self.nonTargetProb=artificialPriorsParams.nonTargetInitialProb;
                end
                if isfield(artificialPriorsParams,'numberOfTargetSamples')
                    self.numberOfTargetSamples=artificialPriorsParams.numberOfTargetSamples;
                end
                if isfield(artificialPriorsParams,'numberOfNonTargetSamples')
                    self.numberOfNonTargetSamples=artificialPriorsParams.numberOfNonTargetSamples;
                end
                if isfield(artificialPriorsParams,'allowBackspace')
                    self.allowBackspace=artificialPriorsParams.allowBackspace;
                end
                
            end
            
            self.targetID=[];
            self.nonTargetID=[];
            
            trialStructIndices=([imageStructs.IsTrial]==1);
            
            self.trialNames={imageStructs(trialStructIndices).Name};
            self.trialIDs=[imageStructs(trialStructIndices).ID];
            self.backspaceID=self.trialIDs(strcmp(self.trialNames,'DeleteCharacter'));
            self.trialTexts={imageStructs(trialStructIndices).Text};
            self.typingQueue=linkedList;
        end
        
        % sets the prior probabilities for the target and non target symbols and the rest of symbols. 
        % According to inequality betweenn the ratio of
        % numberOfNonTargets/self.numberOfNonTargetSamples and numberTargets/self.numberOfTargetSamples
        % the prior probability of the targetSymbol and probability of
        % nonTarget is increased or decreased respectively. The nonTarget
        % symbol is choose randomly. 
        function p=getProbs(self,params4ArtificialPriors)
            if nargin>1
                numberOfTargets=params4ArtificialPriors.numberOfTargets;
                numberOfNonTargets=params4ArtificialPriors.numberOfNonTargets;
            else
                numberOfTargets=0;
                numberOfNonTargets=0;
            end
            p=zeros(1,length(self.trialIDs));
            
            
            if ~isempty(self.targetID)
                uniformProbs= 1-self.targetProb-self.nonTargetProb;
                tmpIDs=self.trialIDs;
                if ~self.allowBackspace
                    tmpIDs([self.targetID,self.backspaceID])=[];
                    uniformProbs=uniformProbs/(length(p)-3);
                    p(1:end)=uniformProbs;
                    p(self.backspaceID)=0;
                else
                    tmpIDs([self.targetID])=[];
                    uniformProbs=uniformProbs/(length(p)-2);
                    p(1:end)=uniformProbs;
                end
                self.nonTargetID=tmpIDs(randi(length(tmpIDs),1,1));
                
                
                targetRatio=numberOfTargets/self.numberOfTargetSamples;
                nonTargetRatio=numberOfNonTargets/self.numberOfNonTargetSamples;
                
                if targetRatio>nonTargetRatio && (numberOfNonTargets < self.numberOfNonTargetSamples)
                    if self.targetProb>=self.probAdjustStep && self.nonTargetProb<=1-self.probAdjustStep
                        self.targetProb= self.targetProb-self.probAdjustStep;
                        self.nonTargetProb=self.nonTargetProb+self.probAdjustStep;
                    end
                elseif targetRatio<nonTargetRatio
                    if self.nonTargetProb>=self.probAdjustStep && self.targetProb<=1-self.probAdjustStep
                        self.nonTargetProb= self.nonTargetProb-self.probAdjustStep;
                        self.targetProb=self.targetProb+self.probAdjustStep;
                    end
                end
                p(self.targetID)=self.targetProb;
                p(self.nonTargetID)=self.nonTargetProb;
            else
                if ~self.allowBackspace
                    uniformProbs=1/(length(p)-1);
                    p(1:end)=uniformProbs;
                    p(self.backspaceID)=0;
                else
                    uniformProbs=1/(length(p));
                    p(1:end)=uniformProbs;
                end
                
            end
            
            
            
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        
        
        function update(self,decision,targetID)
            
            
            if(strcmp(self.trialNames{decision.decided},'DeleteCharacter'))
                self.typingQueue.remove(self.typingQueue.Tail);
            else
                self.typingQueue.insertEnd(listNode(decision.decided));
            end
            if nargin>2
                 self.targetID=targetID;
            end
           
        end
        
        function text=getText(self)
            text=cell2mat(self.trialTexts(cell2mat(self.typingQueue.toCell)));
            if(isempty(text))
                text='';
            end
            
        end
        
        function reset(self)
   
            self.typingQueue=linkedList;
        end
        
        function initializeState(self,text)
             self.reset;
        end
        
    end
end
