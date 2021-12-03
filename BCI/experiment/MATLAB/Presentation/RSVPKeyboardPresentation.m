%% RSVPKeyboardPresentation
% Controls the presentation side of the RSVP Keyboard. It is a script that runs on a separate
% Matlab, communicates with main part of RSVP Keyboard and does the presentation using Psychtoolbox.
% To be able to communicate with the main part standaloneFlag should be set to 0. It updates the
% items to be shown on the screen according to the information coming from the main side.
%%

Screen('Preference', 'SkipSyncTests', 1);


if ~exist('standaloneFlag','var')
    
    standaloneFlag=1;
    
end

try
    
    initializeRSVPKeyboardPresentation
    currentStimulusNode=presentationQueue.Head;
    pausePresentationQueue = linkedList(); % This is a buffer to hold the sequence when it has been paused during execution.
    
    tic;
    presentationContinueFlag=true;
    isPausedFlag=true;
    
    while presentationContinueFlag
        
        processPresentationQueue;
        
    end
    
    quitPresentation;
    
    
catch exception
    logError(exception,0);
    quitPresentation;
    
end