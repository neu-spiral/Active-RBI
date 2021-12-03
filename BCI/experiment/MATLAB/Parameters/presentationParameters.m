DeveloperMode=0;
%% presentationParameters
% Parameter file corresponding to presentation.

%% General Screen Information
% The index of the monitor to use in case multiple monitors are connected. Default (1)
presentationStruct.presentationScreenIndex=1;

%%
% Parameter to start the presentation as full screen or not. 
% 
% * 0 : Windowed
% * 1 : Full screen
%
presentationStruct.fullScreenFlag=1;

%% P300MatrixSpeller parameters
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


%% 
% Parameter to lock the keyboard such that only Psychtoolbox reads the keyboard input. (1 (default): Lock, 0 : Do not lock)
presentationStruct.lockKeyboard=1;

%% Presentation Durations and Duty Cyycles
% Duration (in seconds) and duty cycle of the target symbol for calibration
%
% Default duration is 2 seconds and default duty cycle is 1, which means target symbol will be shown
% for 2 seconds with no blank screen following the target symbol.
presentationStruct.Duration.Target=2;
presentationStruct.DutyCycle.Target=1;

presentationStruct.Duration.FRPTarget=0.1;
presentationStruct.DutyCycle.FRPTarget=.9;

%%
% Default duration is 5 seconds and default duty cycle is 1, which means copyTask target word will be shown
% for 5 seconds with no blank screen following the copyTaskt arget symbol before Initiation of first sequence
% of every new Sentence.
presentationStruct.Duration.copyTaskTarget=5;
presentationStruct.DutyCycle.copyTaskTarget=1;


%%
% Duration (in seconds) and duty cycle of the fixation cross
%
% Default duration is 1 second and default duty cycle is 1, which means fixation will be shown
% for 1 second with no black screen following the fixation symbol.
presentationStruct.Duration.Fixation=1;
presentationStruct.DutyCycle.Fixation=1;
%% 
% Duration (in seconds) and duty cycle of the sequence bgin (black screen) 
%
% Default duration is 0.1 second and default duty cycle is 1, which means a
% black screen wil be shown before each sequence during 0.1 seconds. 
presentationStruct.Duration.SequenceBegin=.1;
presentationStruct.DutyCycle.SequenceBegin=1;

%%
% Duration (in seconds) and duty cycle of the ERP trials
%
% Default duration is 0.2 second and default duty cycle is 0.75, which means trial symbol will be
% shown for 150 ms followed by a 50 ms blank screen. For the ERP trials it is not safe to set the
% duty cycle to 1.
presentationStruct.Duration.ERPTrial=.2;
presentationStruct.DutyCycle.ERPTrial=.75;

presentationStruct.Duration.ERPMatrixTrial=.2;
presentationStruct.DutyCycle.ERPMatrixTrial=.75;

%%
% Duration (in seconds) and duty cycle of the FRP trials
%
% Default duration is 1 second and default duty cycle is 0.9, which means trial symbol will be
% shown for 0.9s followed by a 0.1s blank screen. For the FRP trials it is not safe to set the
% duty cycle to 1.
presentationStruct.Duration.FRPTrial=1;
presentationStruct.DutyCycle.FRPTrial=.9;


%% 
% Duration (in seconds) and duty cycle of the blank screen to separate blocks, and number of trials
% per block to split a sequence into blocks.
presentationStruct.Duration.BlankScreen=1;
presentationStruct.DutyCycle.BlankScreen=1;
presentationStruct.SequenceBreakInterval=14;

%%
% Duration (in seconds) and duty cycle of the mastery task level complete sign.
presentationStruct.Duration.LevelUpSign=3;
presentationStruct.DutyCycle.LevelUpSign=1;

%%
% Duration (in seconds) and duty cycle of the sequence end trigger pulse. It is only useful for trigger purposes
% to mark the end of a sequence.
presentationStruct.Duration.SequenceEnd=0.3;
presentationStruct.DutyCycle.SequenceEnd=1;

%%
% Duration (in seconds) and duty cycle of the decision screen, which shows the decided symbol after
% a decision.
presentationStruct.Duration.Decision=2;
presentationStruct.DutyCycle.Decision=1;

%%
% Duration (in seconds) and duty cycle of the pause screen which listens to keyboard to continue. These
% durations indicate the periodic flashes of the pause screen.
presentationStruct.Duration.activePauseBar=1;
presentationStruct.DutyCycle.activePauseBar=0.5;

%% Font and Style of the Text
% TextFont should be a string containing the font name. However some fonts might not be available or
% might not show up properly.
% Tested and confirmed fonts: 'Arial' (default), 'Calibri', 'Courier New'
presentationStruct.TextFont='Arial'; 

%%
% TextStyle is a number indicating the style of the text in {0,1,...,7}
%
% * 0 : normal
% * 1 : bold
% * 2 : italic
% * 4 : underline
% * 3 = 1+2 : bold & italic
% 
presentationStruct.TextStyle=0; %0=normal,1=bold,2=italic,4=underline, 1+2=bold&italic

%% 
% Text size of the stimulus (default = 300), including target, fixation and trials.
presentationStruct.ERPStimulusTextSize=200;
% add comments
presentationStruct.FRPStimulusTextSize=200;
%% Colors 
% Colors in RGB.
% 
% * [0,0,0] : Black
% * [255,255,255] : White
% * [0,0,255] : Blue
% * [255,0,0] : Red
% * [0,255,0] : Green
%

%% 
% Background color (default : black)
presentationStruct.backgroundColor=[0,0,0];

%%
% Stimulus ERP color (default : white)
presentationStruct.Color.ERPStimulus=[255, 255, 255]; 

