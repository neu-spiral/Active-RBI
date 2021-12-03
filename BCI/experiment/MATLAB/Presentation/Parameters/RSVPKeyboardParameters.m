DeveloperMode=0;
%% RSVPKeyboardParameters
% Parameter file for the general operation of RSVPKeyboard

%% Mode of acquisition system.
% Available options are 'gUSBAmp' and 'noAmp'.
%
% * 'gUSBAmp': Acquires data from gTec's g.USBAmp amplifier
% * 'noAmp' : Uses no amplifiers to record. It generates artificial signals or can play a previously
% recorded '.daq' file from gTec's g.USBAmp amplifier
% * 'DSI' :  Acquires data from DSI amplifier
% * noAmpDSI: Uses no amplifiers to record. It generates artificial signals or can play a previously
% recorded '.daq' file from DSI amplifier
RSVPKeyboardParams.DAQType='DSI';
RSVPKeyboardParams.IsDataCollection=1;

RSVPKeyboardParams.IRBString2Append='_IRB130107';

QueryingType = '4';
taskType = 1;

%% Operation mode selection (For now: Matrix or RSVP)
% If the matrixSpellerMode is set to 1 you will work with matrix speller
% and if it is set to 0 you can use RSVPKeyboard.
RSVPKeyboardParams.matrixSpellerMode=0;
% Available options for matrix presentation pradigms are (Row and
% Column)'RC', (Single character flashes) 'Single',...
RSVPKeyboardParams.matrixPresentationParadigm='Single';
% [numberOfRows numberOfColumns] or 'Auto'
RSVPKeyboardParams.matrixSize=[4 7];% [4 7] or 'Auto' are reasonable choices for 28 elements.

%% List of I/O ports to use in parallel port communication.
% The program will send triggers to all of these ports. If there is a new device or new computer,
% please check the port from the Resources of the device in Device Manager.
RSVPKeyboardParams.parallelPortIOList={'auto','3000','2020','2FD8','4FD8'};%'auto' checks parallel port in device manager ports (COM & LPT)resources 

%% Language Model
% Enables or disables the language model. Enabled = 1 (default), Disabled = 0.
RSVPKeyboardParams.languageModelWrapper.languageModelEnabled=1;

%%
% Language model file to use. The model files are stored in btlmserver/models/. Default value is
% 'nyt.200.36char.m6.greg.fromfst.mod'.
RSVPKeyboardParams.languageModel='nyt.200.36char.m6.greg.fromfst.mod';

%%
% Method to calculate the language model probabilities corresponding to special characters, e.g.
% delete character. There are two options 'fixed', which assigns a fixed probability for the
% special characters and 'adaptive', which changes the probability adaptively. In the current
% implementation only Delete character is considered as the special character.
RSVPKeyboardParams.languageModelWrapper.specialProbCalcType='fixed';

%%
% The fixed probability corresponding to the delete symbol. It should take a real value in [0,1].
% The default value is 0.05.
RSVPKeyboardParams.languageModelWrapper.fixedProbability.DeleteCharacter=0.05;

%%
% The maximum value that can be assigned to the delete symbol
RSVPKeyboardParams.languageModelWrapper.adaptiveProbability.DeleteCharacter.upperLimit=0.2;

%%
% The minimum value that can be assigned to the delete symbol
RSVPKeyboardParams.languageModelWrapper.adaptiveProbability.DeleteCharacter.lowerLimit=0.03;

%%
% Language model scaling factor in $[0,\infty)$.
% It takes the power of the probabilities obtained from the language model by the given factor.
% Lower the number closer to giving equal probability for each symbol.
%
% * 1 : No modification on the language model probabilities
% * 0: The probabilities coming from the language model are made equal
% * 0.5 : Takes the square root of the probabilities that makes the probabilities closer to each
% other. (used in v1.3)
%
RSVPKeyboardParams.languageModelWrapper.LANGUAGEMODELSCALINGHACK=0.5;

