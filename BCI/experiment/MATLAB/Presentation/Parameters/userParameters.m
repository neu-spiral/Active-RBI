%% Presentation Parameters
%-----------------------------------------------------------------------------------------------------
% Duration (in seconds) and duty cycle of the trials
%
% Default duration is 0.2 second and default duty cycle is 0.75, which means trial symbol will be
% shown for 150 ms followed by a 50 ms blank screen. For the ERP trials it is not safe to set the
% duty cycle to 1.
presentationStruct.Duration.ERPTrial=.2;
presentationStruct.DutyCycle.ERPTrial=.75;

presentationStruct.Duration.ERPMatrixTrial=.2;
presentationStruct.DutyCycle.ERPMatrixTrial=.75;

QueryingType = '4';
taskType = 1;

%%
% Duration (in seconds) and duty cycle of the FRP trials
%
% Default duration is 1 second and default duty cycle is 0.9, which means trial symbol will be
% shown for 0.9s followed by a 0.1s blank screen. For the FRP trials it is not safe to set the
% duty cycle to 1.
presentationStruct.Duration.FRPTrial=1;
presentationStruct.DutyCycle.FRPTrial=.9;

% Duration (in seconds) and duty cycle of the blank screen to separate blocks, and number of trials
% per block to split a sequence into blocks.
presentationStruct.Duration.BlankScreen=1;
presentationStruct.SequenceBreakInterval=5;

% Duration (in seconds) and duty cycle of the decision screen, which shows the decided symbol after
% a decision.
presentationStruct.Duration.Decision=2;
presentationStruct.DutyCycle.Decision=1;

% Default duration is 5 seconds and default duty cycle is 1, which means copyTask target word will be shown
% for 5 seconds with no blank screen following the copyTaskt arget symbol before Initiation of first sequence
% of every new Sentence.
presentationStruct.Duration.copyTaskTarget=5;
presentationStruct.DutyCycle.copyTaskTarget=1;

% Font and Style of the Text
% TextFont should be a string containing the font name. However some fonts might not be available or
% might not show up properly.
% Tested and confirmed fonts: 'Arial' (default), 'Calibri', 'Courier New'
presentationStruct.TextFont='Arial'; 

% TextStyle is a number indicating the style of the text in {0,1,...,7}
%
% * 0 : normal
% * 1 : bold
% * 2 : italic
% * 4 : underline
% * 3 = 1+2 : bold & italic
% 
presentationStruct.TextStyle=0; %0=normal,1=bold,2=italic,4=underline, 1+2=bold&italic
 
% Text size of the stimulus (default = 300), including target, fixation and trials.
presentationStruct.ERPStimulusTextSize=200;
% add comments
presentationStruct.FRPStimulusTextSize=200;

% Colors 
% Colors in RGB.
% 
% * [0,0,0] : Black
% * [255,255,255] : White
% * [0,0,255] : Blue
% * [255,0,0] : Red
% * [0,255,0] : Green
% * [255,255,0]: Yellow
%


% Background color (default : black)
presentationStruct.backgroundColor=[0,0,0];


% Stimulus ERP color (default : white)
presentationStruct.Color.ERPStimulus=[255, 255, 255];

%Stimulus FRP color (default : green)
presentationStruct.Color.FRPStimulus=[0 255 0];


% Target color (default : Yellow)
presentationStruct.Color.Target=[255, 255, 0];


% CopyTask Target color (default : Yellow)
presentationStruct.Color.copyTaskTarget=[255, 255, 0];


% Decision color (default green)
presentationStruct.Color.Decision=[0 255 0];

% Boolean; determines if the decision probability feedback text is visible when a decision is made.
presentationStruct.decisionProbabilityFeedback.isVisible = true; 

% The index of the monitor to use in case multiple monitors are connected. Default (1)
presentationStruct.presentationScreenIndex=1;


