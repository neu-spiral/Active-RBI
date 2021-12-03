%% RSVPKeyboard
% RSVPKeyboard.m starts the RSVP Keyboard, BCI typing system. It initializes the data acquisition
% using gTec, starts the language model server (btlm) and starts a separate MATLAB session for the
% presentation. All of the signal processing and machine learning modules are handled in this
% routine. Presentation information transmitted to the presentation MATLAB. The contextual
% probabilities are updated and acquired by communicating with the language model server. See
% \Documents\RSVPKeyboardOperationManual.pdf for more detailed information on the operation of
% RSVPKeyboard system.
%%

clear;
clc; 


%% Initialization of parameters
% Initializes the parameters, queries the user input for subject and session and sets up the
% recording folders and files.
global BCIframeworkDir

BCIframeworkDir='.';
addpath(genpath('.'));

RSVPKeyboardParameters

updatePortList
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
projectID='CSL_RSVPKeyboard';
subjectID=getSubjectInformation(RSVPKeyboardParams.IsDataCollection,RSVPKeyboardParams.IRBString2Append);
[sessionID,sessionName]=getSessionInformation;

setPathandFilenames %% 

%% Initialization of data acquisition
% Initializes the data acquisition device, applies a trigger test and starts signal quality check
% GUI.

initializeDAQ;                   
availableChannels = true(1,length(DAQClassObj.channelNames));
channelStateChanged = false;


%% Initialization signal processing and machine learning
% Initializes the buffers, filters, feature extraction, language model and decision maker.
initializeSignalProcessing
initializeMachineLearning
artifactFilteringParameters
clear artifactFiltering
clear channelDropWarningToGUI

if sessionID == 6 % RecursiveCalibration
    % Finiding the handle to the ghm object to call the update method
    % directly.
    [recursiveUpdateObj, ~] = GetNodeHandle(processingStruct.featureExtraction.ERP.Flow,'ghm');
    recursiveUpdateObj.storelastTrialDataFlag = 1;
end