%% Modules
RSVPKeyboardParams.modules = {'Presentation','GUI'};

%% Presentation
% Parameters that affect the remote presentation

%%
% TCP/IP Communication with the Presentation
% IP and Port address of the main controller side. These shouldn't be changed unless trying to run
% the presentation on a separate computer.
RSVPKeyboardParams.IP_main='localhost';
RSVPKeyboardParams.IP_presentation='localhost';
RSVPKeyboardParams.IP_GUI='localhost';
RSVPKeyboardParams.port_mainAndPresentation=52957;
RSVPKeyboardParams.port_mainAndGUI=52958;

%% GUI
% Parameters pertaining to the remote GUI

%%
% GUI automatic launch flag
% Determines if the GUI is automatically launched on the same computer as
% the main module, or if it has to be manually launched, which allows it to
% be launched on any computer.
RSVPKeyboardParams.GUI.autoLaunch = true;

%%
% GUI stream flag
% Determines the nature of the data being sent to the GUI
RSVPKeyboardParams.GUI.NO_DATA = 1; % No data being sent.
RSVPKeyboardParams.GUI.RAW_DATA = 2; % Raw data being sent.
RSVPKeyboardParams.GUI.FILTERED_DATA = 3; % Filtered data being sent.
RSVPKeyboardParams.GUI.AM_DATA = 4; % Attention monitoring data being sent.

%% Trigger Offset Constant
% Trigger offset added to the trigger of the target symbol. For example, if a symbol has a trigger value of 5 when it is shown as a trial,
% it has a trigger value of 128+5 when it is shown as a target. This shouldn't be changed. Default
% value is 128.
RSVPKeyboardParams.TARGET_TRIGGER_OFFSET=128;

%% Window Duration for Classification
% The signals are windowed after the stimulus to use the response corresponding to the stimulus. The
% window duration is in seconds. The default value is 0.5.
RSVPKeyboardParams.windowDuration.ERP=0.5;
RSVPKeyboardParams.windowDuration.FRP=0.5;

%% Calibration Parameters
% Number of trials to show per sequence in calibration. This effects the duration of calibration
% session and the target symbol is guaranteed to show up in the sequence.
RSVPKeyboardParams.Calibration.NumberofTrials=5;

%%
% Number of sequences in the calibration. This effects the duration of the calibration session.
RSVPKeyboardParams.Calibration.NumberofSequences=10;
% Maximum number of sequences in the Calibration FRP. This effects the duration of the calibration session.
RSVPKeyboardParams.CalibrationFRP.maxNumberOfSequences=3;

%% Typing Parameters
% These parameters are valid for the typing sessions, i.e spell, copyphrase, masterytask.

%%
% The maximum number of sequences to show in each epoch. A decision is made after showing this many
% sequences, if a decision is not made earlier by reaching to enough confidence level.
%RSVPKeyboardParams.Typing.MaximumNumberofSequences=8;

%%
% The minimum number of sequences to show in each epoch. A decision is not made without showing at
% least this many sequences.
%
% * 0 : A decision can be made without showing any trials, if enough confidence is reached using the
% evidence coming from the language model.
% * 1 : At least one sequence will be shown before making any decisions.
% * MaximumNumberofSequences = MinimumNumberofSequences : The number of sequences per epoch is
% constant. No adaptive early decision based on the confidence.
%RSVPKeyboardParams.Typing.MinimumNumberofSequences=1;

%%
% Confidence function to calculate the confidence. Given function (default: @max) is applied on the
% posterior probabilities to obtain the confidence value.
RSVPKeyboardParams.Typing.ConfidenceFunction=@max;

%%
% Confidence threshold to stop the epoch and make a decision. Default value is 0.9.
% If max(posteriorProbabilities)>0.9, a decision is made and epoch is finished.
RSVPKeyboardParams.Typing.ConfidenceThreshold=2/3;


