%% function [firstUnprocessedTimeIndex,completedSequenceCount,trialSampleTimeIndices,trialTargetness,trialLabels]=triggerDecoder(triggerBufferObject,triggerPartitionerStruct)
% Trigger Control and Partitioning
%
%   Inputs : triggerBufferObject      - a dataBuffer class object containing the
%                                       buffer corresponding to trigger signal.
%
%           triggerPartitionerStruct  - a struct for trigger partitioner
%
%   Outputs : firstUnprocessedTimeIndex  - the time index of first
%                                          unprocessed sequence
%             completedSequenceCount     - number of completed sequence
%             trialSampleTimeIndices     - time index for specific trial
%                                          sample
%             trialTargetness
%             trialLabels                - labels of trials
%%
function [firstUnprocessedTimeIndex,completedSequenceCount,trialSampleTimeIndices,trialTargetness,trialLabels]=triggerDecoder(triggerBufferObject,triggerPartitionerStruct,matrixSequences,trialIDs)


 try
    trialSampleTimeIndices=[];
    trialTargetness=[];
    trialLabels=[];
    completedSequenceCount=0;
    isMatrix=0;
    if nargin>2
        if ~isempty(matrixSequences) && ~isempty(trialIDs)
            isMatrix=1;
        end
    end
    
    %Initialize first unprocessed time index
    firstUnprocessedTimeIndex=triggerPartitionerStruct.firstUnprocessedTimeIndex;
    if(isa(triggerBufferObject,'dataBuffer'))
        %check whether triggerBufferObject is of type dataBuffer
        %if so,set last sample time index from triggerBufferObject
        lastSampleTimeIndex=triggerBufferObject.lastSampleTimeIndex;
    else
        %else set last sample time index to the difference between the
        %length of triggerOfBufferObject and windowLengthinSample
        lastSampleTimeIndex=length(triggerBufferObject)-triggerPartitionerStruct.windowLengthinSamples;
    end
    
    if(lastSampleTimeIndex>firstUnprocessedTimeIndex)%whether the last sample index greater than first unprocessed time index
        if(isa(triggerBufferObject,'dataBuffer'))
            %check whether triggerBufferObject is of type dataBuffer
            %if so,get data from triggerBufferObject.getOrderedData
            %ranging from firstUnprocessedTimeIndex to lastSampleTimeIndex
            t=triggerBufferObject.getOrderedData(firstUnprocessedTimeIndex,lastSampleTimeIndex);
        else
            %else,get data from triggerBufferObject(1 to lastSampleTimeIndex)
            t=triggerBufferObject(1:lastSampleTimeIndex);
        end
        
        %index of element not equal to previous element
        tChangeLocAllRaw=find(diff(t)~=0)+1;
        %values of element not equal to previous element
        tChangeValues=t(tChangeLocAllRaw);
        %find the last zero that not equal to previous element
        lastChangetoZero=find(tChangeValues==0,1,'last');
        %update index of tChangeValues,select elements previous to lastChangetoZero
        tChangeLocAll=tChangeLocAllRaw(1:lastChangetoZero);
        %update values of tChangeValues
        tChangeValues=tChangeValues(1:lastChangetoZero);
        %find tChangeValues greater than zero
        tChangeValuesispositive=(tChangeValues>0);
        %index of non-zero tChangeValues
        tChangeValuesispositiveIndices=find(tChangeValuesispositive);
        
        tChangeLoc=tChangeLocAll(tChangeValuesispositive);
        %update tChangeValues
        tChangeValues=round(tChangeValues(tChangeValuesispositive));
        
        %% When pausing a sequence while it is running, any trigger data collected prior to the pause must be discarded.
        % Create begin index.
        beginIndex = 1;
        seqCount=1;
        % Iterate over all the triggers.
        for i = 1:length(tChangeLoc)
            
            % Check the current trigger.
            if tChangeValues(i) == triggerPartitionerStruct.sequenceEndID % If the trigger is a sequence end index, update the begin index.
                
                % Set begin index to the trigger immediately after the sequence end index.
                beginIndex = i + 1;

                
            elseif tChangeValues(i) == triggerPartitionerStruct.pauseID % If the trigger is a pause index, invalidate all the triggers between the begin index and the pause index.
                
                % Iterate through each trigger between the begin index and the pause index.
                for j = beginIndex:i
                    
                    % Set the value of the trigger to -1.
                    tChangeValues(j) = -1;
                    
                    % Cancel the matrix sequence if there was a pause in
                    % during the sequence.
                     
                end
                
                % Set begin index to the trigger immediately after the pause index.
                beginIndex = i + 1;
                
            end
            
        end
        
        sequenceEndIndicesWithPause=find(tChangeValues==triggerPartitionerStruct.sequenceEndID);
        % If the trigger decoder is in offline analysis mode, remove all the negative values from the triggers.
        %if(~isa(triggerBufferObject,'dataBuffer'))
            indices = find(tChangeValues >= 0);
            tChangeLoc = tChangeLoc(indices);
            tChangeValues = tChangeValues(indices);

       % end
        %%
        
        %index of sequence end flag
        sequenceEndIndices=find(tChangeValues==triggerPartitionerStruct.sequenceEndID);
        
        if(isempty(sequenceEndIndices))
            %check if sequenceEndIndices is empty
            %if so,set complete sequence count to zero
            completedSequenceCount=0;
            
            
        else
            
            if(tChangeLoc(sequenceEndIndices(end)-1)+triggerPartitionerStruct.windowLengthinSamples>length(t))
                %compare the length of sequence end indices (end -1) plus
                %length of sample with length of triggerData
                %update sequence end index from (1 to end-1)
                sequenceEndIndices=sequenceEndIndices(1:end-1);
            end
            if(isempty(sequenceEndIndices))
                %check if sequenceEndIndices is empty
                %if so,set complete sequence count to zero
                completedSequenceCount=0;
                
            else
                %else,set the completed sequence count to the length of
                %sequence end sequences
                completedSequenceCount=length(sequenceEndIndices);
                %update index of tChangeLoc(1 to sequenceEndIndices(end))
                tChangeLoc=tChangeLoc(1:sequenceEndIndices(end));
                %update values of tChangeValues(1 to sequenceEndIndices(end))
                tChangeValues=tChangeValues(1:sequenceEndIndices(end));
                %index of fixation flag
                fixationIndices=find(tChangeValues==triggerPartitionerStruct.fixationID);
                %number of total trial times
                trialCount=sum(sequenceEndIndices-fixationIndices-1);
                %initialize trial labels,trialSampleTimeIndices,trialTargetness,trial index
                if ~isMatrix
                    %initialize trialLabels as a struct if the system is in
                    %RSVP mode.
                    trialLabels=zeros(1,trialCount);
                else
                    %initialize trialLabels as a struct if the system is in
                    %P300MatrixSpeller mode.
                    trialLabels=[];
                end
                trialSampleTimeIndices=zeros(1,trialCount);
                trialTargetness=repmat(-1,1,trialCount);
                trialIndex=1;
                
                for(ii=1:completedSequenceCount)
                    sequenceEndIndex=sequenceEndIndices(ii);
                    % find the begin index of sequence
