%%[success,packet2send] = sendBCIPacket(tcpipObject,BCIpacketHDR,packet2send)
%Writes data to TCP/IP buffer.
% This function coverts packet structure data into some predecided format
% and writes the buffer. In this function headers are sent as chars, packet
% data as hex if it's double or sent as is in case of chars. 
% For packets that might also send labels of the data, this function send
% header as characters, labels are sent comma-separated and enclosed in <>
% followed by hex doubles.
% For example for structure - 
%   packet2send.header = BCIPacketStruct.HDR.PROBABILITIES;
%   packet2send.data = [0.7 0.2 0.1];
%   packet2send.labels = {'icon1','icon2','icon20'}
%   <icon1,icon2,icon3>hex of data is sent.
%
% Inputs: tcpipObject - TCP/IP interface object.
%         packet2send - structure contating following fields
%           *packet2send.header - specifies type of the packet
%           *packet2send.data - data to be send (this field is optional as
%                              is not required in certain packets.)
%           *packet2send.labels - labels for the data (this field is optional
%                              as is not required in certain packets.Might
%                              be needed in order to specify data be sent)
% Outputs: success - Indicates if the packet was succesfully sent.
% 
% This function uses fprintf to write data to output buffer 
% See also tcpipParameters, main2presentationCommObject, presentation2mainCommObject
%%
function [success] = sendBCIPacket(tcpipObject,BCIPacketStruct,packet2send)
try
    
    packet2send.header = num2hex(packet2send.header);

    switch(packet2send.header)
        case BCIPacketStruct.HDR.START
            % Do nothing additional
        
        case BCIPacketStruct.HDR.PAUSE
            % Do nothing additional
            
        case BCIPacketStruct.HDR.STOP
            % Do nothing additional

        case BCIPacketStruct.HDR.DECISION
            packet2send.data = num2hex(packet2send.data);
            packet2send.data = reshape(packet2send.data,1,numel(packet2send.data));
            
        case BCIPacketStruct.HDR.PARAMETERS
            % Do nothing additional
            
        case BCIPacketStruct.HDR.TARGET
            % Do nothing additional
            
        case BCIPacketStruct.HDR.PROBABILITIES
            labels2send = '<';
            for ii = 1:length(packet2send.labels)
                if ii == length(packet2send.labels)
                    labels2send = [labels2send cell2mat(packet2send.labels(ii))];
                else
                    labels2send = [labels2send cell2mat(packet2send.labels(ii)) ','];
                end
            end
            labels2send = [labels2send '>'];
            packet2send.data = num2hex(packet2send.data);
            packet2send.data = reshape(packet2send.data,1,numel(packet2send.data));

        case BCIPacketStruct.HDR.STATE
            % Do nothing additional
            
        case BCIPacketStruct.HDR.MESSAGE
            % Do nothing additional

        case BCIPacketStruct.HDR.SIGNAL
            % Do nothing additional

        case BCIPacketStruct.HDR.ROBOT
            % Do nothing additional

    end
    
    fwrite(tcpipObject,[packet2send.header,packet2send.data,BCIPacketStruct.terminator]);
    
    success = true;
catch ME
    success = false;
    logError(ME);
end