decisionLoop = true;
while decisionLoop
    
    [selection,~] = listdlg(...
        'PromptString','Select which modules you would like to run:',...
        'ListString',RSVPKeyboardParams.modules...
        );
    
    if isempty(selection)
        decisionLoop = false;
        showPresentation = false;
        showGUI = false;
    else
        showPresentation = any(selection == 1);
        showGUI = any(selection == 2);
    end
    
    
    
    
    %% Start GUI MATLAB
    remoteGUI = [];
    displayMode = 0;
    GUIServerRunning = false;
    GUIClientRunning = false;
    if showGUI;
        remoteGUI = RemoteSignalMonitorGUI();
        remoteGUI.start(RSVPKeyboardParams.GUI.autoLaunch,RSVPKeyboardParams.IP_main,RSVPKeyboardParams.IP_GUI,RSVPKeyboardParams.port_mainAndGUI);
        remoteGUI.setChannelNames(DAQClassObj.channelNames);
        remoteGUI.setSampleRate(DAQClassObj.fs);
        
        GUIServerRunning = true;
    end;
    
    if(strcmp(daqStruct.DAQType,'noAmp'))
         %% Start recording
        if or(showGUI,showPresentation)

               % Start data acquisition
           
                DAQClassObj.StartAcquisition('fileName', [dataFolderName '\' recordingFolder '\' recordingFolder daqStruct.extension]);
        end
        %% Start presentation MATLAB
        if showPresentation;
            remoteStartPresentation;
        end;
    
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(strcmp(daqStruct.DAQType,'gUSBAmp') || strcmp(daqStruct.DAQType,'DSI'))
         %% Start presentation MATLAB
        if showPresentation;
            remoteStartPresentation;
        end;  
        %% Start recording
        if or(showGUI,showPresentation)

        % Start data acquisition

                DAQClassObj.StartAcquisition('fileName', [dataFolderName '\' recordingFolder '\' recordingFolder daqStruct.extension]);
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
    
    %% Start main loop
    while or(showGUI,showPresentation)
        
        %% Fetch the data
        %fetchData;
        [rawData,triggerData]=DAQClassObj.GetData;
        
        %% SignalProcessing
        % Reads the data and trigger from the amplifer applies the frontEnd filter
        % to the data and stores the data in the dataBuferObject and the trigger in
        % triggerBufferObject.
        [~,filteredData] = signalProcessing(...
            rawData,...
            triggerData,...
            dataBufferObject,...
            triggerBufferObject,...
            frontendFilter...
            );
        
        %% Trigger Control and Partitioning
        % Based on the triggers collected in the buffer, checks the completion of the sequences and
        % partitions the sequence into trials accordingly for each evidence.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%
        %%%%
        for evidenceIndex=1:length(RSVPKeyboardParams.evidenceEval.evidences)
            switch RSVPKeyboardParams.evidenceEval.evidences{evidenceIndex}
                case 'ERP'
                    if RSVPKeyboardParams.matrixSpellerMode
                        
                        [processingStruct.triggerPartitioner.ERP.firstUnprocessedTimeIndex,...
                            processingStruct.featureExtraction.ERP.completedSequenceCount,...
                            processingStruct.featureExtraction.ERP.trialSampleTimeIndices,...
                            processingStruct.featureExtraction.ERP.trialTargetness,...
                            processingStruct.featureExtraction.ERP.trialLabels]...
                            = triggerDecoder(triggerBufferObject,...
                            processingStruct.triggerPartitioner.ERP,...
                            RSVPKeyboardTaskObject.currentMatrixSequences,trialsID);
                        
                    else
                        [processingStruct.triggerPartitioner.ERP.firstUnprocessedTimeIndex,...
                            processingStruct.featureExtraction.ERP.completedSequenceCount,...
                            processingStruct.featureExtraction.ERP.trialSampleTimeIndices,...
                            processingStruct.featureExtraction.ERP.trialTargetness,...
                            processingStruct.featureExtraction.ERP.trialLabels]...
                            = triggerDecoder(triggerBufferObject,...
                            processingStruct.triggerPartitioner.ERP);
                    end
                     processingStruct.triggerPartitioner.FRP.firstUnprocessedTimeIndex = ...
                         processingStruct.triggerPartitioner.ERP.firstUnprocessedTimeIndex;
                     processingStruct.featureExtraction.ERP.featureType='ERP';
                case 'FRP'
                    [processingStruct.triggerPartitioner.FRP.firstUnprocessedTimeIndex,...
                        processingStruct.featureExtraction.FRP.completedSequenceCount,...
                        processingStruct.featureExtraction.FRP.trialSampleTimeIndices,...
                        processingStruct.featureExtraction.FRP.trialTargetness,...
                        processingStruct.featureExtraction.FRP.trialLabels]...
                        = triggerDecoder(triggerBufferObject,...
                        processingStruct.triggerPartitioner.FRP);
                    processingStruct.triggerPartitioner.ERP.firstUnprocessedTimeIndex ...
                        = processingStruct.triggerPartitioner.FRP.firstUnprocessedTimeIndex;
                    processingStruct.featureExtraction.FRP.featureType='FRP';
                    
            end
        end
       
        %%%%
        %%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        %% Artifacts
        % Based on the setting detects the artifacts and tries to remove them from
        % the signal.
        [processingStruct.featureExtraction.ERP,newAvailableChannels] = artifactFiltering(...
            DAQClassObj.channelNames,...
            dataBufferObject,...
            daqStruct.fs,...
            processingStruct.triggerPartitioner.ERP,...
            processingStruct.featureExtraction.ERP,...
            artifactFilteringParams,...
            RSVPKeyboardParams.artifactFiltering,...
            remoteGUI,...
            calibrationArtifactParameters);
        
        % Check if the state of the channels has changed.
        channelStateChanged = any(newAvailableChannels ~= availableChannels);
        if channelStateChanged
            
            availableChannels = newAvailableChannels;
%             remoteGUI.setChannelStatuses(double(availableChannels));
            
        end
        
        %% Attention Monitoring
        % Based on the setting detects the attention during experiment.
        %         attentionMonitoringStruct = attentionMonitoring(...
        %                                                             RSVPKeyboardParams.attentionMonitoring.enabled,...
        %                                                             RSVPKeyboardParams.attentionMonitoring.useArtifactFilteringData,...
        %                                                             RSVPKeyboardParams.attentionMonitoring.processWindowLength,...
        %                                                             fs,...
        %                                                             dataBufferObject,...
        %                                                             cleanDataBufferObject,...
        %                                                             RSVPKeyboardParams.artifactFiltering.enabled,...
        %                                                             amplifierStruct.channelNames...
        %                                                        );
        
        %% Feature Extraction
        % Extracts the feature(s) corresponding to trials from the filtered EEG for each evidence.
        for evidenceIndex=1:length(RSVPKeyboardParams.evidenceEval.evidences)
            switch RSVPKeyboardParams.evidenceEval.evidences{evidenceIndex}
                case 'ERP'
                   % if isfield(featureExtraction,'ERP')
                        [results.ERP,scoreStruct] = featureExtraction(...
                            dataBufferObject,...
                            processingStruct.triggerPartitioner.ERP,...
                            processingStruct.featureExtraction.ERP,...
                            channelStateChanged,...
                            availableChannels,...
                            RSVPKeyboardParams,...
                            calibrationDataStruct...
                            );
                        if ~isempty(processingStruct.featureExtraction.ERP.trialTargetness) && (sessionID == 6) ...
                                && isempty(processingStruct.featureExtraction.ERP.trialTargetness < 0)
                            recursiveUpdateObj.update([],processingStruct.featureExtraction.ERP.trialTargetness);
                        end
                   % end
                case 'FRP'
                    [results.FRP,scoreStruct] = featureExtraction(...
                        dataBufferObject,...
                        processingStruct.triggerPartitioner.FRP,...
                        processingStruct.featureExtraction.FRP,...
                        channelStateChanged,...
                        availableChannels,...
                        RSVPKeyboardParams,...
                        calibrationDataStruct...
                        );
                    
            end
        end
        
        if ~isempty(scoreStruct)
            RSVPKeyboardTaskObject.decisionObj.scoreStruct = scoreStruct;
        end
        
        if showPresentation
            
            %% Decision making
            % Makes decision based on the extracted features and language model. The decisions and the next
            % trials to show is sent to the presentation MATLAB via TCP/IP.
            [showPresentation,decision] = decisionMaker(...
                results,...
                RSVPKeyboardTaskObject,...
                main2presentationCommObjectStruct,...
                BCIPacketStruct...
                );
            
            %% Generate artificial triggers
            % In no amplifier mode ('noAmp'), triggers are generated artificially if no input file is selected.
            if(strcmp(daqStruct.DAQType,'noAmp'))
                if isfield(decision,'nextSequence') && isfield(decision.nextSequence,'Type')
                    generateArtificialTriggers(DAQClassObj,decision,artificialsTriggersParams.(decision.nextSequence.Type))
                else
                    generateArtificialTriggers(DAQClassObj,decision,artificialsTriggersParams.ERP)
                end
            end
            
        end
        
        %% Check packets from presentation
        % Gets feedback from the presentation.
        if showPresentation
            
            inPacket = receiveBCIPacket(main2presentationCommObjectStruct.main2presentationCommObject,BCIPacketStruct);
            
            switch inPacket.header
                
                case BCIPacketStruct.HDR.STOP
                    showPresentation = false;
                    
            end
            
        end
        
        %% Communication with GUI
        if showGUI
            
%             if GUIServerRunning
%             
%                 if GUIClientRunning
% 
%                     if ~(remoteGUI.isStarted(1))
% 
%                         GUIServerRunning = false;
%                         showGUI = false;
% 
%                     end
% 
%                 else
% 
%                     if remoteGUI.isStarted(1)
% 
%                         GUIClientRunning = true;
% 
%                     end
% 
%                 end
% 
%             end
            
            % Gets feedback from the GUI.
            newDisplayMode = remoteGUI.getDisplayMode(1);
            
            if displayMode ~= newDisplayMode
                
                displayMode = newDisplayMode;
                
                % Initialise new display mode properties.
                switch displayMode;
                    
                    case 0
                        showGUI = false;
                        
                    case {RSVPKeyboardParams.GUI.RAW_DATA,RSVPKeyboardParams.GUI.FILTERED_DATA}
                        remoteGUI.setChannelNames(DAQClassObj.channelNames);
                        
                    case RSVPKeyboardParams.GUI.AM_DATA
                        remoteGUI.setChannelNames({'Theta Power','Alpha Power','Lateral Eye Movement','Eye Blink Rate'});
                end
                
            end
            
            % Sends data to the GUI, based on the display mode.
            if ~isempty(rawData)
                
                switch displayMode;
                    
                    case RSVPKeyboardParams.GUI.RAW_DATA
                        remoteGUI.addData(rawData);
                        
                    case RSVPKeyboardParams.GUI.FILTERED_DATA
                        remoteGUI.addData(filteredData);
                        
                    case RSVPKeyboardParams.GUI.AM_DATA
                        
                        if attentionMonitoringStruct.show
                            % Prepare data packet.
                            AMData = [transpose(attentionMonitoringStruct.thetaPower),...
                                transpose(attentionMonitoringStruct.alphaPower),...
                                transpose(attentionMonitoringStruct.lateralEyeMovement),...
                                transpose(attentionMonitoringStruct.eyeBlinkRate)];
                            remoteGUI.addData(AMData);
                        end
                        
                end
                
            end
            
        end
        
        pause(0.01);
    end
    
    % Stop, but do not destroy, the DAQ(s).
    
        
       
    DAQClassObj.StopAcquisition();
        
    
    
    if any(selection == 1)
        
        outPacket.header = BCIPacketStruct.HDR.STOP;
        outPacket.data = [];
        sendBCIPacket(main2presentationCommObjectStruct.main2presentationCommObject,BCIPacketStruct,outPacket);
        
    end
    
    if any(selection == 2)
        
        remoteGUI.stop();
        
    end
    
end

%% Save information and quit
saveInformation;
DAQClassObj.CloseDevice();
if(~RSVPKeyboardParams.languageModelOld)
    s = system('docker-machine stop default');
end
