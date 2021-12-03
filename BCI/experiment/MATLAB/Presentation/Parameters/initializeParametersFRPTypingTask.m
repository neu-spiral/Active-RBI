%initializeParametersFRPTypingTask

%% Default Parameters for Experiment Design FRP - Paula.
% This can be commented and the experimenter can applied directly their
% desired parameters. 

% For typing tasks (Spelling, Copy Task, or Mastery Task) three different paradaigms can be applied.  
% * 0 : Not Typing Task (Calibration FRP or Calibration ERP)
% * 1 : Typing Task not using FRP evidences
% * 2 : Typing Task using FRP evidences, and showing a sequence of type 2 (prospect) after each ERP sequence. 
% * 3 : Typing Task using FRP evidences and showing a prospect when reaches the stopping criteria

switch RSVPKeyboardParams.TypingType
    case 0
    case 1
        RSVPKeyboardParams.evidenceEval.evidences={'ERP'};
        RSVPKeyboardParams.evidenceEval.priorities=[1];
    case 2 
        
    case 3
        RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{2}.Typing.minMaxRequiredSequenceCount{1}=[0 inf];
        RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{2}.Typing.MaximumNumberofSequences=6;
end