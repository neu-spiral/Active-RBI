%% languageModelWrapper Class
% languageModelWrapper is a Matlab interface for the language model. It sets up the language model
% probabilities to be used in fusion. In addition to original language model, it can handle
% additional symbols and perform modifications on the original probability mass.
%%

classdef languageModelWrapper < handle
    %% Properties of the languageModelWrapper Class
    properties
        %%
        % languageModelClient is the btlm object. It is the Matlab interface for the language model.
        languageModelClient
        
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
        
        %%
        %
        trialLanguageModelSymbols
        languageModelWrapperParameters
        languageModelClientTrialIndices
        
        lastPosteriorProbs
        lastDecided
        lastDeleted
        
        specialSymbolIndices
        typingQueue
    end
    
    methods
        function self=languageModelWrapper(languageModelClient,imageStructs,languageModelWrapperParameters)
            self.languageModelClient=languageModelClient;
            
            trialStructIndices=([imageStructs.IsTrial]==1);
            
            self.trialNames={imageStructs(trialStructIndices).Name};
            self.trialIDs=[imageStructs(trialStructIndices).ID];
            self.trialLanguageModelSymbols={imageStructs(trialStructIndices).LanguageModelSymbol};
            self.trialTexts={imageStructs(trialStructIndices).Text};
            
            languageModelSymbols=languageModelClient.symbol;
            self.languageModelClientTrialIndices=zeros(1,length(self.trialIDs));
            
            %self.nonLanguageModelTrialIndices=zeros(1,length(self.trialIDs));
            self.specialSymbolIndices=find(strcmp(self.trialLanguageModelSymbols,'*'));
            for(trialIndex=1:length(self.trialIDs))
                temp=find(strcmp(self.trialLanguageModelSymbols(trialIndex),languageModelSymbols));
                if(~isempty(temp))
                    
                    self.languageModelClientTrialIndices(trialIndex)=temp;
                end
                % self.languageModelClientTrialIndices(trialIndex)=
            end
            
            self.languageModelWrapperParameters=languageModelWrapperParameters;
            
            self.lastPosteriorProbs=ones(1,length(self.trialIDs))/length(self.trialIDs);
            self.lastDecided=0;
            self.typingQueue=linkedList;
        end
        
        function p=getProbs(self)
            if(self.languageModelWrapperParameters.languageModelEnabled)
                p=zeros(length(self.trialIDs),1);
                tempProbsLM=exp(-self.languageModelClient.probs*self.languageModelWrapperParameters.LANGUAGEMODELSCALINGHACK);
                
                if(self.typingQueue.elementCount~=0) %No text
                    if(strcmp(self.languageModelWrapperParameters.specialProbCalcType,'fixed'))
                        for(specialIndex=1:length(self.specialSymbolIndices))
                            p(self.specialSymbolIndices(specialIndex))=self.languageModelWrapperParameters.fixedProbability.(self.trialNames{self.specialSymbolIndices(specialIndex)});
                        end
                    elseif(strcmp(self.languageModelWrapperParameters.specialProbCalcType,'adaptive'))
                        deleteSymbolIndex=find(strcmp(self.trialNames,'DeleteCharacter'));
                        tempDeleteSymProb=1-max(self.lastPosteriorProbs);
                        if(~strcmp(self.trialNames{self.lastDecided},'DeleteCharacter'))
                            if(tempDeleteSymProb >= self.languageModelWrapperParameters.adaptiveProbability.DeleteCharacter.upperLimit)
                                p(deleteSymbolIndex)=self.languageModelWrapperParameters.adaptiveProbability.DeleteCharacter.upperLimit;
                            elseif(tempDeleteSymProb <= self.languageModelWrapperParameters.adaptiveProbability.DeleteCharacter.lowerLimit)
                                p(deleteSymbolIndex)=self.languageModelWrapperParameters.adaptiveProbability.DeleteCharacter.lowerLimit;
                            else
                                p(deleteSymbolIndex)=tempDeleteSymProb;
                            end
                        elseif(strcmp(self.trialNames{self.lastDecided},'DeleteCharacter'))
                            p(deleteSymbolIndex)=self.languageModelWrapperParameters.adaptiveProbability.DeleteCharacter.lowerLimit;
                        end
                    end
                end
                
                if(self.lastDecided==0 || ~strcmp(self.trialNames{self.lastDecided},'DeleteCharacter'))
                    
                    %                     for(specialIndex=1:length(self.specialSymbolIndices))
                    %                         p(self.specialSymbolIndices(specialIndex))=self.languageModelWrapperParameters.fixedProbability.(self.trialNames{self.specialSymbolIndices(specialIndex)});
                    %                     end
                    
                    tempProbsnonSpecial=tempProbsLM(self.languageModelClientTrialIndices(self.languageModelClientTrialIndices>0));
                    p(self.languageModelClientTrialIndices>0)=tempProbsnonSpecial/sum(tempProbsnonSpecial)*(1-sum(p));
                    
                else
                    tempProbsnonSpecial=tempProbsLM(self.languageModelClientTrialIndices(self.languageModelClientTrialIndices>0));
                    nonSpecialLoc=self.languageModelClientTrialIndices>0;
                    
                    multiplierP=repmat(self.lastPosteriorProbs(self.lastDecided),size(p));
                    
                    multiplierP(self.specialSymbolIndices)=1;
                    multiplierP(self.lastDeleted)=1-self.lastPosteriorProbs(self.lastDecided);
                    
                    tempProbsnonSpecial=tempProbsnonSpecial.*multiplierP(nonSpecialLoc);
                    
                    p(nonSpecialLoc)=tempProbsnonSpecial./sum(tempProbsnonSpecial)*(1-sum(p));
                    
                    
                    
                    
                end
            else
                p=ones(length(self.trialIDs),1);
                if(self.typingQueue.elementCount==0)
                    p(strcmp(self.trialNames,'DeleteCharacter'))=0;
                end
                p=p/sum(p);
            end
            
        end
        
        function update(self,decision)
            self.lastPosteriorProbs=decision.posteriorProbs;
            self.lastDecided=decision.decided;
            
            if(self.languageModelClientTrialIndices(decision.decided)>0)
                self.languageModelClient.update(self.trialLanguageModelSymbols{decision.decided});
                self.typingQueue.insertEnd(listNode(decision.decided));
                %self.text=[self.text self.trialTexts{decision.decided}];
            else
                if(strcmp(self.trialNames{decision.decided},'DeleteCharacter'))
                    self.languageModelClient.undo();
                    self.lastDeleted=self.typingQueue.Tail.Data;
                    self.typingQueue.remove(self.typingQueue.Tail);
                    %self.text=self.text(1:end-1);
                end
                
                
            end
        end
        
        function text=getText(self)
            text=cell2mat(self.trialTexts(cell2mat(self.typingQueue.toCell)));
            if(isempty(text))
                text='';
            end
            
        end
        
        function reset(self)
            self.languageModelClient.reset;
            self.languageModelClient.alloc;
            self.lastPosteriorProbs=ones(1,length(self.trialIDs))/length(self.trialIDs);
            self.lastDecided=0;
            self.lastDeleted=0;
            self.typingQueue=linkedList;
        end
        
        function initializeState(self,text)
            self.reset;
            for(characterIndex=1:length(text))
                self.languageModelClient.update(self.trialLanguageModelSymbols{strcmp(self.trialTexts,text(characterIndex))});
            end
        end
        
    end
end
