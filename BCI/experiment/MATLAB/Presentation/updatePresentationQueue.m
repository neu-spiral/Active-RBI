%% function [continueFlag,pauseFlag] = updatePresentationQueue(presentationQueue,presentationInfo,updateType,standaloneFlag,CommObjectStruct,BCIPacketStruct)
% Provides the presentation queue with new nodes, depending on the commands given to the presentation module.
%
%   The inputs of the function:
%
%       presentationQueue - Object, linked list of presentation nodes.
%
%       presentationInfo - Struct, contains data about the presentation.
%
%       updateType - String, used to determine the nature of the update to be made to the presentation.
%
%       standaloneFlag - Boolean, used to determine if the presentation is running on the same system as the main control.
%
%       CommObjectStruct - Struct, contains the communication object.
%
%       BCIPacketStruct - Struct, contains data about the communication protocols.
%
%   The outputs of the function:
%
%       continueFlag - Boolean, used to determine if the presentation should continue.
%
%       pauseFlag - Boolean, used to determine if the presentation should pause.
%
%%

function [continueFlag,pauseFlag] = updatePresentationQueue(presentationQueue,presentationInfo,updateType,standaloneFlag,CommObjectStruct,BCIPacketStruct)

% Declare global and persistent variables.
persistent pauseBackgroundNode
persistent fullBackgroundNode
persistent droppedChannels

% Sets the output value to true. The value returned is true in most cases, and so is set to true at the beginning of the program.
continueFlag = true;
pauseFlag = false;

