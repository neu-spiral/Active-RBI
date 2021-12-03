function query_set = ActiveQuerying(symbol_set, priorProbs, posteriorHistory, param)
% Rough implementation of active query method including MMI, momentum and 
% the proposed mix method for RSVPKeyboard MATLAB version Dec 2016.
% Requires hist iformation different than other querying methods.
% 
% Args:
%   symbol_set[str]: Symbol set of the application
%   priorProbs(float[1 x k]): Posterior distribution over the alphabet
%   posteriorHistory: Sequence hist?
%   param: parameters
%       .Typing.NumberofTrials(int): Number of trials in a sequence
%       .Typing.momentum.lam(float): Lambda value for query selection, it
%       should be between 0 and 1 
%
% Return:
%   activeFlag[bool]: Flag denoting this querying can be used.
%   nextSequence[struct] :
%       .trials(int[1 x m]): integers denoting letters in query
%       .target(int): index of the target symbol(?)
%

posteriorHistory = posteriorHistory.';  
numSeq = size(posteriorHistory,1) - 1;
eps = 1e-5;
entropy_term = priorProbs.*log(priorProbs+eps) + (1 + eps - priorProbs).*log(1 + eps - priorProbs);
    
if param.Typing.querying.lamChangeFlag
    if numSeq < 5
        param.Typing.querying.lam = max(param.Typing.querying.lam/(5*numSeq+1), 0);
    else
        param.Typing.querying.lam = 0;
    end
    
end

if numSeq < 1;
    objective = -entropy_term; 
else    
    momentum_term = (1/numSeq)*sum( posteriorHistory(1:end-1,:).*log((posteriorHistory(2:end,:)./(posteriorHistory(1:end-1,:)+eps))+eps ), 1 );
    objective = (param.Typing.querying.lam - 1)*entropy_term + param.Typing.querying.lam * momentum_term.';
end

[~,sorted_alp] = sort(objective,'descend');
query_set = symbol_set(sorted_alp(1:param.Typing.NumberofTrials));
query_set = query_set(randperm(length(query_set)));

% query_set = ones(1,param.Typing.NumberofTrials);

end

