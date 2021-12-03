%% [meanAuc, stdAuc]=calculateAuc(scores,trueClass,crossValidationPartitioning,K,positiveClass)
%calculateAuc(scores,trueClass,crossValidationPartitioning,K,positiveClass)
% function calculates the AUC of the Cross-Validation.
%
%   The inputs of the function
%      scores - This is the vector of scores out of the classifier
%      associated with the labels cassifier has determined.
%
%      trueClass - This input is the vector of true class of points.
%
%      crossValidationPartitioning - This input is a vector which represent
%      which partition each point belong to.
%
%      K - This input is a scaler which determines the number of folds.
%
%      positiveClass - This input is a vector determining the classes which
%      should be treated as positive class.
%
%
%   The outputs of the function
%      meanAuc - This ouput is scaler representing the mean value of AUC.
%
%      stdAuc - This ouput is scaler representing the standard deviation 
%      value of AUC.
%
%  

function [meanAuc, stdAuc]=calculateAuc(scores,trueClass,crossValidationPartitioning,K,positiveClass)
%% Sub Module #1, Checking the number of parametes in function input.
% this part of the function would check the number of input parameters and
% would set the function to to oprate in an apropriate condotion by setting
% some deffult values.
N=length(trueClass);                                    
if(nargin<3)
    crossValidationPartitioning=ones(1,N);
    K=1;
elseif(nargin<4)
    K=length(unique(crossValidationPartitioning));
end
if(nargin<5)
    classes=unique(trueClass);
    if(any(classes==1))
        positiveClass=1;
    elseif(any(classes==true))
        positiveClass=true;
    else
        positiveClass=1;
    end 
end
%% Sub Module #2, AUC calculation
if(ischar(positiveClass))
    trueClass=strcmpi(positiveClass,trueClass);
else
trueClass=trueClass==positiveClass;
end

aucs = zeros(1,K);

for(k=1:K)
    valSet=(crossValidationPartitioning==k);
    tempScores=scores(valSet);
    
    
    [~,I]=sort(tempScores,'descend');
    tempTrueClass=trueClass(valSet);
    tempTrueClass=tempTrueClass(I);
    % swipping the threshold.
    N=length(tempScores);
    cT=cumsum(tempTrueClass);
    cF=cumsum(~tempTrueClass);
    
    tprs=[0 cT]./cT(end);
    fprs=[0 cF]./cF(end);
    aucs(k)=trapz(fprs,tprs);
    
end

meanAuc=mean(aucs);
stdAuc=std(aucs);


