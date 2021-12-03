%% function generateArtificialTriggers(DAQClassObj,artificialsTriggersParams,decision)
% Creates a list of contrived triggers, which are added to the specified amplifier. Triggers are generated based on the given decision.
%
%   The inputs of the function:
%
%       artificialsTriggersParams - Struct, that contains information for generating the artificials triggers. 
%           The fields are the following: 
%                   % artificialsTriggersParams.Duration.Target
                    % artificialsTriggersParams.DutyCycle.Target
                    % artificialsTriggersParams.Duration.Fixation
                    % artificialsTriggersParams.DutyCycle.Fixation
                    % artificialsTriggersParams.DutyCycle.Trial
                    % artificialsTriggersParams.Duration.Trial
                    % artificialsTriggersParams.Duration.SequenceEnd
                    % artificialsTriggersParams.DutyCycle.SequenceEnd
                    % artificialsTriggersParams.triggerPartitioner.fixationID
                    % artificialsTriggersParams.triggerPartitioner.sequenceEndID
                    % artificialsTriggersParams.TARGET_TRIGGER_OFFSET

%
%       decision - Struct, contains information about the decision made regarding the sequence of trials.
%
%       DAQClassObj -  This object controls all aspects of the daq including detecting, calibrating the amp, testing the trigger, initializing the amps and setting up amp parameters.

function generateArtificialTriggers(DAQClassObj,decision,artificialsTriggersParams)
    
    % Check if the decision variable is not empty and if the decision variable contains the field 'nextSequence'
    if ~isempty(decision) && isfield(decision,'nextSequence')
        
        % Set the value of the variable durations to an array of zeros, where the length of the array is equal to the length of the variable decision.nextSequence.trials plus 4.
        durations = zeros(4 + length(decision.nextSequence.trials),1);
        
        % Make two copies of the variable durations.
        activeDurations = durations;
        values = durations;

        % Check if the variable decisions has the field 'decided'.
        if isfield(decision,'decided')
            
            % Set the value of the first element of the variable durations to the length of the variable decision.decided.
            durations(1) = length(decision.decided);
            
        else
            
            % Set the value of the first element of the variable durations to 1.
            durations(1) = 1;
            
        end

        % Checks if the variable decision.nextSequence has the field 'target'.
        if isfield(decision.nextSequence,'target')
            
            % Set the values of the second element of each of the three arrays, using the target data from the given structs.
            durations(2) = artificialsTriggersParams.Duration.Target;
            values(2) = decision.nextSequence.target + artificialsTriggersParams.TARGET_TRIGGER_OFFSET;
            activeDurations(2) = durations(2) * artificialsTriggersParams.DutyCycle.Target;
            
        end
        
        % Set the values of the third element of each of the three arrays, using the fixation data from the given structs.
        durations(3) = artificialsTriggersParams.Duration.Fixation;
        values(3) = artificialsTriggersParams.triggerPartitioner.fixationID;
        activeDurations(3) = durations(3) * artificialsTriggersParams.DutyCycle.Fixation;

        % Set the values of the fourth element to the second last element of each of the three arrays, using the trial data from the given structs.
%         if (isfield(decision.nextSequence,'Type'))
%              if(strcmp(decision.nextSequence.Type,'ERP'))
%                 durations(4:3 + length(decision.nextSequence.trials)) = artificialsTriggersParams.Duration.ERPTrial;
%              elseif(strcmp(decision.nextSequence.Type,'FRP'))
                 durations(4:3 + length(decision.nextSequence.trials)) = artificialsTriggersParams.Duration.Trial;
%              end
%         end
        
        %%
        %%
        if iscell(decision.nextSequence.trials)
            values(4:3 + length(decision.nextSequence.trials)) = 1:length(decision.nextSequence.trials);
        else
            values(4:3 + length(decision.nextSequence.trials)) = decision.nextSequence.trials;
        end
%         if (isfield(decision.nextSequence,'Type'))
%              if(strcmp(decision.nextSequence.Type,'ERP'))
%                activeDurations(4:3 + length(decision.nextSequence.trials)) = durations(4:3 + length(decision.nextSequence.trials)) * artificialsTriggersParams.DutyCycle.ERPTrial;
%              elseif(strcmp(decision.nextSequence.Type,'FRP'))
               activeDurations(4:3 + length(decision.nextSequence.trials)) = durations(4:3 + length(decision.nextSequence.trials)) * artificialsTriggersParams.DutyCycle.Trial;
%              end
%         end

        % Set the values of the last element of each of the three arrays, using the sequence end data from the given structs.
        durations(4 + length(decision.nextSequence.trials)) = artificialsTriggersParams.Duration.SequenceEnd;
        values(4 + length(decision.nextSequence.trials)) = artificialsTriggersParams.triggerPartitioner.sequenceEndID;
        activeDurations(4 + length(decision.nextSequence.trials)) = durations(4 + length(decision.nextSequence.trials)) * artificialsTriggersParams.DutyCycle.SequenceEnd;

        % Multiply two of the arrays by the variable amplifierStruct.fs, and take the ceiling of the calculated values.
        durations = ceil(durations * DAQClassObj.fs);
        activeDurations = ceil(activeDurations * DAQClassObj.fs);
        
        % Set the value of the variable cumDurations to an array, such that the array has 2 elements, the first element is 0, and the second element is the cumulative sum of the variable durations.
        cumDurations = [0;cumsum(durations)];

        %activeDurations=round(durations*amplifierStruct.Duration.DutyCycle);

        % Set the value of the variable triggerSignals to an array of zeros, where the length of the array is equal to the cumulative sum of the variable durations.
        triggerSignal = zeros(cumDurations(end),1);

        % Iterate over the length of the activeDurations vector.
        for durationIndex = 1:length(activeDurations)
            
            % Populate the triggerSignal array with elements from the values array.
            triggerSignal(cumDurations(durationIndex) + 1:cumDurations(durationIndex) + activeDurations(durationIndex)) = values(durationIndex);
            
        end
        
        % Append the generated trigger signals to the data in the amplifier.
%         amplifierStruct.awaitingTriggers.data = [amplifierStruct.awaitingTriggers.data;triggerSignal];
        %%% 
        DAQClassObj.SetTrigger(triggerSignal);

    end
    
end