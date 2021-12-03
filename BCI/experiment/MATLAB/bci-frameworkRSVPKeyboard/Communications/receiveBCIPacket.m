%% receiveBCIPacket(tcpipObject,BCIPacketStruct)
% This template functions reads a packet separated by terminator from the buffer.
% This function parses BCI packet header and creates a receivedPacket struct.
%
%   The inputs of the function
%      tcpipObject - system object for tcp/ip communication
%
%      BCIPacketStruct - A structure containing header, header length and terminator
%      information.
%
% See also sender2receiverCommInitialize, sendBCIPacket, tcpipParameters.
%%
function [receivedPacket] = receiveBCIPacket(tcpipObject,BCIPacketStruct)

    receivedPacket.header = 0;
    receivedPacket.data = [];

    try
        if(tcpipObject.BytesAvailable)
            receivedStream = fscanf(tcpipObject);
            receivedPacket.header = hex2num(receivedStream(1:BCIPacketStruct.HDRLength));
            receivedPacket.data = receivedStream(BCIPacketStruct.HDRLength+1:end-length(BCIPacketStruct.terminator));

            switch(receivedPacket.header)
                case BCIPacketStruct.HDR.START
                    % Do nothing additional
                    
                case BCIPacketStruct.HDR.PAUSE
                    % Do nothing additional
                    
                case BCIPacketStruct.HDR.STOP
                    % Do nothing additional

                case BCIPacketStruct.HDR.DECISION
                    % Do nothing additional
                    receivedPacket.data = hex2num(reshape(receivedPacket.data,length(receivedPacket.data)/16,16));
                    
                case BCIPacketStruct.HDR.PARAMETERS
                    % Do nothing additional

                case BCIPacketStruct.HDR.TARGET
                    % Do nothing additional

                case BCIPacketStruct.HDR.PROBABILITIES
                    % Do nothing additional
                    labels = receivedStream(strfind(receivedStream,'<')+1 : strfind(receivedStream,'>')-1);
                    if(~isempty(labels))
                        labelSeparatorNdx = strfind(labels,',');
                        numberOfLabels = length(strfind(labels,','))+1;
                        receivedPacket.labels = cell(numberOfLabels,1);
                        for ii = 1:numberOfLabels
                            if ii == 1
                                receivedPacket.labels(ii) = {labels(1:labelSeparatorNdx(ii)-1)};
                            elseif ii == numberOfLabels
                                receivedPacket.labels(ii) = {labels(labelSeparatorNdx(ii-1)+1:end)};
                            else
                                receivedPacket.labels(ii) = {labels(labelSeparatorNdx(ii-1)+1:labelSeparatorNdx(ii)-1)};
                            end
                        end
                    else
                        receivedPacket.labels = [];
                    end
                    dataNdx = strfind(receivedStream,'>')+1;
                    receivedPacket.data = hex2num(reshape(receivedStream(dataNdx:end-2),length(receivedStream(dataNdx:end-2))/16,16));
                    
                case BCIPacketStruct.HDR.STATE
                    % Do nothing additional

                case BCIPacketStruct.HDR.MESSAGE
                    % Do nothing additional
                    
                case BCIPacketStruct.HDR.SIGNAL
                    % Do nothing additional

                case  BCIPacketStruct.HDR.ROBOT
                    % Do nothing additional

            end

        end
        
    catch ME
        logError(ME);
    end
end