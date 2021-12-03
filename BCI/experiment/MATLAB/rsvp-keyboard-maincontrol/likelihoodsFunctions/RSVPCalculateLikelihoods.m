function [y,orderedVocabLabels] =RSVPCalculateLikelihoods( x,trialLabels,orderedVocabLabels,params)
%% compute the likelihoods of the scores

%% Inputs:
% x: scores (vector)
% trial Labels: the labels of the trials (vector of indices)
% orderedVocabLabels:  vector of symbol IDs which are allowed to
% stimulus
% params: additional parameters
%          * params.scoreStruct:  A calibration file containing the kernel density estimators.
%          * params.isCalibration: A boolean indicating if the session ID is calibration for that evidence.
%% Outputs:
% y: likelihoods of each score for the target class and non target class.
% ordered Labels: a vector containing all the IDs labels which are allowed to be stimulus.

if isfield(params,'isCalibration') && ~params.isCalibration
    if (isfield(params,'isMatrix') && (~params.isMatrix)) || ~iscell(trialLabels)
        y=nan(length(orderedVocabLabels),2);
        for(trialIndex=1:length(trialLabels))
            
            pT=params.scoreStruct.conditionalpdf4targetKDE.probs(x(trialIndex));
            pN=params.scoreStruct.conditionalpdf4nontargetKDE.probs(x(trialIndex));
            
            if(trialLabels(trialIndex)<=length(orderedVocabLabels))
                
                if(params.scoreStruct.probThresholdTarget < pT || params.scoreStruct.probThresholdNontarget < pN)
                    
                    y(trialLabels(trialIndex),1)=(log(pT));
                    y(trialLabels(trialIndex),2)=(log(pN));
                end
            end
        end
    else
        y=nan(length(orderedVocabLabels),2);
        for(trialIndex=1:length(trialLabels))
            currentTrialLabelSet=trialLabels{trialIndex};
            pT=params.scoreStruct.conditionalpdf4targetKDE.probs(x(trialIndex));
            pN=params.scoreStruct.conditionalpdf4nontargetKDE.probs(x(trialIndex));
            if(params.scoreStruct.probThresholdTarget < pT || params.scoreStruct.probThresholdNontarget < pN)
                
                for trialIds=1:length(currentTrialLabelSet)
                    if isnan(y(orderedVocabLabels(currentTrialLabelSet(trialIds)),1))
                        y(orderedVocabLabels(currentTrialLabelSet(trialIds)),1)=(log(pT));
                    else
                        y(orderedVocabLabels(currentTrialLabelSet(trialIds)),1)=y(orderedVocabLabels(currentTrialLabelSet(trialIds)),1)+(log(pT));
                    end
                    
                    if isnan(y(orderedVocabLabels(currentTrialLabelSet(trialIds)),2))
                        y(orderedVocabLabels(currentTrialLabelSet(trialIds)),2)=(log(pN));
                    else
                        y(orderedVocabLabels(currentTrialLabelSet(trialIds)),2)=y(orderedVocabLabels(currentTrialLabelSet(trialIds)),2)+(log(pN));
                    end
                    
                end
                
            end
            
        end
    end
else
    if (params.sessionID == 6) % RecursiveCalibration
        if (isfield(params,'isMatrix') && (~params.isMatrix)) || ~iscell(trialLabels)
            y=nan(length(orderedVocabLabels),2);
            for(trialIndex=1:length(trialLabels))
                
                pT=x(trialIndex);
                pN=ones(size(x(trialIndex)));%params.scoreStruct.conditionalpdf4nontargetKDE.probs(x(trialIndex));
                
                if(trialLabels(trialIndex)<=length(orderedVocabLabels))
                    
%                     if(params.scoreStruct.probThresholdTarget < pT || params.scoreStruct.probThresholdNontarget < pN)
                        
                        y(trialLabels(trialIndex),1)=(log(pT));
                        y(trialLabels(trialIndex),2)=(log(pN));
%                     end
                end
            end
        else
            y=nan(length(orderedVocabLabels),2);
            for(trialIndex=1:length(trialLabels))
                currentTrialLabelSet=trialLabels{trialIndex};
                pT=x(trialIndex);
                pN=ones(size(x(trialIndex)));
%                 if(params.scoreStruct.probThresholdTarget < pT || params.scoreStruct.probThresholdNontarget < pN)
                    
                    for trialIds=1:length(currentTrialLabelSet)
                        if isnan(y(orderedVocabLabels(currentTrialLabelSet(trialIds)),1))
                            y(orderedVocabLabels(currentTrialLabelSet(trialIds)),1)=(log(pT));
                        else
                            y(orderedVocabLabels(currentTrialLabelSet(trialIds)),1)=y(orderedVocabLabels(currentTrialLabelSet(trialIds)),1)+(log(pT));
                        end
                        
                        if isnan(y(orderedVocabLabels(currentTrialLabelSet(trialIds)),2))
                            y(orderedVocabLabels(currentTrialLabelSet(trialIds)),2)=(log(pN));
                        else
                            y(orderedVocabLabels(currentTrialLabelSet(trialIds)),2)=y(orderedVocabLabels(currentTrialLabelSet(trialIds)),2)+(log(pN));
                        end
                        
                    end
                    
%                 end
                
            end
        end
    else
        
        y=zeros(length(orderedVocabLabels),2);
        
    end
    
end