%Stimulus FRP color (default : green)
presentationStruct.Color.FRPStimulus=[0 255 0];

%%
% Target color (default : blue)
presentationStruct.Color.Target=[255, 255, 0];

%%
% CopyTask Target color (default : blue)
presentationStruct.Color.copyTaskTarget=[50 50 255];

%%
% Decision color (default green)
presentationStruct.Color.Decision=[0 255 0];

%%
% CopyTask Target font size (default : 100)
presentationStruct.copyTaskTarget.TextSize=100;

%% Indicators
% Text to indicate a target, appearing on the left side of the stimulus, with adjustable text,
% enabling flag, color and size.
presentationStruct.TargetIndicator.Text='NEXT TARGET:               ';
presentationStruct.TargetIndicator.Enabled=1;
presentationStruct.TargetIndicator.Color=[255 255 0];
presentationStruct.TargetIndicator.TextSize=50;

%%
% Text to indicate a copy taks target, appearing on the left side of the stimulus, with adjustable text,
% enabling flag, color and size.
presentationStruct.CopyTaskTargetIndicator.Text='';
presentationStruct.CopyTaskTargetIndicator.Enabled=1;
presentationStruct.CopyTaskTargetIndicator.Color=[255 255 0];
presentationStruct.CopyTaskTargetIndicator.TextSize=50;

%%
% Text to indicate a decision, appearing on the left side of the stimulus, with adjustable text,
% enabling flag, color and size.
presentationStruct.DecisionIndicator.Text='DECISION:               ';
presentationStruct.DecisionIndicator.Enabled=1;
presentationStruct.DecisionIndicator.Color=[0 255 0];
presentationStruct.DecisionIndicator.TextSize=50;

%%
% Text to indicate a feedback in the center of the screen (prospect), appearing on the left side of the feedback, with adjustable text,
% enabling flag, color and size.
presentationStruct.FRPIndicator.Text='               ';
presentationStruct.FRPIndicator.Enabled=1;
presentationStruct.FRPIndicator.Color=[0 255 0];
presentationStruct.FRPIndicator.TextSize=50;

%% 
% Parameters to adjust the feedback text appearing on the top of the screen.
%
% * Neutral color represents the color scheme for neutral text (default : white)
% * Positive color represents the color scheme for correct selections (default : green)
% * Negative color represents the color scheme for incorrect selections (default : red)
% * TextSize and vSpacing adjusts the font size and vertical spacing, respectively.
% * Border represents the line which can be drawn after the feedback text.
%
presentationStruct.typingFeedbackBar.neutralColor=[255,255,255];
presentationStruct.typingFeedbackBar.positiveColor=[0,255,0];
presentationStruct.typingFeedbackBar.negativeColor=[255,0,0];
presentationStruct.typingFeedbackBar.TextSize=40;
presentationStruct.typingFeedbackBar.vSpacing=2;
presentationStruct.typingFeedbackBar.BorderEnabled=1;
presentationStruct.typingFeedbackBar.BorderInfo.width=6;
presentationStruct.typingFeedbackBar.BorderInfo.color=[255,255,255];


%%
% Parameters to adjust the pauseBar on the bottom of the screen.
presentationStruct.pauseBar.inactiveText='Press Space Bar or Enter to pause,\nEsc to quit';
presentationStruct.pauseBar.inactiveRelativeXLocation='center';
presentationStruct.pauseBar.inactiveRelativeYLocation=0.9;
presentationStruct.pauseBar.inactiveTextSize=20;
presentationStruct.pauseBar.inactiveColor=[255 255 255];
presentationStruct.pauseBar.vSpacing=1.5;
presentationStruct.pauseBar.activeText='Press Space Bar or Enter to continue,\nEsc to quit';
presentationStruct.pauseBar.activeTextSize=30;
presentationStruct.pauseBar.activeRelativeXLocation='center';
presentationStruct.pauseBar.activeRelativeYLocation='center';
presentationStruct.pauseBar.activeColor=[255 255 255];


%%
presentationStruct.decisionProbabilityFeedback.isVisible = true; % Boolean; determines if the decision probability feedback text is visible when a decision is made.
presentationStruct.decisionProbabilityFeedback.fontSize = 18; % Integer; determines the size of the decision probability feedback text (and also affects the spacing between the lines).
presentationStruct.decisionProbabilityFeedback.generalColor = [0,255,0]; % (1x3) array of integers between [0,255]; determines the color of the decision probability feedback text.
presentationStruct.decisionProbabilityFeedback.decidedColor = [0,255,255]; % (1x3) array of integers between [0,255]; determines the color of a decided item in the decision probability feedback text.
presentationStruct.decisionProbabilityFeedback.indicator = '*'; % Char; symbol used to indicate magnitude of probability.
presentationStruct.decisionProbabilityFeedback.maxIndicators = 50; % Positive integer; number of indicators that represents 100% probability.
presentationStruct.decisionProbabilityFeedback.x_shift = 0; % Real; determines the percentage of horizontal shift of the decision probability feedback text, relative to the bounds of the screen. 0% will cause the left of the text to touch the left of the screen, while 100% will cause the right of the text to touch the right of the screen.
presentationStruct.decisionProbabilityFeedback.y_shift = 50; % Real; determines the percentage of vertical shift of the decision probability feedback text, relative to the bounds of the screen. 0% will cause the top of the text to touch the top of the screen, while 100% will cause the bottom of the text to touch the bottom of the screen.

%% Over writing user parameter values.
if ~DeveloperMode
    userParamsCallMode='%% Presentation Parameters';
    loadUserParams
end