%                     if(ii>1)
%                         %update sequence begin index from
%                         sequenceBeginIndex=sequenceEndIndices(ii-1)+1;
%                     else
%                         sequenceBeginIndex=1;
%                     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    sequenceBeginIndex=fixationIndices(ii);
                    if sequenceBeginIndex>1 && tChangeValues(sequenceBeginIndex-1)>=triggerPartitionerStruct.TARGET_TRIGGER_OFFSET
                        sequenceBeginIndex=sequenceBeginIndex-1;
                        
                         %update
                        targetLabel=tChangeValues(sequenceBeginIndex)-triggerPartitionerStruct.TARGET_TRIGGER_OFFSET;
                        sequenceTrialCount=sequenceEndIndex-2-sequenceBeginIndex;
                        tempTrialLabels=tChangeValues((sequenceBeginIndex+2):sequenceEndIndex-1);
                        %update trialLabels from tChaneValues(sequenceBeginIndex+2 to SequenceEndIndex-1)
                        
                        if isMatrix && iscell(trialLabels)
                            
                            %%%%%%%%%%%%%%%%%%%%%% MatrixFormat %%%%%%%%%%%%%%%%%%%%%%%%%%
                            tmpSequence=matrixSequences(ii).trials;
                            for j=trialIndex:trialIndex+sequenceTrialCount-1
                                trialLabels{j}=trialIDs(find(str2num(tmpSequence{tempTrialLabels(j-trialIndex+1)}(:))));
                                tmp=find(trialLabels{j}==targetLabel);
                                if sum(tmp)>0
                                    trialTargetness(j)=1;
                                else
                                    trialTargetness(j)=0;
                                end
                            end
                            
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            
                        else
                            trialLabels(trialIndex:trialIndex+sequenceTrialCount-1)=tempTrialLabels;
                            
                            trialTargetness(trialIndex:trialIndex+sequenceTrialCount-1)=(tempTrialLabels==targetLabel);
                        end
                        %update trialSampleIndices to the sum of
                        %firstUnprocessedTimeIndex plus tChangeLoc(sequenceBeginIndex+2 to sequenceEndIndex-1)-1
                        trialSampleTimeIndices(trialIndex:trialIndex+sequenceTrialCount-1)=firstUnprocessedTimeIndex+tChangeLoc((sequenceBeginIndex+2):sequenceEndIndex-1)-1;
                        %update trialIndex equal to the old value of trialIndex plus sequenceTrialCount
                        trialIndex=trialIndex+sequenceTrialCount;
                        
                        
                    else
                        
                         sequenceTrialCount=sequenceEndIndex-1-sequenceBeginIndex;
                        %check whether sequence begin index equal to
                        %fixation index,if so
                        %update trialLabels from tChaneValues(sequenceBeginIndex+1 to SequenceEndIndex-1)
                        if isMatrix && iscell(trialLabels)
                            %%%%%%%%%%%%%%%%%%%%%% MatrixFormat %%%%%%%%%%%%%%%%%%%%%%%%%%
                            tmpSequence=matrixSequences(ii).trials;
                            for j=trialIndex:trialIndex+sequenceTrialCount-1
                                trialLabels{j}=trialIDs(find(str2num(tmpSequence{tChangeValues((sequenceBeginIndex+1+j-trialIndex))}(:))));
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        else
                            trialLabels(trialIndex:trialIndex+sequenceTrialCount-1)=tChangeValues((sequenceBeginIndex+1):sequenceEndIndex-1);
                        end
                        %update trialSampleIndices to the sum of
                        %firstUnprocessedTimeIndex plus tChangeLoc(sequenceBeginIndex+1 to sequenceEndIndex-1)-1
                        trialSampleTimeIndices(trialIndex:trialIndex+sequenceTrialCount-1)=firstUnprocessedTimeIndex+tChangeLoc((sequenceBeginIndex+1):sequenceEndIndex-1)-1;
                        
                        %update trialIndex equal to the old value of trialIndex plus sequenceTrialCount
                        trialIndex=trialIndex+sequenceTrialCount;
                        
                    end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
