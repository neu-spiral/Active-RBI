%% [completedFlag,correctSection,incorrectSection]=checkTypingCorrectness(targetPhrase,typedPhrase)
%checkTypingCorrectness(targetPhrase,typedPhrase)function checks the
% correctness of the phrase which have been typed so far.
%
%   The inputs of the function
%      targetPhrase - This input is a string of what the algorithm is about
%      to type.
%
%      typedPhrase - This input is a string of what has been typed so far.
%
%
%   The outputs of the function
%      completedFlag - This output is a flag which will show if the phrase
%      is complete or not.
%
%      correctSection - This output is a string of correctly typed part of
%      phrase.
%
%      incorrectSection - This output is a part of targetPhrase begins with
%      the location of the first error which occures in typedPhrase to the
%      end of the targetPhrase.
%

%%
function [completedFlag,correctSection,incorrectSection]=checkTypingCorrectness(targetPhrase,typedPhrase)
%% Determining correctSection and incorrectSection
L=min(length(targetPhrase),length(typedPhrase));

firstIncorrect=find((targetPhrase(1:L)~=typedPhrase(1:L)),1);

if(isempty(firstIncorrect))
correctSection=typedPhrase(1:L);
incorrectSection='';
else
    correctSection=typedPhrase(1:firstIncorrect-1);
    incorrectSection=typedPhrase(firstIncorrect:end);
end
%% Determining the completness of the phrase.
completedFlag=(length(correctSection)==length(targetPhrase));