%%
% The rule to make the fusion.
% 1: Old
% 2: New
RSVPKeyboardParams.FusionRule=2;

%% Phrase stopping criteria
% For copy phrase and mastery tasks, there exists stopping criteria to stop the typing of the
% current phrase and continue with the next phrase if there exists one.

%%
% Maximum allowed duration for a phrase excluding the wait times between sequences in seconds.
RSVPKeyboardParams.copyphrase.StoppingCriteria.MaximumEstimatedPhraseTime=450;

%%
% The scale for the upper limit on the number of sequences based for the copy tasks.
% The typing of the phrase stops when
% $\textrm{number of sequences spent on the phrase} \geq \textrm{SequenceLimitScale} \times
% \textrm{number of characters in the target phrase} \times  \textrm{MaximumNumberofSequences}$.
% Default value is 2.
RSVPKeyboardParams.copyphrase.StoppingCriteria.SequenceLimitScale=2;

%%
% Maximum allowed number of consecutive incorrect decisions for a phrase.
% Default value is 5.
RSVPKeyboardParams.copyphrase.StoppingCriteria.MaximumLengthOfIncorrectSection=5;

%% Mastery task level completion criteria
% A level in the mastery task is completed if at least this ratio of the phrases in a set are completed
% successfully. If the |LevelCompletionThreshold| is exceeded in any set, the level is completed.
% Otherwise the level continues to show all the sets repeatedly.
RSVPKeyboardParams.masteryTask.LevelCompletionThreshold=2/3;

%% Feature Extraction Methodology
% List of operators to use in the ProcessFlow of the feature extraction. The handles corresponding
% to the class names of the operators should be listed as a cell vector.

% Recursive process flow elements
%Notice that running a previousely collected calibration to obtain the
%RecursiveUpdate calibration is a computationally heavy task and it takes
%about 27 minutes to run over one of the routine calibrations.
RSVPKeyboardParams.formRecursiveProcessflow = 0;

% A flag to control whether a calibration file should be loaded to
% initialize the recursive classifier or not.
RSVPKeyboardParams.loadRecursiveCalibrationFile = true;

RSVPKeyboardParams.RecursiveUnsupervisedProccesses.operatorHandles={@downsampleObject};
RSVPKeyboardParams.RecursiveSupervisedProccesses.operatorHandles={@ghm};

RSVPKeyboardParams.RecursiveUnsupervisedProccesses.operationParameters{1} = {};
RSVPKeyboardParams.RecursiveSupervisedProccesses.operationParameters{1}.initializationMethod = 'RDA';
RSVPKeyboardParams.RecursiveSupervisedProccesses.operationParameters{1}.storelastTrialDataFlag = 1;

RSVPKeyboardParams.RecursiveUnsupervisedProccesses.operationModes = 2;
RSVPKeyboardParams.RecursiveSupervisedProccesses.operationModes = 0;

RSVPKeyboardParams.RecursiveSupervisedProccesses.optimizationMode=0;


% Static process flow elements
RSVPKeyboardParams.UnsupervisedProccesses.operatorHandles={@downsampleObject, @pca};
RSVPKeyboardParams.SupervisedProccesses.operatorHandles={@rda};

%%
% List of the operation modes of each operator.
%
% * 0 : Concatenate all the data as a single feature vector before applying the operator.
% * 1 : Apply the feature extraction along the first dimension for each of the other dimensions.
% Initially it is applied over spatial samples.
% * 2 : Apply the feature extraction along the second dimension for each of the other dimensions.
% Initially it is applied over time samples.
%
% Example; [2 2 0] means first and second operator is applied for each channel separately, third
% operator is applied over the full feature vector.
RSVPKeyboardParams.UnsupervisedProccesses.operationModes=[2 2];
RSVPKeyboardParams.SupervisedProccesses.operationModes=0;