% P300MatrixSpeller parameters
% if RSVPKeyboard is operating in matrix mode these parameters will be
% employed to justify matrix appiarance.(Elements size would be the same as
% stimulus textSize.)

% The portion of vertical space on the screen which will be covered by the
% matrix. Other properties will be justified to keep this ratio constant.
presentationStruct.relativeVerticalMatrixSize=.75;
% The minimum distance between matrix items will be applied vertically and
% horizontally. Note that this parameter will override the text size if
% needed.
presentationStruct.minDistanceBetweenMatrixElements=80;
% Other screen elements which are not a part of the matrix (like target, 
% Decision, ...) will be located according the following parameters.
presentationStruct.nonMatrixElementsRelativeVPosition=.5;
presentationStruct.nonMatrixElementsRelativeHPosition=.01;
% Flash color.
presentationStruct.matrixForeColor=[255 255 0];
% Matrix background color.
presentationStruct.matrixBackColor=[50 50 50];

%=====================================================================================================

%% RSVPKeyboard Parameters
%-----------------------------------------------------------------------------------------------------
% Enables or disables the language model. Enabled = 1 (default), Disabled = 0.
RSVPKeyboardParams.languageModelEnabled=1;

% Language model file to use. The model files are stored in btlmserver/models/. Default value is
% 'nyt.200.36char.m6.greg.fromfst.mod'.
RSVPKeyboardParams.languageModel='nyt.200.36char.m6.greg.fromfst.mod';

% Method to calculate the language model probabilities corresponding to special characters, e.g.
% delete character. There are two options 'fixed', which assigns a fixed probability for the
% special characters and 'adaptive', which changes the probability adaptively. In the current
% implementation only Delete character is considered as the special character.
RSVPKeyboardParams.languageModelWrapper.specialProbCalcType='fixed';


% Calibration Parameters
% Number of trials to show per sequence in calibration. This effects the duration of calibration
% session and the target symbol is guaranteed to show up in the sequence.
RSVPKeyboardParams.Calibration.NumberofTrials=5;

% Number of sequences in the calibration. This effects the duration of the calibration session.
RSVPKeyboardParams.Calibration.NumberofSequences=100;
% Maximum number of sequences in the Calibration FRP. This effects the duration of the calibration session.
RSVPKeyboardParams.CalibrationFRP.maxNumberOfSequences=3;
%%
% List of parameters for the list of evidenceEvalObjects 
RSVPKeyboardParams.evidenceEval.evidences={'ERP','FRP'};
%%
% List of priorities of evidences. By default we show first a sequence of
% type 2
RSVPKeyboardParams.evidenceEval.priorities=[2 1];
%%
% Likelihood functions handles for each evidence
RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.Names={'RSVPCalculateLikelihoods','RSVPCalculateLikelihoods'};
% Likelihood functions parameters for each evidence of type {}
RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.params{1}=[];
%%
% Next trial functions handles for each evidence
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.Names={'decideNextTrialsERP','decideNextTrialsFRP'};

% Typing Parameters
% These parameters are valid for the typing sessions, i.e spell, copyphrase, masterytask.

% The maximum/minimum number of sequences of type evidence {} to show in each
% epoch. A decision is made when all the evidences reach the stopping
% criteria of an epoch. 
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{1}.Typing.MaximumNumberofSequences=10;
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{2}.Typing.MaximumNumberofSequences=inf;

%
% The minimum number of sequences to show in each epoch. A decision is not made without showing at
% least this many sequences for each evidence.
%
% * 0 : A decision can be made without showing any trials, if enough confidence is reached using the
% evidence coming from the language model.
% * 1 : At least one sequence will be shown before making any decisions.
% * MaximumNumberofSequences = MinimumNumberofSequences : The number of sequences per epoch is
% constant. No adaptive early decision based on the confidence.
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{1}.Typing.MinimumNumberofSequences=2;
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{2}.Typing.MinimumNumberofSequences=0;
% Allow/not Allow to be first sequence of an epoch of type 2. 
% * 0 : not Allow
% * 1 : Allow
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{2}.Typing.AllowAsFirstSequence=0;

