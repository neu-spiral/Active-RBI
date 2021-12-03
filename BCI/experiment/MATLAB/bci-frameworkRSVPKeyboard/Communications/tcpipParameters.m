%% tcpipParameters
%Contains TCP/IP communication parameters.
%   This files create following structures
%   TCPIPBufferSize -
%       *TCPIPBufferSize.input - input buffer size in bytes
%       *TCPIPBufferSize.output - output buffer size in bytes
%   BCIPacketStruct with following fields,
%       *BCIPacketStruct.HDR - defines header codes for different packet types
%       used in BCI projects. HDR structure has a specific code for all
%       possible packet type, with convention given below.
%           Header definition for different packet types:
%         BCIPacketStruct.HDR.START = 1;     % STARTS PRESENTATION
%         BCIPacketStruct.HDR.PAUSE = 2;     % PAUSES PRESENTATION
%         BCIPacketStruct.HDR.STOP = 3;      % STOPS PRESENTATION
%         BCIPacketStruct.HDR.DECISION = 4;  % SENDS DECISION
%         BCIPacketStruct.HDR.PARAMETERS = 5;% Presentation parameters
%         BCIPacketStruct.HDR.TARGET = 6;     % Target ID
%         BCIPacketStruct.HDR.PROBABILITIES = 7; % Language model probabilites
%         BCIPacketStruct.HDR.STATE = 8;     % 
%         BCIPacketStruct.HDR.MESSAGE = 9;   % 
%         BCIPacketStruct.HDR.SIGNAL = 10;    % Send EEG signals
%         BCIPacketStruct.HDR.ROBOT = 11;     % Controls Robot
%    *BCIPacketStruct.terminator - this field is appended in order to
%                                   receive callback while data is received.
%    *BCIPacketStruct.HDRLength - specifies number of characters to used in the
%    header.
%%
% TCP/IP parameters
tcpipBufferSize.input = 2^20; % in Bytes
tcpipBufferSize.output = 2^20;  % in Bytes

% Packet types used 
BCIPacketStruct.HDR.START = 1;     % STARTS PRESENTATION
BCIPacketStruct.HDR.PAUSE = 2;     % PAUSES PRESENTATION
BCIPacketStruct.HDR.STOP = 3;      % STOPS PRESENTATION
BCIPacketStruct.HDR.DECISION = 4;  % SENDS DECISION
BCIPacketStruct.HDR.PARAMETERS = 5;% Presentation parameters
BCIPacketStruct.HDR.TARGET = 6;     % Target ID
BCIPacketStruct.HDR.PROBABILITIES = 7; % Language model probabilites
BCIPacketStruct.HDR.STATE = 8;     % 
BCIPacketStruct.HDR.MESSAGE = 9;   % 
BCIPacketStruct.HDR.SIGNAL = 10;    % Send EEG signals
BCIPacketStruct.HDR.ROBOT = 11;     % Controls Robot

BCIPacketStruct.terminator = char(4); % Terminator for TCP/IP data; ascii for 'end of tranmission'
BCIPacketStruct.HDRLength = 16;