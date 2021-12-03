%% processPresentationQueue
% Processes the presentation queue and displays currentStimulusNode
%%

% Get key-press information.
action = checkKeyboardOperations(importantKeys);

% Perform an action based on the key pressed
switch action

    case 0 % If the escape key is pressed, then terminate the executing loop.

        presentationContinueFlag = 0;

    case 1 % If the space OR enter/return key is pressed, then pause or unpause the presentation.

        % Toggle the paused state of the presentation.
        isPausedFlag = ~isPausedFlag;

        % If the presentation is now paused, check if it has been paused during or after a sequence.
        if(isPausedFlag)

            % If the current stimulus node is not empty, move the current presentation queue to a temporary buffer.
            if ~isempty(currentStimulusNode)

                % Clear the buffer queue (should be empty, but just in case).
                pausePresentationQueue.empty();
                
                % Move the presentation queue to the buffer queue.
                pausePresentationQueue.Head = presentationQueue.Head;
                pausePresentationQueue.Tail = presentationQueue.Tail;
                pausePresentationQueue.elementCount = presentationQueue.elementCount;
                
                % Clear the current stimulus node.
                currentStimulusNode = [];
                
            end
            
            % Flush the presentation queue.
            presentationQueue.empty();
            
            % Finally update the presentation queue with a pause node.
            [presentationContinueFlag,~] = updatePresentationQueue(presentationQueue,presentationInfo,'pause',standaloneFlag,CommObjectStruct,BCIPacketStruct);
            
            % Send the pause trigger.
            pauseID = presentationInfo.imageStructs(strcmpi({presentationInfo.imageStructs.Name},'Pause')).ID;
            sendTrigger(pauseID);
            
            % Set the current stimulus node.
            currentStimulusNode = presentationQueue.Head;

        else % If the presentation is now unpaused, check to see if the buffer queue has elements. If the buffer queue has elements, move the contents to the presentation queue.
            
            % Check if the buffer queue has elements.
            if pausePresentationQueue.elementCount > 0
                
                % Clear the presentation queue (should be empty, but just in case).
                presentationQueue.empty();
                
                % Move the buffer queue to the presentation queue.
                presentationQueue.Head = pausePresentationQueue.Head;
                presentationQueue.Tail = pausePresentationQueue.Tail;
                presentationQueue.elementCount = pausePresentationQueue.elementCount;
                
                % Clear the buffer queue.
                pausePresentationQueue.empty();
                
                % Set the current stimulus node.
                currentStimulusNode = presentationQueue.Head;
                
            end
            
        end

    case 2 % If no key is pressed, then continue the execution of the presentation.

        % Check if the current stimulus node is not empty.
        if ~isempty(currentStimulusNode) % If it isn't empty, then process the node.

            % Draw and flip the screen information.
            currentStimulusNode.Data.Draw;
            tic;
            currentStimulusNode.Data.Flip;
            
            % Send the event trigger.
            sendTrigger(currentStimulusNode.Data.triggerValue);

            % Get the next node in the presentation queue.
            nextStimulusNode = currentStimulusNode.Next;
            
            % Check if the next node exists.
            if isempty(nextStimulusNode) % If the next node does not exist...

                % Check if the presentation is paused.
                if(isPausedFlag) % If the presentation is paused...
                
                    % Update the presentation with a pause node.
                    [presentationContinueFlag,~] = updatePresentationQueue(presentationQueue,presentationInfo,'pause',standaloneFlag,CommObjectStruct,BCIPacketStruct);
                    
                    % Get the next node in the presentation queue (which is the new pause node).
                    nextStimulusNode = currentStimulusNode.Next;
                    
                    % Set the flip time with the next node (which is again the new pause node).
                    currentStimulusNode.Data.setFlipTime(nextStimulusNode.Data);

                else % If the presentation is not paused...
                    
                    % Set the flip time with an empty next node.
                    currentStimulusNode.Data.setFlipTime([]);
                    
                end

            else % If the next node exists...

                currentStimulusNode.Data.setFlipTime(nextStimulusNode.Data);

            end

            currentStimulusNode = nextStimulusNode;

        else % If it is empty, then flush and update the presentation queue.

            % Clear the presentation queue.
            presentationQueue.empty();
            
            % Update the presentation queue.
            if(isPausedFlag)
                
                [presentationContinueFlag,~] = updatePresentationQueue(presentationQueue,presentationInfo,'pause',standaloneFlag,CommObjectStruct,BCIPacketStruct);

            else

                [presentationContinueFlag,isPausedFlag] = updatePresentationQueue(presentationQueue,presentationInfo,'sequence',standaloneFlag,CommObjectStruct,BCIPacketStruct);

            end
            
            currentStimulusNode = presentationQueue.Head;

        end

end