%%
% List of parameters corresponding to each operator. It is a cell vector containing the parameters
% as a structure for each operator.
% RSVPKeyboardParams.FeatureExtraction.operationParameters{2}.minimumRelativeEigenvalue corresponds
% to the minimumRelativeEigenvalue parameter of the second operator.
RSVPKeyboardParams.UnsupervisedProccesses.operationParameters{2}.minimumRelativeEigenvalue=1e-5;

%%
% Values assigned to each parameter in supervised proccess contains 
% [minimum allowed value , maximum allowed value , reasonable initial point for Nelder-Mead simplex direct search method] 
RSVPKeyboardParams.SupervisedProccesses.operationParameters{1}.lambda=[0,1,0.9];
RSVPKeyboardParams.SupervisedProccesses.operationParameters{1}.gamma=[0,1,0.1];

% Grid search resolution for optimizable parameters in supervised
% proccesses.
RSVPKeyboardParams.SupervisedProccesses.operationParameters{1}.gridResolution.lambda=0.2;
RSVPKeyboardParams.SupervisedProccesses.operationParameters{1}.gridResolution.gamma=0.2;

% RSVPKeyboardParams.SupervisedProccesses.optimizationMode is the mode you 
% choose to find parameters. 
% * 0 : Would result in usage of default values for each parameter.
% * 1 : The Nelder-Mead simplex direct search would be employed to find the optimum values for parameters.
% * 2 : Parameters would be optimized by grid search.
RSVPKeyboardParams.SupervisedProccesses.optimizationMode=1;

%% Cross Validation
% Cross validation fold count. Default value is 10, which applies a 10-fold cross validation.
RSVPKeyboardParams.CrossValidation.K=10;

%%
% The partitioning type of the cross validation. The possible values are
%
% * Uniform : Folds consist of contiguous trial blocks.
% * Random : Trials are selected to folds randomly without replacement.
%
RSVPKeyboardParams.CrossValidation.partitioningType='Uniform';

%% Simulation to estimate the typing performance
% Enables(true)/disables(false) the simulation
RSVPKeyboardParams.Simulation.Enabled=true;

%%
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
RSVPKeyboardParams.Simulation.HyperparameterNames = {'evidenceEval.nextTrialFunctions.params{1}.Typing.MaximumNumberofSequences'};
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
RSVPKeyboardParams.Simulation.ExportToExcel.Enabled = 0;
RSVPKeyboardParams.Simulation.ExportToExcel.Filename = [];
RSVPKeyboardParams.Simulation.ExportToExcel.Folder = [];

%%
% The number of monte carlo simulations. As this number increases, simulations return more stable
% results, however simulations take longer time.
RSVPKeyboardParams.Simulation.MonteCarloRepetitionCount=5;

%% Offline Analysis Screen
% Enables (true)/ disables (false) the offline analysis screen.
RSVPKeyboardParams.OfflineAnalysisScreen.Enabled=true;

%%
% Enables (true)/ disables (false) average the target and nontarget ERP plots.
RSVPKeyboardParams.OfflineAnalysisScreen.AverageERPPlotsEnabled=true;

%%
% Enables(true)/disables(false) the artifactFiltering process
RSVPKeyboardParams.artifactFiltering.enabled=0; 

%%
% Enables (true)/ disables (false) the "Channel Drop Warning" on the GUI
RSVPKeyboardParams.artifactFiltering.channelDropWarning=0;

%%
% Enables (true)/ disables (false) trial rejection
RSVPKeyboardParams.artifactFiltering.rejectSequence=0;

%%
% List of parameters for the list of evidenceEvalObjects 
RSVPKeyboardParams.evidenceEval.evidences={'ERP','FRP'};

%%
% List of priorities of evidences. By default we show first a sequence of
% type 2. 
RSVPKeyboardParams.evidenceEval.priorities=[2 1];

