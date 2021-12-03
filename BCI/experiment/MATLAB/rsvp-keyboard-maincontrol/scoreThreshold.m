%% scoreThreshold(scores,sigma,totalPThreshold) 
% calculates threshold for accepting scores. That means scores less than 
% that threshold won't be useful for our decision making. This threshold is
% defined as the score that integral of distribution function of sorted 
% scores that is more than that score, is equal to totalPThreshold.
%
%   The inputs of the function
%      scores - a vector that can be target scores or non target scores
%      sigma - kernel width for kernel density estimation.
%      totalPThreshold - a predefined parameter that is reflective of the
%      percentage of the accepted area of scores to be target or non-target
%      
%   The outputs of the function
%      th - a number that shows the maximum acceptance of a vector of scores.
%
%  See also kde1d.
%%
function th=scoreThreshold(scores,sigma,totalPThreshold)
minScore=min(scores);
maxScore=max(scores);
%N=length(scores);

delta=sigma/2;
x=(minScore-3*sigma):delta:(maxScore+3*sigma);
kdeObj=kde1d(scores);
px=kdeObj.probs(x);

[sortedpx,I]=sort(px,'descend');
Px=cumsum(sortedpx*delta);

Ith=find(Px>totalPThreshold,1);
th=sortedpx(Ith);

end