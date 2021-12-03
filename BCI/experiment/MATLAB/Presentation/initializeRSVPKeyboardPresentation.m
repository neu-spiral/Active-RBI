%% initializeRSVPKeyboardPresentation
% Initialization part of the RSVPKeyboardPresentation. It sets up the TCP/IP communication to
% receive information from the main side or to send stop command. It sets up the parameters and
% initializes the Psychtoolbox.
%%

addpath(genpath('..\.'));

presentationParameters
RSVPKeyboardParameters
updatePortList

presentationInfo=presentationStruct;
presentationInfo.matrixSpeller=RSVPKeyboardParams.matrixSpellerMode;
presentationInfo.matrixSize=RSVPKeyboardParams.matrixSize;
if(~standaloneFlag)
    [~,CommObjectStruct,BCIPacketStruct] = sender2receiverCommInitialize('presentation','main',false,[],RSVPKeyboardParams.IP_main,RSVPKeyboardParams.port_mainAndPresentation);
end

presentationInfo.imageStructs=xls2Structs('imageList.xls');


presentationInfo.blankScreen.Type='Blank';

presentationQueue=linkedList;

importantKeys.list={'esc','space','return'};
importantKeys.code=KbName(importantKeys.list);
importantKeys.actionValue=[0,1,1];
if(presentationInfo.lockKeyboard)
    ListenChar(2);
end
PsychHID('KbQueueCreate');
PsychHID('KbQueueStart');

AssertOpenGL;

presentationInfo.screens=Screen('Screens');
if(length(presentationInfo.screens)==1)
    presentationInfo.screenNumber=presentationInfo.screens;
else
    if(presentationStruct.presentationScreenIndex<=max(presentationInfo.screens))
        presentationInfo.screenNumber=presentationStruct.presentationScreenIndex;
    else
        presentationInfo.screenNumber=max(presentationInfo.screens);
    end
end

% This preference setting selects the high quality text renderer on
% each operating system: It is not really needed, as the high quality
% renderer is the default on all operating systems, so this is more of
% a "better safe than sorry" setting.
Screen('Preference', 'TextRenderer', 1);

presentationInfo.resolution=Screen('Resolution', presentationInfo.screenNumber);

Screen('Preference', 'VisualDebugLevel', 3);  %Hides Psychtoolbox entry screen

if(presentationStruct.fullScreenFlag==0)
    presentationInfo.windowRect=[presentationInfo.resolution.width/4,presentationInfo.resolution.height/4,presentationInfo.resolution.width*3/4,presentationInfo.resolution.height*3/4];
else
    presentationInfo.windowRect=[];
    HideCursor(presentationInfo.screenNumber);
end

[presentationInfo.window,presentationInfo.windowRect]= Screen('OpenWindow',presentationInfo.screenNumber,presentationStruct.backgroundColor,presentationInfo.windowRect);

presentationInfo.interFlipInterval = Screen('GetFlipInterval',presentationInfo.window);
Screen('TextFont',presentationInfo.window, presentationInfo.TextFont);
Screen('TextStyle', presentationInfo.window, presentationInfo.TextStyle);
presentationInfo.imageTextures=makeTextures(presentationInfo.imageStructs,presentationInfo.window);
initializeParallelPortTriggerSender(RSVPKeyboardParams.parallelPortIOList);

presentationInfo.TARGET_TRIGGER_OFFSET=RSVPKeyboardParams.TARGET_TRIGGER_OFFSET;


isMatrixElement=[presentationInfo.imageStructs.showInMatrix];
symbols = {presentationInfo.imageStructs.Stimulus};
presentationInfo.matrix.symbols=symbols(find(isMatrixElement));
symbolsType={presentationInfo.imageStructs.Type};
presentationInfo.matrix.symbolsType=symbolsType(find(isMatrixElement));

if presentationInfo.matrixSpeller
    
    screen_resolution = presentationInfo.windowRect;
    % Defining the matrix dimensions (With less rows)
    if isempty(presentationInfo.matrixSize) || ischar(presentationInfo.matrixSize) || prod(presentationInfo.matrixSize)<length(presentationInfo.matrix.symbols)
        
        numberOfRows=floor(sqrt(length(presentationInfo.matrix.symbols)));
        numberOfColumns=floor(length(presentationInfo.matrix.symbols)/numberOfRows)+(rem(length(presentationInfo.matrix.symbols),numberOfRows)>0);
    else
        numberOfRows=presentationInfo.matrixSize(1);
        numberOfColumns=presentationInfo.matrixSize(2);
    end
    
    vertical_shift=floor(screen_resolution(4)*presentationInfo.relativeVerticalMatrixSize/(numberOfRows));
    % Defining the item size according to the textSize &
    % minimum distance between the items (Minimum distance
    % overrides the textSize).
    presentationInfo.matrixElementSize=presentationInfo.ERPStimulusTextSize;
    if vertical_shift<presentationInfo.minDistanceBetweenMatrixElements+presentationInfo.ERPStimulusTextSize
        presentationInfo.matrixElementSize=vertical_shift-presentationInfo.minDistanceBetweenMatrixElements;
        %Screen('TextSize',self.windowHandle, presentationInfo.matrixElementSize);
    end
    % Aspect ratio of the matrix is one.
    horizontal_shift=vertical_shift;
    % Putting the matrix at screen center (shifted downward to avoid overlapping with feedBack section on the screen).
    horizontalLocationofMatrixCorner = floor(screen_resolution(3)/2-((numberOfColumns)*horizontal_shift)/2);
    verticalLocationofMatrixCorner = floor(screen_resolution(4)/2-((numberOfRows)*vertical_shift)/2)+(10/.75*presentationInfo.relativeVerticalMatrixSize);
    
    for i = 1 : length(presentationInfo.matrix.symbols)
        row_number = floor((i-1)/numberOfColumns);
        if vertical_shift<presentationInfo.minDistanceBetweenMatrixElements+presentationInfo.matrixElementSize
            presentationInfo.matrixElementSize=vertical_shift-presentationInfo.minDistanceBetweenMatrixElements;
        end
        
        
        imageCornerPosition=[horizontalLocationofMatrixCorner +  (rem(i-1,numberOfColumns)*horizontal_shift),...
            verticalLocationofMatrixCorner   +  (row_number*vertical_shift)+0.2*presentationInfo.matrixElementSize];
        
        presentationInfo.MatrixSymbolRects{i}=[imageCornerPosition,imageCornerPosition+presentationInfo.matrixElementSize];
    end
    
    
end

% presentationInfo.adjustedTargetDurations=getAdjustedDuration(presentationInfo.targetDuration,presentationInfo.interFlipInterval,presentationInfo.dutyCycle);
% presentationInfo.adjustedFixationDurations=getAdjustedDuration(presentationInfo.fixationDuration,presentationInfo.interFlipInterval,presentationInfo.dutyCycle);
% presentationInfo.adjustedTrialDurations=getAdjustedDuration(presentationInfo.trialDuration,presentationInfo.interFlipInterval,presentationInfo.dutyCycle);

%sca
% blankScreenNode=screenNode(presentationInfo.window,presentationInfo.interFlipInterval);
% presentationQueue.insertEnd(listNode(blankScreenNode));