%%
% Likelihood functions handles for each evidence
RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.Names={'RSVPCalculateLikelihoods','RSVPCalculateLikelihoods'};
% Likelihood functions parameters for each evidence of type {}
RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.params{1}=[];

%%
% Next trial functions handles for each evidence
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.Names={'decideNextTrialsERP','decideNextTrialsFRP'};

% The maximum/minimum number of sequences of type evidence {} to show in each
% epoch. A decision is made when all the evidences reach the stopping
% criteria of an epoch. 
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{1}.Typing.MaximumNumberofSequences=10;
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{1}.Typing.MinimumNumberofSequences=2;
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{2}.Typing.MaximumNumberofSequences=inf;
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{2}.Typing.MinimumNumberofSequences=0;

% Allow/not Allow to be first sequence of an epoch of type 2. 
% * 0 : not Allow
% * 1 : Allow
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{2}.Typing.AllowAsFirstSequence=0;
% Confidence threshold to show a sequence of type 2. Default value is 0.6.
% If max(posteriorProbabilities)>0.6, a sequence of type 2 is shown to the
% user.
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{2}.Typing.ConfidenceThreshold=2/3;

% Between type evidence 2, how many minimum and maximum sequences of type
% evidence 1 can be shown. 
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{2}.Typing.minMaxRequiredSequenceCount{1}=[1 1];

% Enforce to show a sequence of type {} before a decision is made
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{2}.Typing.enforceBeforeDecision=1;


%%
% The method to use for deciding which symbols to show in the next sequence. The trial symbols to
% show in a sequence are selected from possible symbol set using one of the following options
%
% * 'Random' : Randomly without replacement.
% * 'Posterior' : Using the top symbols according to the posterior probabilities calculated after
% the last sequence which was shown. The posterior probabilities change as more EEG evidence
% collected.
%
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{1}.Typing.nextSequenceDecisionRule=QueryingType;
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{1}.Typing.querying.lam = 1;
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{1}.Typing.querying.lamChangeFlag = 1;

% params.Typing.querying.lamChangeFlag
RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{1}.Typing.enforceBackSpaceAtEverySequence=1;

% Number of trials in a sequence of type {} of a typing session. When it is equal to the number of trial
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

% Number of positive FRP and negative FRP in the FRP calibration. This effects the duration of the calibration session.
RSVPKeyboardParams.artificialPriors.numberOfTargetSamples=120;
RSVPKeyboardParams.artificialPriors.numberOfNonTargetSamples=120;

%% Default Parameters for Experiment Design FRP - Paula.
% This can be commented and the experimenter can applied directly their
% desired parameters. 

% For typing tasks (Spelling, Copy Task, or Mastery Task) three different paradaigms can be applied.  
% By Default the parameters are set to be typing type 2 and is compatible with ERP and FRP Calibrations sessions.

% * 0 : Not Typing Task (Calibration FRP or Calibration ERP)
% * 1 : Typing Task not using FRP evidences
% * 2 : Typing Task using FRP evidences, and showing a sequence of type 2 (prospect) after each ERP sequence. 
% * 3 : Typing Task using FRP evidences and showing a prospect when reaches the stopping criteria

% RSVPKeyboardParams.TypingType=2;

% if(isfield(RSVPKeyboardParams,'TypingType'))
%     initializeParametersFRPTypingTask;
% end

%% Attention Monitoring - Asieh
% RSVPKeyboardParams.attentionMonitoring.enabled=1;
% RSVPKeyboardParams.attentionMonitoring.useArtifactFilteringData=1;
% RSVPKeyboardParams.attentionMonitoring.processWindowLength=3;

RSVPKeyboardParams.languageModelOld=true;
RSVPKeyboardParams.dockerScriptPath='.\@lm\dockerRun.bat';

%% Over writing user parameter values.
if ~DeveloperMode
    userParamsCallMode='%% RSVPKeyboard Parameters';
    loadUserParams
end