% Check the nature of the update.
switch updateType
    
    case 'sequence' % If the value is 'sequence', add a sequence of nodes to the presentation queue.
        
        % Check if the presentation is running in standalone mode.
        if standaloneFlag
            
            % Generate an array of 10 random integers between 1 and 26.
            p = randperm(26);
            p = p(1:10);
            
            % Create a pause background node.
            pauseBackgroundNode = screenNode(presentationInfo.window,presentationInfo.interFlipInterval);
            
            % Create a full background node, and adds a text label to the background. Then inserts the node into the presentation queue.
            fullBackgroundNode = copy(pauseBackgroundNode);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if presentationInfo.matrixSpeller
                tempElement = textElement('inactivePauseBar',[],presentationInfo);
                fullBackgroundNode.addGraphicElement(tempElement);
                tempElement = matrixElement('drawBackgroundMatrix',[],presentationInfo,'Text');
                fullBackgroundNode.addGraphicElement(tempElement);
            else
                tempElement = textElement('inactivePauseBar',[],presentationInfo);
                fullBackgroundNode.addGraphicElement(tempElement);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            presentationQueue.insertEnd(listNode(fullBackgroundNode));
            
            % Select a random integer from the generated array of random integers. Use this selected integer to select an image struct to be the stimuls struct.
            T = randi(10);
            stimulusStruct = presentationInfo.imageStructs(p(T));
            
            % Add the full background node as a new stimulus node to the presentation queue. This is to be added as a target node.
            insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'Target',fullBackgroundNode);
            
            % Add the full background node as another new stimulus node to the presentation queue. This is to be added as a fixation node.
            stimulusStruct = presentationInfo.imageStructs(strcmpi({presentationInfo.imageStructs.Name},'Fixation'));
            insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'Fixation',fullBackgroundNode);
            
            % Iterate over the length of the generated array of random values.
            for ii = 1:length(p)
                
                % For each element in the array of random values, add the full background node as another new stimulus node to the presentation queue. These are to be added as trial nodes.
                stimulusStruct = presentationInfo.imageStructs(p(ii));
                insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'Trial',fullBackgroundNode);
                
                % Adding blank screen and fixeation after it for subject to rest.
                
                if (ii-fix(ii/(presentationInfo.SequenceBreakInterval))*(presentationInfo.SequenceBreakInterval)==0) && ~(ii<length(p)) &&(presentationInfo.SequenceBreakInterval>0)
                    stimulusStruct=presentationInfo.imageStructs(strcmpi({presentationInfo.imageStructs.Name},'BlankScreen'));
                    stimulusStruct.ID=0;
                    %stimulusStruct=presentationInfo.blankScreen;
                    insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'BlankScreen',fullBackgroundNode);
                    
                    stimulusStruct=presentationInfo.imageStructs(strcmpi({presentationInfo.imageStructs.Name},'Fixation'));
                    stimulusStruct.ID=0;
                    insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'Fixation',fullBackgroundNode);
                    
                    
                end
                
            end
            
            
        else
            
            % Obtain a data packet from the main presentation.
            receivedPacket = receiveBCIPacket(CommObjectStruct.presentation2mainCommObject,BCIPacketStruct);
            
            % Check if the droppedChannels is not empty.
            if ~isempty(droppedChannels)
                clear droppedChannels;
            end
            % Check if the received packet is not empty.
            if receivedPacket.header ~= 0
                
                % Check the header of the received packet.
                switch receivedPacket.header
                    
                    case BCIPacketStruct.HDR.MESSAGE % If the value is that of a message, process the packet as such.
                        
                        % Evaluate the data in the received packet.
                        eval(receivedPacket.data);
                        
                        % Create a pause background node.
                        pauseBackgroundNode = screenNode(presentationInfo.window,presentationInfo.interFlipInterval);
                        
                        % Check if the variable f exists.
                        if exist('f','var')
                            
                            % Check if the variable f is not a cell array.
                            if ~iscell(f)
                                
                                % Set the first cell element of the variable f to itself.
                                f{1} = f;
                                
                                % The variable f is supposed to be a cell array comprised of elements that are standard arrays. So if f is a standard array, it is cast into a cell array, where the first element is the standard array that f originally represented.
                                
                            end
                            
                            % Set the parent element to the pause background node.
                            parentElement = pauseBackgroundNode;
                            
                            % Iterate over the length of the variable f.
                            for feedbackTextIndex = 1:length(f)
                                
                                % Check the value of the first element of the current cell element of the variable f.
                                switch f{feedbackTextIndex}(1)
                                    
                                    case '+' % If the value is '+', specify that the mood is positive.
                                        
                                        % Set the mood to positive.
                                        temp.mood = 'positive';
                                        
                                    case '-' % If the value is '-', specify that the mood is negative.
                                        
                                        % Set the mood to negative.
                                        temp.mood = 'negative';
                                        
                                    case '0' % If the value is '0', specify that the mood is neutral.
                                        
                                        % Set the mood to neutral.
                                        temp.mood = 'neutral';
                                        
                                    otherwise
                                        
                                        % Do nothing.
                                        
                                end
                                
                                % Create a buffer struct and give it a label that is set to the values of the second element to the last element of the current cell element.
                                temp.text = f{feedbackTextIndex}(2:end);
                                
                                % Check if the buffer struct has an empty text label.
                                if isempty(temp.text)
                                    
                                    % Set the text label to ' '.
                                    temp.text = ' ';
                                    
                                end
                                
                                % Add the buffer text label as a text element to the parent element.
                                tempElement = textElement('typingFeedback',temp,presentationInfo);
                                parentElement.addGraphicElement(tempElement);
                                
                                % Set the parent element to the created text element.
                                parentElement = tempElement;
                                
                            end
                            
                            % Create a line element and add it to the parent element.
                            tempElement = lineElement(presentationInfo);
                            parentElement.addGraphicElement(tempElement);
                            
                        end
                        
                        % Set the full background node to an independent copy of the pause background node.
                        fullBackgroundNode = copy(pauseBackgroundNode);
                        
                        
                        % Create a text element and add it to the full background node.
                        
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        if presentationInfo.matrixSpeller && ~exist('D','var') && exist('tt','var') && ~strcmp(tt,'FRP')
                            tempElement = textElement('inactivePauseBar',[],presentationInfo);
                            fullBackgroundNode.addGraphicElement(tempElement);
                            tempElement = matrixElement('drawBackgroundMatrix',[],presentationInfo,'Text');
                            fullBackgroundNode.addGraphicElement(tempElement);
                            
                        else
                            tempElement = textElement('inactivePauseBar',[],presentationInfo);
                            fullBackgroundNode.addGraphicElement(tempElement);
                        end
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        % Add the full background node to the presentation queue.
                        presentationQueue.insertEnd(listNode(fullBackgroundNode));
                        
                        % Check if the variable D exists.
                        if exist('D','var')
                            
                            % Create a target background node as a copy of the full background node.
                            stimulusStruct = presentationInfo.imageStructs([presentationInfo.imageStructs.ID]==D);
                            
                            if exist('LU','var') && LU
                                
                                stimulusStruct = presentationInfo.imageStructs(strcmpi({presentationInfo.imageStructs.Name},'LevelUpSign'));
                                stimulusStruct.ID = 0;
                                targetBackgroundNode = copy(fullBackgroundNode);
                                tempElement = imageElement('LevelUpSign',stimulusStruct,presentationInfo);
                                targetBackgroundNode.addGraphicElement(tempElement);
                                
                                if presentationInfo.decisionProbabilityFeedback.isVisible
                                    
                                    % Create decision feedback array
                                    sizeMatrix = size(presentationInfo.imageStructs);
                                    numSymbols = 0;
                                    for i = 1:sizeMatrix(1)
                                        
                                        if presentationInfo.imageStructs(i).IsTrial
                                            
                                            numSymbols = numSymbols + 1;
                                            
                                        end
                                        
                                    end
                                    
                                    feedbackArr = cell(numSymbols,2); % Symbol, probability
                                    
                                    % Set symbols
                                    counter = 1;
                                    for i = 1:sizeMatrix(1)
                                        
                                        if presentationInfo.imageStructs(i).IsTrial
                                            
                                            feedbackArr{counter,1} = presentationInfo.imageStructs(i).Stimulus;
                                            counter = counter + 1;
                                            
                                        end
                                    end
                                    
                                    % Construct probability array
                                    for i = 1:numSymbols
                                        
                                        feedbackArr{i,2} = round(p(i) * presentationInfo.decisionProbabilityFeedback.maxIndicators);
                                        
                                    end
                                    
                                    % Create string representation of feedback array
                                    feedbackList = cell(numSymbols,1);
                                    
                                    % Set strings
                                    for i = 1:numSymbols
                                        
                                        feedbackList{i} = [feedbackArr{i,1},' ',repmat(presentationInfo.decisionProbabilityFeedback.indicator,[1,feedbackArr{i,2}])];
                                        
                                    end
                                    
                                    % Generate color matrix
                                    colorMatrix = repmat(presentationInfo.decisionProbabilityFeedback.generalColor,[numSymbols,1]);
                                    if 1 <= D && D <= numSymbols
                                        
                                        colorMatrix(D,:) = presentationInfo.decisionProbabilityFeedback.decidedColor;
                                        
                                    end
                                    
                                    % Create and add a list graphic element to the target background node.
                                    tempElement = listGraphicElement(...
                                        feedbackList,...
                                        colorMatrix,...
                                        presentationInfo.windowRect(1) + round( ( presentationInfo.decisionProbabilityFeedback.x_shift / 100) * (presentationInfo.windowRect(3) - ((2 + presentationInfo.decisionProbabilityFeedback.maxIndicators) * presentationInfo.decisionProbabilityFeedback.fontSize ))),...
                                        presentationInfo.windowRect(2) + round( ( presentationInfo.decisionProbabilityFeedback.y_shift / 100) * (presentationInfo.windowRect(4) - (numSymbols * (presentationInfo.decisionProbabilityFeedback.fontSize * 1.25)))),...
                                        presentationInfo.decisionProbabilityFeedback.fontSize,...
                                        presentationInfo...
                                        );
                                    targetBackgroundNode.addGraphicElement(tempElement);
                                    
                                end
                                
                                insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'LevelUpSign',targetBackgroundNode);
                                
                                pauseFlag = true;
                                
                            else
                                targetBackgroundNode = copy(fullBackgroundNode);
                                
                                % Create and add a text element to the target background node.
                                tempElement = textElement('DecisionIndicator',[],presentationInfo);
                                targetBackgroundNode.addGraphicElement(tempElement);
                                
                                if presentationInfo.decisionProbabilityFeedback.isVisible
                                    
                                    % Create decision feedback array
                                    sizeMatrix = size(presentationInfo.imageStructs);
                                    numSymbols = 0;
                                    for i = 1:sizeMatrix(1)
                                        
                                        if presentationInfo.imageStructs(i).IsTrial
                                            
                                            numSymbols = numSymbols + 1;
                                            
                                        end
                                        
                                    end
                                    
                                    feedbackArr = cell(numSymbols,2); % Symbol, probability
                                    
                                    % Set symbols
                                    counter = 1;
                                    for i = 1:sizeMatrix(1)
                                        
                                        if presentationInfo.imageStructs(i).IsTrial
                                            
                                            feedbackArr{counter,1} = presentationInfo.imageStructs(i).Stimulus;
                                            counter = counter + 1;
                                            
                                        end
                                    end
                                    
                                    % Construct probability array
                                    for i = 1:numSymbols
                                        
                                        feedbackArr{i,2} = round(p(i) * presentationInfo.decisionProbabilityFeedback.maxIndicators);
                                        
                                    end
                                    
                                    % Create string representation of feedback array
                                    feedbackList = cell(numSymbols,1);
                                    
                                    % Set strings
                                    for i = 1:numSymbols
                                        
                                        feedbackList{i} = [feedbackArr{i,1},' ',repmat(presentationInfo.decisionProbabilityFeedback.indicator,[1,feedbackArr{i,2}])];
                                        
                                    end
                                    
                                    % Generate color matrix
                                    colorMatrix = repmat(presentationInfo.decisionProbabilityFeedback.generalColor,[numSymbols,1]);
                                    if 1 <= D && D <= numSymbols
                                        
                                        colorMatrix(D,:) = presentationInfo.decisionProbabilityFeedback.decidedColor;
                                        
                                    end
                                    
                                    % Create and add a list graphic element to the target background node.
                                    tempElement = listGraphicElement(...
                                        feedbackList,...
                                        colorMatrix,...
                                        presentationInfo.windowRect(1) + round( ( presentationInfo.decisionProbabilityFeedback.x_shift / 100) * (presentationInfo.windowRect(3) - ((2 + presentationInfo.decisionProbabilityFeedback.maxIndicators) * presentationInfo.decisionProbabilityFeedback.fontSize ))),...
                                        presentationInfo.windowRect(2) + round( ( presentationInfo.decisionProbabilityFeedback.y_shift / 100) * (presentationInfo.windowRect(4) - (numSymbols * (presentationInfo.decisionProbabilityFeedback.fontSize * 1.25)))),...
                                        presentationInfo.decisionProbabilityFeedback.fontSize,...
                                        presentationInfo...
                                        );
                                    targetBackgroundNode.addGraphicElement(tempElement);
                                    
                                end
                                
                                % Set the stimulus struct to one of the image structs in the presentation info struct.
                                stimulusStruct = presentationInfo.imageStructs([presentationInfo.imageStructs.ID] == D);
                                
                                % Add the target background node as a new stimulus node to the presentation queue using the information from the stimulus struct. This is added as a decision node.
                                insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'Decision',targetBackgroundNode);
                            end
                            
                            
                        else
                            
                            % Add the full background node as a new stimulus node to the presentation queue. This is added as a target node.
                            insertStimulusNode(presentationQueue,[],presentationInfo,'Target',fullBackgroundNode);
                            
                        end
                        
                        % Check if the variable T exists.
                        if exist('T','var')
                            
                            % Create a target background node as a copy of the full background node.
                            targetBackgroundNode = copy(fullBackgroundNode);
                            
                            % Create and add a text element to the target background node.
                            if exist('tt','var')
                                switch tt
                                    case 'FRP'
                                        % Set the stimulus struct to one of the image structs in the presentation info struct.
                                stimulusStruct = presentationInfo.imageStructs([presentationInfo.imageStructs.ID] == T);
                                
                                % Add the target background node as a new stimulus node to the presentation queue using the information from the stimulus struct. This is added as a decision node.
                                insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'FRPTarget',targetBackgroundNode);
                                        
                                    case 'ERP'
                                        if presentationInfo.matrixSpeller
                                            tempElement = matrixElement('TargetIndicator',[],presentationInfo,'Text');
                                        else
                                            tempElement = textElement('TargetIndicator',[],presentationInfo);
                                        end
                                        targetBackgroundNode.addGraphicElement(tempElement);
                                        % Set the stimulus struct to one of the image structs in the presentation info struct.
                                        stimulusStruct = presentationInfo.imageStructs([presentationInfo.imageStructs.ID] == T);
                                        
                                        % Add the target background node as a new stimulus node to the presentation queue using the information from the stimulus struct. This is added as a decision node.
                                        insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'Target',targetBackgroundNode);
                                        
                                end
                            else
                                if presentationInfo.matrixSpeller
                                    tempElement = matrixElement('TargetIndicator',[],presentationInfo,'Text');
                                else
                                    tempElement = textElement('TargetIndicator',[],presentationInfo);
                                end
                                targetBackgroundNode.addGraphicElement(tempElement);
                                % Set the stimulus struct to one of the image structs in the presentation info struct.
                                stimulusStruct = presentationInfo.imageStructs([presentationInfo.imageStructs.ID] == T);
                                
                                % Add the target background node as a new stimulus node to the presentation queue using the information from the stimulus struct. This is added as a decision node.
                                insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'Target',targetBackgroundNode);
                            end
                            
                            
                            
                            
                        else
                            
                            % Add the full background node as a new stimulus node to the presentation queue. This is added as a target node.
                            insertStimulusNode(presentationQueue,[],presentationInfo,'Target',fullBackgroundNode);
                            
                        end
                        
                        % Check if the variable T exists.
                        if exist('t','var')
                            if exist('ST','var')
                                if ST
                                    targetBackgroundNode = copy(fullBackgroundNode);
                                    % Create and add a TargetIndicator as a text element to the target background node.
                                    tempElement = textElement('CopyTaskTargetIndicator',[],presentationInfo);
                                    targetBackgroundNode.addGraphicElement(tempElement);
                                    insertStimulusNode(presentationQueue, f{strncmp('+',f,1)}(2:end),presentationInfo,'copyTaskTarget',targetBackgroundNode);
                                end
                            end
                            if ~exist('tt','var')
                                tt=[];
                            end
                            switch tt
                                case {'ERP'}
                                    
                                    % Set the stimulus struct to one of the image structs in the presentation info struct, using fixation properties.
                                    stimulusStruct = presentationInfo.imageStructs(strcmpi({presentationInfo.imageStructs.Name},['Fixation']));
                                    
                                    % Add the full background node as a new stimulus node to the presentation queue. This is added as a fixation node.
                                    insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'Fixation',fullBackgroundNode);
                                    
                                    % Iterate over the length of the variable t.
                                    
                                    for trialIndex = 1:length(t)
                                        
                                        % Set the stimulus struct to one of the image structs in the presentation info struct.
                                        if iscell(t(trialIndex))
                                            stimulusStruct = presentationInfo.imageStructs(find(str2num(t{trialIndex}(:))));
                                            presentationInfo.triggerValue=trialIndex;
                                            % Add the full background node as a new stimulus node to the presentation queue. This is added as a trial node.
                                            insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'ERPMatrixTrial',fullBackgroundNode);
                                        else
                                            stimulusStruct = presentationInfo.imageStructs(t(trialIndex));
                                            % Add the full background node as a new stimulus node to the presentation queue. This is added as a trial node.
                                            insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'ERPTrial',fullBackgroundNode);
                                        end
                                        
                                        
                                        
                                        % Adding blank screen and fixeation after it for subject to rest.
                                        if (trialIndex-fix(trialIndex/(presentationInfo.SequenceBreakInterval))*(presentationInfo.SequenceBreakInterval)==0) && (trialIndex<length(t)) &&(presentationInfo.SequenceBreakInterval>0)
                                            stimulusStruct=presentationInfo.imageStructs(strcmpi({presentationInfo.imageStructs.Name},'BlankScreen'));
                                            stimulusStruct.ID=0;
                                            
                                            insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'BlankScreen',fullBackgroundNode);
                                            
                                            stimulusStruct=presentationInfo.imageStructs(strcmpi({presentationInfo.imageStructs.Name},'Fixation'));
                                            stimulusStruct.ID=0;
                                            insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'Fixation',fullBackgroundNode);
                                            
                                        end
                                        
                                    end
                                    % Set the stimulus struct to one of the image structs in the presentation info struct, using sequence end properties.
                                    stimulusStruct = presentationInfo.imageStructs(strcmpi({presentationInfo.imageStructs.Name},'ERPSequenceEnd'));
                                    
                                    %                                     % Set the stimulus struct to one of the image structs in the presentation info struct, using sequence end properties.
                                    %                                     stimulusStruct = presentationInfo.imageStructs(strcmpi({presentationInfo.imageStructs.Name},'SequenceEnd'));
                                    
                                    
                                case ('FRP')
                                    
                                    % Iterate over the length of the variable t.
                                    targetBackgroundNode = copy(fullBackgroundNode);
                                    
                                    % Create and add a text element to the target background node.
                                    tempElement = textElement('FRPIndicator',[],presentationInfo);
                                    targetBackgroundNode.addGraphicElement(tempElement);
                                    
                                    % Set the stimulus struct to one of the image structs in the presentation info struct, using fixation properties.
                                    stimulusStruct = presentationInfo.imageStructs(strcmpi({presentationInfo.imageStructs.Name},['FRPSequenceBegin']));
                                    
                                    % Add the full background node as a new stimulus node to the presentation queue. This is added as a fixation node.
                                    insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'SequenceBegin',targetBackgroundNode);
                                    
                                    
                                    
                                    for trialIndex = 1:length(t)
                                        
                                        
                                        % Set the stimulus struct to one of the image structs in the presentation info struct.
                                        if iscell(t(trialIndex))
                                            stimulusStruct = presentationInfo.imageStructs(find(str2num(t{trialIndex}(:))));
                                            presentationInfo.triggerValue=trialIndex;
                                            % Add the full background node as a new stimulus node to the presentation queue. This is added as a trial node.
                                            insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'FRPMatrixTrial',targetBackgroundNode);
                                        else
                                            stimulusStruct = presentationInfo.imageStructs(t(trialIndex));
                                            % Add the full background node as a new stimulus node to the presentation queue. This is added as a trial node.
                                            insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'FRPTrial',targetBackgroundNode);
                                        end
                                        
                                        
                                        
                                        % Adding blank screen and fixeation after it for subject to rest.
                                        %                                         if (trialIndex-fix(trialIndex/(presentationInfo.SequenceBreakInterval))*(presentationInfo.SequenceBreakInterval)==0) && (trialIndex<length(t)) &&(presentationInfo.SequenceBreakInterval>0)
                                        %                                             stimulusStruct=presentationInfo.imageStructs(strcmpi({presentationInfo.imageStructs.Name},'BlankScreen'));
                                        %                                             stimulusStruct.ID=0;
                                        %
                                        %                                             insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'BlankScreen',fullBackgroundNode);
                                        %
                                        %                                             stimulusStruct=presentationInfo.imageStructs(strcmpi({presentationInfo.imageStructs.Name},'Fixation'));
                                        %                                             stimulusStruct.ID=0;
                                        %                                             insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'Fixation',fullBackgroundNode);
                                        %
                                        %                                         end
                                        
                                    end
                                    % Set the stimulus struct to one of the image structs in the presentation info struct, using sequence end properties.
                                    stimulusStruct = presentationInfo.imageStructs(strcmpi({presentationInfo.imageStructs.Name},'FRPSequenceEnd'));
                                    
                                    
                            end
                            
                            
                            % Add the full background node as a new stimulus node to the presentation queue. This is added as a trial node.
                            insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,'ERPTrial',fullBackgroundNode);
                            
                        end
                        
                        % Add the full background node to the presentation queue.
                        presentationQueue.insertEnd(listNode(fullBackgroundNode));
                        
                    case BCIPacketStruct.HDR.STOP % If the value is that of an stop command, process the packet as such.
                        
                        % Reset the continue flag, stopping the presentation.
                        continueFlag = 0;
                        
                    case str2double(BCIPacketStruct.HDR.PAUSE) % If the value is that of an pause command, process the packet as such.
                        
                        pauseFlag = true;
                        droppedChannels=receivedPacket.data;
                        %                             Add the pause background node as a new stimulus node to the presentation queue. This is added as an active pause bar node.
                        presentationInfo.pauseBar.activeTextChannelDrop=['WARNING!\n Dropped channels are detected.\n channels: ' num2str(droppedChannels)];
                        insertStimulusNode(presentationQueue,[],presentationInfo,'activePauseBarChannelDrop',pauseBackgroundNode);
                        
                    otherwise
                        
                        % Do nothing.
                        
                end
                
            end
            
        end
        
    case 'pause' % If the value is 'pause', add a pause node to the presentation queue.
        
        if ~isempty(droppedChannels)
            presentationInfo.pauseBar.activeTextChannelDrop=['WARNING!\n Dropped channels are detected.\n channels: ' num2str(droppedChannels)];
            insertStimulusNode(presentationQueue,[],presentationInfo,'activePauseBarChannelDrop',pauseBackgroundNode);
        else
            % Add the pause background node as a new stimulus node to the presentation queue. This is added as an active pause bar node.
            insertStimulusNode(presentationQueue,[],presentationInfo,'activePauseBar',pauseBackgroundNode);
        end
        
    otherwise
        % Do nothing.
        
end

end