%% function insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,stimulusType,backgroundNode)
% Initialises and inserts a new stimulus node into the specified presentation queue, using the provided data.
%
%   The inputs of the function:
%
%       presentationQueue - Object, queue which contains the nodes being processed by the presentation. The new stimulus node is added to this queue.
%
%       stimulusStruct - Struct, contains information about the stimulus.
%
%       presentationInfo - Struct, contains information about the presentation.
%
%       stimulusType - String, labels the stimulus type.
%
%       backgroundNode - Object, contains information pertaining to a graphical representation of the stimulus.
%
%%

function insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,stimulusType,backgroundNode)
    %disp(stimulusType)

%   % Initialise the duration of the stimulus.
    if strcmpi(stimulusType,'activePauseBarChannelDrop')
        duration = presentationInfo.Duration.activePauseBar;
        % Sets the values of the variable active and the variable paasive as determined by the getAdjustedDuration function.
      [active,passive] = getAdjustedDuration(duration,presentationInfo.interFlipInterval,presentationInfo.DutyCycle.activePauseBar);

    else
        
        duration = presentationInfo.Duration.(stimulusType);
        % Sets the values of the variable active and the variable paasive as determined by the getAdjustedDuration function.
        [active,passive] = getAdjustedDuration(duration,presentationInfo.interFlipInterval,presentationInfo.DutyCycle.(stimulusType));

    end
    
    % Check if the variable active is not equal to 0.
    if active ~= 0
%         disp(stimulusType)
        % Sets the value of the variable mainScreenNode to a screenNode object.
        mainScreenNode = screenNode(presentationInfo.window,presentationInfo.interFlipInterval,active);
        
        % Checks if the stimulusType variable has the value 'activePauseBar' (ignoring case) or if the stimulusStruct struct is not empty.
        if strcmpi(stimulusType,'activePauseBar') || ~isempty(stimulusStruct)|| strcmpi(stimulusType,'activePauseBarChannelDrop') || strcmpi(stimulusType,'BlankScreen') || strcmpi(stimulusType,'ERPMatrixTrial')
             % Checks if the backgroundNode object is not empty.
            if ~isempty(backgroundNode)
                
                % Adds the backgroundNode object as a graphic element to the mainScreenNode object.
                mainScreenNode.addGraphicElement(backgroundNode);
                
            end

            if isfield(stimulusStruct,'Type')
                stimulusBased=stimulusStruct.Type;
            else
                stimulusBased='Non';
            end
            
            if strcmpi(stimulusType,'ERPMatrixTrial')
                tempElement = matrixElement('ERPTrial',stimulusStruct,presentationInfo);
            elseif   strcmpi(stimulusType,'FRPMatrixTrial')
                tempElement = matrixElement('FRPTrial',stimulusStruct,presentationInfo); 
            else
                
                if presentationInfo.matrixSpeller && (~strcmpi(stimulusType,'activePauseBar') && ~strcmpi(stimulusType,'Decision')) && (~strcmpi(stimulusType,'FRPTrial')) && (~strcmpi(stimulusType,'ERPTrial')) && (~strcmpi(stimulusType,'FRPTarget'))
                    tempElement=matrixElement(stimulusType,stimulusStruct,presentationInfo,stimulusBased);
                else
                    if strcmpi(stimulusBased,'Image')
                        
                        tempElement=imageElement(stimulusType,stimulusStruct,presentationInfo);
                        
                    elseif ~strcmpi(stimulusType,'FRPTarget')
                        % Sets the value of the tempElement variable to a new textElement object.
                        tempElement = textElement(stimulusType,stimulusStruct,presentationInfo);
                    else
                        tempElement = textElement('Target',' ',presentationInfo);
                    end
                end
            end
            
            % Adds the tempElement object as a graphic element to the mainScreenNode object.
            mainScreenNode.addGraphicElement(tempElement);
            
           
            % Checks the value of the stimulusType variable.
            switch stimulusType
                
                case {'Target','FRPTarget'} % If the value is 'Target', the stimulus node is given a target trigger value.
                    
                    % Sets the trigger value of the mainScreenNode object to the target trigger value, as designated by (stimulusStruct.ID + presentationInfo.TARGET_TRIGGER_OFFSET).
                    mainScreenNode.setTriggerValue(stimulusStruct.ID + presentationInfo.TARGET_TRIGGER_OFFSET);

                case {'ERPTrial','FRPTrial','Fixation','SequenceBegin'} % If the value is 'Trial' or 'Fixation', the stimulus node is given a default trigger value.
                    
                    % Sets the trigger value of the mainScreenNode object to the default trigger value, as designated by stimulusStruct.ID.
                                        
                    mainScreenNode.setTriggerValue(stimulusStruct.ID);
                    
                case {'ERPMatrixTrial','FRPMatrixTrial'}
                    mainScreenNode.setTriggerValue(presentationInfo.triggerValue);
                    
                otherwise
                    
                    % Do nothing.
                    
            end
            
            presentationQueue.insertEnd(listNode(mainScreenNode));
            
        end
         
    end
    
    % Check if the variable passive is not equal to 0.
    if passive ~= 0
        
        % Sets the value of the variable mainScreenNode to a screenNode object.
        mainScreenNode = screenNode(presentationInfo.window,presentationInfo.interFlipInterval,passive);
        
        % Checks if the backgroundNode object is not empty.
        if ~isempty(backgroundNode)
            
            % Appends the backgroundNode object as a graphic element to the mainScreenNode object.
            mainScreenNode.addGraphicElement(backgroundNode);
            
        end
        
        % Casts the mainScreenNode object to a listNode object and then appends it to the presentationQueue object.
        presentationQueue.insertEnd(listNode(mainScreenNode));

    end
    
end




% function insertStimulusNode(presentationQueue,stimulusStruct,presentationInfo,stimulusType)
% [active,passive]=getAdjustedDuration(presentationInfo.Duration.(stimulusType),presentationInfo.interFlipInterval,presentationInfo.Duration.DutyCycle);
% if(active~=0)
%     stimulusStruct.Duration=active;
%     presentationQueue.insertEnd(listNode(stimulusStruct));
% end
% if(passive~=0)
%     S=presentationInfo.blankScreen;
%     S.Duration=passive;
%     presentationQueue.insertEnd(listNode(S));
%
% end