%between type FRP evidences how many minimum and maximum ERP trials
%should we show. 
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{2}.Typing.minMaxRequiredSequenceCount{1}=[1 1];
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{2}.Typing.enforceBeforeDecision=1;
% Use this flag to enforce presence of the backSpace symbol at every
% sequence (0/1).
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{1}.Typing.nextSequenceDecisionRule=QueryingType;
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{1}.Typing.querying.lam = 1;
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{1}.Typing.querying.lamChangeFlag = 1;

RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{1}.Typing.enforceBackSpaceAtEverySequence=1;


% The fixed probability corresponding to the delete symbol. It should take a real value in [0,1].
% The default value is 0.05.
RSVPKeyboardParams.languageModelWrapper.fixedProbability.DeleteCharacter=0.05;

% The maximum value that can be assigned to the delete symbol
RSVPKeyboardParams.languageModelWrapper.adaptiveProbability.DeleteCharacter.upperLimit=0.2;

% The minimum value that can be assigned to the delete symbol
RSVPKeyboardParams.languageModelWrapper.adaptiveProbability.DeleteCharacter.lowerLimit=0.03;

% TCP/IP Communication with the Presentation
% IP and Port address of the main controller side. These shouldn't be changed unless trying to run
% the presentation on a separate computer.
RSVPKeyboardParams.IP_main='localhost';
RSVPKeyboardParams.IP_presentation='localhost';
RSVPKeyboardParams.IP_GUI='localhost';
RSVPKeyboardParams.port_mainAndPresentation=52957;
RSVPKeyboardParams.port_mainAndGUI=52958;

% GUI automatic launch flag
% Determines if the GUI is automatically launched on the same computer as
% the main module, or if it has to be manually launched, which allows it to
% be launched on any computer.
RSVPKeyboardParams.GUI.autoLaunch = true;

% Window Duration for Classification
% The signals are windowed after the stimulus to use the response corresponding to the stimulus. The
% window duration is in seconds. The default value is 0.5.
RSVPKeyboardParams.windowDuration.ERP=0.5;
RSVPKeyboardParams.windowDuration.FRP=0.5;


% Number of trials in a sequence of a typing session. When it is equal to the number of trial
% symbols according to the imageList.xls (28 by default), the whole alphabet is shown. If it is
% lower, which symbols to show is decided according to the nextSequenceDecisionRule.
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{1}.Typing.NumberofTrials=5;

%% Artificial Priors
% Instead of using the prior from the language model an artificial prior
% is used for the FRP Calibration in order to get enought samples from
% postive FRP and negative FRP.  
RSVPKeyboardParams.artificialPriors.probAdjustStep=0.05;
RSVPKeyboardParams.artificialPriors.nonTargetInitialProb=0.4;
RSVPKeyboardParams.artificialPriors.targetInitialProb=0.4;
RSVPKeyboardParams.artificialPriors.numberOfTargetSamples=120;
RSVPKeyboardParams.artificialPriors.numberOfNonTargetSamples=120;
% RSVPKeyboardParams.SupervisedProccesses.optimizationMode is the mode you 
% choose to find parameters. 
% * 0 : Would result in usage of default values for each parameter.
% * 1 : The Nelder-Mead simplex direct search would be employed to find the optimum values for parameters.
% * 2 : Parameters would be optimized by grid search.
RSVPKeyboardParams.SupervisedProccesses.optimizationMode=1;

%% Simulation to estimate the typing performance
% Enables(true)/disables(false) the simulation
RSVPKeyboardParams.Simulation.Enabled=true;

