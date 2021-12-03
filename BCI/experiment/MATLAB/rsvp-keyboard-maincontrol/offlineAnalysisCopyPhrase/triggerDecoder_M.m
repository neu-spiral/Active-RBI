% Modified Trigger decoder for decoding the copy phrase data

function [firstUnprocessedTimeIndex,completedSequenceCount,trialSampleTimeIndices,trialTargetness,trialLabels]=triggerDecoder_M(triggerBufferObject,trigger_partitioner, imageStructs, sessionInfo)

% Construct the alphabet for Copy Phrase Decoding
% We can vaguely assume the space symbol is the last one related with the
% alphabet and the rest are information.
for idx = 1 : length(imageStructs)
    if strcmp(imageStructs(idx).Name, 'DeleteCharacter')
        alphabet{idx} = '<';
    elseif strcmp(imageStructs(idx).Name, 'Space')
        alphabet{idx} = '_';
        break;
    else
        alphabet{idx} = imageStructs(idx).Name;
    end
    
end
alphabet = cell2mat(alphabet);
firstUnprocessedTimeIndex = trigger_partitioner.firstUnprocessedTimeIndex;
len_win = trigger_partitioner.windowLengthinSamples;
id_sequence_end = trigger_partitioner.sequenceEndID;
id_pause = trigger_partitioner.pauseID;
id_fixation = trigger_partitioner.fixationID;
offset_trig = trigger_partitioner.TARGET_TRIGGER_OFFSET;

time_last = length(triggerBufferObject) - len_win;
falling_edges = find((triggerBufferObject(2:end)-triggerBufferObject(1:end-1))<0);
labels_trig = triggerBufferObject(falling_edges);
num_finished_seq = length(find(labels_trig==id_sequence_end));

idx_fix = find(labels_trig==id_fixation);
idx_end_seq = find(labels_trig==id_sequence_end);

labels_seq = [];
timing_seq = [];
for i = 1:length(idx_fix)
%     asd = labels_trig(idx_fix(i)+1:idx_end_seq(i)-1);
%     if length(labels_trig(idx_fix(i)+1:idx_end_seq(i)-1)) ~= 5
%         asd = [asd; ones(5-length(asd),1)];
%     end
%     labels_seq = [labels_seq, asd];
    labels_seq = [labels_seq, labels_trig(idx_fix(i)+1:idx_end_seq(i)-1)];
    timing_seq = [timing_seq, falling_edges(idx_fix(i)+1:idx_end_seq(i)-1)];
end

% Check if it is a calibration
true_seq = [];
target_seq = [];
if idx_fix(1) ~= 1
    for i = 1:length(idx_fix) 
        true_seq = [true_seq, labels_trig(idx_fix(i))-offset_trig];
        target_seq = [target_seq, labels_seq(i) == true_seq];
    end
else
     for i = 1:length(idx_fix),
        true_seq = [true_seq, zeros(idx_end_seq(1)-idx_fix(1)-1,1)];
        target_seq = [target_seq, zeros(idx_end_seq(1)-idx_fix(1)-1,1)];
    end
end

trialSampleTimeIndices = timing_seq;
completedSequenceCount = num_finished_seq;
trialTargetness = target_seq;
trialLabels =  labels_seq;

%%
% Using decoded data update the trialTargetness if the task is Copy Phrase

% Check the task type
% num_sum = 0; % Dummy variable to check number of sequences 
% match the task history
count_seq = 1;
if strcmp(sessionInfo.sessionType,'CopyPhraseTask')
    
    len_copyphrase = length(sessionInfo.taskHistory);
    for idx  = 1:len_copyphrase
        num_epoch = length(sessionInfo.taskHistory{1,idx}.epochList);
        tar = sessionInfo.taskHistory{1,idx}.target;
        state = '';
        
        for idx_epoch = 1:num_epoch
            
            % calculate the new objective for the sequence
            if isempty(state)
                obj = find(alphabet == tar(1));
            else
                if length(tar)>=length(state)
                    if strcmp(tar(1:length(state)),state)
                        obj = find(alphabet == tar(length(state)+1));
                    else
                        obj = find(alphabet == '<');
                    end
                else
                    obj = find(alphabet == '<');
                end
            end
            
            % For Copy Phrase Task
            % In the sequence History, as these copy phrases consist FRP
            % sequences, they have their own enumeration.
            % sequenceHistory==1 ERP sequence
            % sequenceHistory==2 FRP sequence
            % num_sum = num_sum + sum(sessionInfo.taskHistory{1,idx}.epochList{idx_epoch}.sequenceHistory==1);
            % Chosen letter for the epoch
            update_state = imageStructs(sessionInfo.taskHistory{1,idx}.epochList{idx_epoch}.decided).Name;
            
            % If '<' remove final letter, if '_' insert '-', else insert the
            % update parameter to the state
            if strcmp(update_state, 'DeleteCharacter')
                state = state(1:end-1);
            elseif strcmp(update_state, 'Space')
                state = strcat(state,'-');
            else
                state = strcat(state,update_state);
            end
            
            len_epoch = sum(sessionInfo.taskHistory{1,idx}.epochList{idx_epoch}.sequenceHistory==1);
            trialTargetness(:,count_seq:count_seq+len_epoch-1)  = (trialLabels(:,count_seq:count_seq+len_epoch-1)==obj);
            count_seq = count_seq+len_epoch;
            
        end
    end
    
end

%%
% Trigger decoder returns everything on a trial idx x sequence idx
% matrix basis. In order to preserve the form of current offline
% analysis we vectorize the information and keep everything in trial
% level.
trialTargetness = trialTargetness(:).';
trialLabels = trialLabels(:).';
trialSampleTimeIndices = trialSampleTimeIndices(:).';

end