%% sendDecisionPacket(decision)
% sendDecisionPacket is the function that communicates with the presentation. Input decision is a
% structure that might contain a subset of the following fields to be sent to the presentation.
% Possible fields which can be sent to the presentation are,
%
% * decision.decided - Index of the decided symbol
% * decision.nextSequence.target - Index of the target symbol to be shown
% * decision.nextSequence.trials - Index of the trial symbols to be shown
% * decision.feedback - cell vector containing the list of feedback texts. Each element is a
% structure with Type, for the color of text, and Text fields.
%
%%

function sendDecisionPacket(decision,main2presentationCommObjectStruct,BCIPacketStruct)

packet2send.header = BCIPacketStruct.HDR.MESSAGE;
packet2send.data = '';

if(isfield(decision,'decided') && ~isempty(decision.decided))
    
    packet2send.data = [packet2send.data 'D=[' sprintf('%d,',decision.decided) ';'];
    packet2send.data(end-1)=']';
    
end

if(isfield(decision,'levelUp') && ~isempty(decision.levelUp)) && decision.levelUp
    
    packet2send.data = [packet2send.data 'LU=[' sprintf('%d,',decision.levelUp) ';'];
    packet2send.data(end-1)=']';
    
end

if(isfield(decision,'showTarget') && ~isempty(decision.showTarget))
    
    packet2send.data = [packet2send.data 'ST=[' sprintf('%d,',decision.showTarget) ';'];
    packet2send.data(end-1)=']';
    
end

if(isfield(decision,'nextSequence'))
    
    if(isfield(decision.nextSequence,'target') && ~isempty(decision.nextSequence.target))
        
        packet2send.data = [packet2send.data sprintf('T=%d',decision.nextSequence.target) ';'];
        
    end
    
    if(isfield(decision.nextSequence,'trials') && ~isempty(decision.nextSequence.trials))
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %decision.nextSequence.trials
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if iscell(decision.nextSequence.trials)
            
            
            packet2send.data = [packet2send.data 't={' sprintf('''%s'',',decision.nextSequence.trials{:}) ';'];
            packet2send.data(end-1)='}';
        else
            packet2send.data = [packet2send.data 't=[' sprintf('%d,',decision.nextSequence.trials) ';'];
            packet2send.data(end-1)=']';
        end
        if isfield(decision.nextSequence,'Type')
            packet2send.data = [packet2send.data 'tt=[' sprintf('''%s'',',decision.nextSequence.Type) ';'];
            packet2send.data(end-1)=']';
        end
        
        
    end
    
end

if(isfield(decision,'feedback'))
    
    for feedbackIndex = 1:length(decision.feedback)
        
        switch decision.feedback{feedbackIndex}.Type
            case 'neutral'
                feedbackHeader='0';
            case 'positive'
                feedbackHeader='+';
            case 'negative'
                feedbackHeader='-';
        end
        
        packet2send.data = [packet2send.data 'f{' num2str(feedbackIndex) '}=''' feedbackHeader decision.feedback{feedbackIndex}.Text ''';'];
        
    end
    
end

if isfield(decision, 'posteriorProbs')
    
    packet2send.data = [packet2send.data,'p=[',sprintf('%d,',decision.posteriorProbs),';'];
    packet2send.data(end - 1) = ']';
    
end

[success] = sendBCIPacket(main2presentationCommObjectStruct.main2presentationCommObject,BCIPacketStruct,packet2send);
end