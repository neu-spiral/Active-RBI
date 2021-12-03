%% [success,CommObjectStruct,BCIPacketStruct]=sender2receiverCommInitialize(sender,receiver,CommObjectStruct,receiverIP,receiverPort)
%sender2receiverCommInitialize(sender,receiver,CommObjectStruct,receiverIP,receiverPort) 
% is template  function to create TCP/IP object for communication. Properties like - InputBufferSize,OutputBufferSize,Terminator used for
% the connection are specified in tcpipParameters file.
%
%   The inputs of the function
%
%       sender - is a string specifying name of the sender MATLAB. Options -
%       'main', 'presentation', 'GUI', 'DAQ'
%       (A a converntion, if sender is set to'main' then TCP/IP object acts as
%       server or else is acts as client).
%
%       reciever - is string specifying name of the reciever MATLAB. Options -
%       'main', 'presentation', 'GUI', 'DAQ'.
%
%       interrupts - is a boolean specifying if the comm object uses the BytesAvailable function.
%       WARNING: If interrupts is set to true, then the name of the output variable for
%       CommObjectStruct MUST also be named CommObjectStruct, and MUST be declared in the main workspace.
%
%       CommObjectStruct - is a struct containing TCP/IP objects that has been
%       created previously. 
%
%       receiverIP - IP address of the reciver computer .If same computer runs
%       both sender and reciever then receiverIP is 'localhost'. Default if
%       'localhost'.
%
%       receiverPort - portnumber that is used for the communication between
%       the sender and reciever functions. If no value is mentioned default value is used in the tcp/ip object.
%
%
%   The outputs of the function
%
%       success (0/1) - A flag that shows the success of the process.
%
%       CommObjectStruct - Structrue containf TCP/IP object as elements.
%
%       BCIPacketStruct - A structure containing header, header length and terminator
%       information. Having this function as an output variable help passing
%       them to receiveMainPacket function ( a callback funtction that
%       executes from the base workspace.
%
%
%  See also sendBCIPacket, receiveBCIPacket, tcpipParameters.
%%
function [success,CommObjectStruct,BCIPacketStruct] = sender2receiverCommInitialize(sender,receiver,interrupts,CommObjectStruct,receiverIP,receiverPort)
    global errorFilename,
    if(isempty(errorFilename))
        errorFilename = [sender '2' receiver 'CommInitializeErrorFile.txt'];
    end
    eval(['global ' sender '2' receiver 'CommInitialize']);
    if(exist('logError','file')~=2)
        addpath('..\GeneralFramework');
        addpath('..\Parameters');
    end


    %% Read TCP/IP connection parameters

    tcpipParameters;

    %% Checking for the input variables
    switch(nargin)
        case {0,1,2}
            error('Please specify sender and receiever.');
        case 3
            invalidInputArg = isempty(find(strcmpi(sender,{'main','presentation','GUI','DAQ'}), 1));
            if(invalidInputArg)
                disp('Valid sender options - ''main'',''presentation'',''GUI'',''DAQ''');
                error('Provide valid sender.');
            end
            invalidInputArg = isempty(find(strcmpi(receiver,{'main','presentation','GUI','DAQ'}), 1));
            if(invalidInputArg)
                disp('Valid receiver options - ''main'',''presentation'',''GUI'',''DAQ''');
                error('Provide valid receiver.');
            end
            receiverIP=input(['Please enter the ',receiver,' IP address [localhost]:'],'s');
            if(isempty(receiverIP))
                receiverIP='localhost'; % If no IP number is entered, local host option is assumed for the tcp/ip object
            end
            receiverPort=input(['Please enter the ',receiver,' port number [52957]:'],'s');
            if(isempty(receiverPort))
                receiverPort=52957; % Default port number
            else
                receiverPort=str2int(receiverPort);
            end
            CommObjectStruct = [];
        case 4
            invalidInputArg = isempty(find(strcmpi(sender,{'main','presentation','GUI','DAQ'}), 1));
            if(invalidInputArg)
                disp('Valid sender options - ''main'',''presentation'',''GUI'',''DAQ''');
                error('Provide valid sender.');
            end
            invalidInputArg = isempty(find(strcmpi(receiver,{'main','presentation','GUI','DAQ'}), 1));
            if(invalidInputArg)
                disp('Valid receiver options - ''main'',''presentation'',''GUI'',''DAQ''');
                error('Provide valid receiver.');
            end
            receiverIP=input(['Please enter the ',receiver,' IP address [localhost]:'],'s');
            if(isempty(receiverIP))
                receiverIP='localhost'; % If no IP number is entered, local host option is assumed for the tcp/ip object
            end
            receiverPort=input(['Please enter the ',receiver,' port number [52957]:'],'s');
            if(isempty(receiverPort))
                receiverPort=52957; % Default port number
            else
                receiverPort=str2int(receiverPort);
            end
        case 5
            receiverPort=receiverIP;
            receiverIP='localhost';
    end
    %% Creating the TCP/IP object

    try

        if interrupts

            if(strcmpi(sender,'main'))
                eval(...
                        [...
                            'CommObjectStruct.',sender, '2' , receiver,'CommObject = tcpip(receiverIP,receiverPort,',...
                            ' ''NetworkRole'', ''server'', ',...
                            ' ''Terminator'', BCIPacketStruct.terminator, ',...
                            ' ''OutputBufferSize'', tcpipBufferSize.output, ',...
                            ' ''InputBufferSize'', tcpipBufferSize.input, ',...
                            ' ''BytesAvailableFcn'', ''receiveBCIPacket(CommObjectStruct.',sender,'2',receiver,'CommObject,BCIPacketStruct)'', ',...
                            ' ''BytesAvailableFcnMode'',''terminator'' ',...
                            ');'...
                        ]...
                    );
                disp(['TCP/IP server started']);
            else
                eval(...
                        [...
                            'CommObjectStruct.',sender, '2' , receiver,'CommObject = tcpip(receiverIP,receiverPort,',...
                            ' ''NetworkRole'', ''client'', ',...
                            ' ''Terminator'', BCIPacketStruct.terminator, ',...
                            ' ''OutputBufferSize'', tcpipBufferSize.output, ',...
                            ' ''InputBufferSize'', tcpipBufferSize.input ',...
                            ' ''BytesAvailableFcn'', ''receiveBCIPacket(CommObjectStruct.',sender,'2',receiver,'CommObject,BCIPacketStruct)'', ',...
                            ' ''BytesAvailableFcnMode'',''terminator'' ',...
                            ');'...
                        ]...
                    );
                disp(['TCP/IP client started']);
            end

        else

            if(strcmpi(sender,'main'))
                eval(...
                        [...
                            'CommObjectStruct.',sender, '2' , receiver,'CommObject = tcpip(receiverIP,receiverPort,',...
                            ' ''NetworkRole'', ''server'', ',...
                            ' ''Terminator'', BCIPacketStruct.terminator, ',...
                            ' ''OutputBufferSize'', tcpipBufferSize.output, ',...
                            ' ''InputBufferSize'', tcpipBufferSize.input ',...
                            ');'...
                        ]...
                    );
                disp(['TCP/IP server started']);
            else
                eval(...
                        [...
                            'CommObjectStruct.',sender, '2' , receiver,'CommObject = tcpip(receiverIP,receiverPort,',...
                            ' ''NetworkRole'', ''client'', ',...
                            ' ''Terminator'', BCIPacketStruct.terminator, ',...
                            ' ''OutputBufferSize'', tcpipBufferSize.output, ',...
                            ' ''InputBufferSize'', tcpipBufferSize.input ',...
                            ');'...
                        ]...
                    );
                disp(['TCP/IP client started']);
            end
            
        end
        
        eval(['fopen(CommObjectStruct.',sender,'2',receiver,'CommObject);']);
        success = true;
    catch ME
        logError(ME);
        success = false;
    end
end