% Hyperparameters to search over during the simulations.
% HyperparameterNames cell vector of strings containing the names of the parameters.
% HyperparameterValues cell vector of real vectors containing the values of the parameters to search
% over.
% Any real value taking parameter can be entered and it should be written without RSVPKeyboardParams
% in the beginning of the parameter name. If there are multiple parameters to search over, they may
% be entered together.
%
% Example; if
% RSVPKeyboardParams.Simulation.HyperparameterNames = {'Typing.MaximumNumberofSequences', 'Typing.NumberofTrials'}
% RSVPKeyboardParams.Simulation.HyperparameterValues = {[1 2 4 8],[14 28]};
% Maximum number of sequences is varied in the set {1,2,4,8} and number of trials is varied in the
% set {14,28}. Correspondingly the simulations are performed for 8 different scenarios.
RSVPKeyboardParams.Simulation.HyperparameterNames = {'Typing.MaximumNumberofSequences'};
RSVPKeyboardParams.Simulation.HyperparameterValues = {[8]};


% 1 if user wants to generate Excel spreadsheet with simulation results.
% The spreadsheet will have a sheet for each field in the simulation
% statistics struct. The hyperparameter values will be gridded and added to
% the sheet as well. The last column will contain the field data. All
% colums will have corresponding names on row 1.
% The filename of the Excel spreadsheet. If empty, the program will
% generate an file called simulationResult.xls with a timestamp
% Excel file is saved in the data folder unless folder name specified in the Folder 
% parameter. The .xls extension is needed in filename
RSVPKeyboardParams.Simulation.ExportToExcel.Enabled = 1;
RSVPKeyboardParams.Simulation.ExportToExcel.Filename = [];
RSVPKeyboardParams.Simulation.ExportToExcel.Folder = [];



% The number of monte carlo simulations. As this number increases, simulations return more stable
% results, however simulations take longer time.
RSVPKeyboardParams.Simulation.MonteCarloRepetitionCount=5;

% Offline Analysis Screen
% Enables (true)/ disables (false) the offline analysis screen.
RSVPKeyboardParams.OfflineAnalysisScreen.Enabled=true;

% Enables (true)/ disables (false) average the target and nontarget ERP plots.
RSVPKeyboardParams.OfflineAnalysisScreen.AverageERPPlotsEnabled=true;

%
% Enables (1)/disables (0) the artifactFiltering process
RSVPKeyboardParams.artifactFiltering.enabled=0; 


% Enables (1)/ disables (0) the "Channel Drop Warning" on the GUI
RSVPKeyboardParams.artifactFiltering.channelDropWarning=0;


% Enables (1)/ disables (0) trial rejection
RSVPKeyboardParams.artifactFiltering.rejectSequence=0;

% Operation mode selection (For now: Matrix or RSVP)
% If the matrixSpellerMode is set to 1 you will work with matrix speller
% and if it is set to 0 you can use RSVPKeyboard.
RSVPKeyboardParams.matrixSpellerMode=0;
% Available options for matrix presentation pradigms are (Row and
% Column)'RC', (Single character flashes) 'Single',...
RSVPKeyboardParams.matrixPresentationParadigm='RC';
% [numberOfRows numberOfColumns] or 'Auto'
RSVPKeyboardParams.matrixSize=[4 7];% [4 7] or 'Auto' are reasonable choices for 28 elements.

%% Default Parameters for Experiment Design FRP - Paula.
% This can be commented and the experimenter can applied directly their
% desired parameters.  

% For typing tasks (Spelling, Copy Task, or Mastery Task) three different paradaigms can be applied.  
% By Default the parameters are set to be typing type 2 and is compatible with ERP and FRP Calibrations sessions.

% * 0 : Not Typing Task (Calibration FRP or Calibration ERP). 
% * 1 : Typing Task not using FRP evidences
% * 2 : Typing Task using FRP evidences, and showing a sequence of type 2 (prospect) after each ERP sequence. 
% * 3 : Typing Task using FRP evidences and showing a prospect when reaches the stopping criteria

 RSVPKeyboardParams.TypingType=taskType;


  initializeParametersFRPTypingTask;

%=====================================================================================================