%                     if(sequenceBeginIndex==fixationIndices(ii))
                        
                        
%                         sequenceTrialCount=sequenceEndIndex-1-sequenceBeginIndex;
%                         %check whether sequence begin index equal to
%                         %fixation index,if so
%                         %update trialLabels from tChaneValues(sequenceBeginIndex+1 to SequenceEndIndex-1)
%                         if isMatrix && iscell(trialLabels)
%                             %%%%%%%%%%%%%%%%%%%%%% MatrixFormat %%%%%%%%%%%%%%%%%%%%%%%%%%
%                             tmpSequence=matrixSequences(ii).trials;
%                             for j=trialIndex:trialIndex+sequenceTrialCount-1
%                                 trialLabels{j}=trialIDs(find(str2num(tmpSequence{tChangeValues((sequenceBeginIndex+1+j-trialIndex))}(:))));
%                             end
%                             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         else
%                             trialLabels(trialIndex:trialIndex+sequenceTrialCount-1)=tChangeValues((sequenceBeginIndex+1):sequenceEndIndex-1);
%                         end
%                         %update trialSampleIndices to the sum of
%                         %firstUnprocessedTimeIndex plus tChangeLoc(sequenceBeginIndex+1 to sequenceEndIndex-1)-1
%                         trialSampleTimeIndices(trialIndex:trialIndex+sequenceTrialCount-1)=firstUnprocessedTimeIndex+tChangeLoc((sequenceBeginIndex+1):sequenceEndIndex-1)-1;
%                         
%                         %update trialIndex equal to the old value of trialIndex plus sequenceTrialCount
%                         trialIndex=trialIndex+sequenceTrialCount;
%                     else
%                         %update
%                         targetLabel=tChangeValues(sequenceBeginIndex)-triggerPartitionerStruct.TARGET_TRIGGER_OFFSET;
%                         sequenceTrialCount=sequenceEndIndex-2-sequenceBeginIndex;
%                         tempTrialLabels=tChangeValues((sequenceBeginIndex+2):sequenceEndIndex-1);
%                         %update trialLabels from tChaneValues(sequenceBeginIndex+2 to SequenceEndIndex-1)
%                         
%                         if isMatrix && iscell(trialLabels)
%                             
%                             %%%%%%%%%%%%%%%%%%%%%% MatrixFormat %%%%%%%%%%%%%%%%%%%%%%%%%%
%                             tmpSequence=matrixSequences(ii).trials;
%                             for j=trialIndex:trialIndex+sequenceTrialCount-1
%                                 trialLabels{j}=trialIDs(find(str2num(tmpSequence{tempTrialLabels(j-trialIndex+1)}(:))));
%                                 tmp=find(trialLabels{j}==targetLabel);
%                                 if sum(tmp)>0
%                                     trialTargetness(j)=1;
%                                 else
%                                     trialTargetness(j)=0;
%                                 end
%                             end
%                             
%                             
%                             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                             
%                         else
%                             trialLabels(trialIndex:trialIndex+sequenceTrialCount-1)=tempTrialLabels;
%                             
%                             trialTargetness(trialIndex:trialIndex+sequenceTrialCount-1)=(tempTrialLabels==targetLabel);
%                         end
%                         %update trialSampleIndices to the sum of
%                         %firstUnprocessedTimeIndex plus tChangeLoc(sequenceBeginIndex+2 to sequenceEndIndex-1)-1
%                         trialSampleTimeIndices(trialIndex:trialIndex+sequenceTrialCount-1)=firstUnprocessedTimeIndex+tChangeLoc((sequenceBeginIndex+2):sequenceEndIndex-1)-1;
%                         %update trialIndex equal to the old value of trialIndex plus sequenceTrialCount
%                         trialIndex=trialIndex+sequenceTrialCount;
                        
%                     end
                    
                    
                    
                end
                %update firstUnprocessedTimeIndex
                firstUnprocessedTimeIndex=firstUnprocessedTimeIndex+tChangeLocAll(tChangeValuesispositiveIndices(sequenceEndIndicesWithPause(end))+1)-1;
                %firstUnprocessedTimeIndex=firstUnprocessedTimeIndex+tChangeLocAll(tChangeValuesispositiveIndices(sequenceEndIndex)+1)-1;
                
                
                
            end
        end
        %check if complete sequence count equal to zero
        if(completedSequenceCount==0)
            if(~isempty(tChangeLocAllRaw))
                %if tChangeLocAllRaw is empty,update firstUnprocessedTimeIndex
                %to firstUnprocessedTimeIndex plus tChangeLocALLRaw(1) -2
                firstUnprocessedTimeIndex=firstUnprocessedTimeIndex+tChangeLocAllRaw(1)-2;
            else
                %otherwise,update firstUnprocessedTimeIndex to
                %lastSampleTimeIndex
                firstUnprocessedTimeIndex=lastSampleTimeIndex;
            end
        end
        
    end
    
catch exception
    
    disp(exception);
    
    keyboard;
    
end