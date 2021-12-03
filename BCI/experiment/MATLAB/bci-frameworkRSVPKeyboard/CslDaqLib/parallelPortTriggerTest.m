%% success=parallelPortTriggerTest(amplifierStruct,recordingFilename,fs)
%parallelPortTriggerTest(amplifierStruct,recordingFilename,fs) tests the
% triggers received by the amplifiers. This function uses the inpout
% library for the communication with the PCI port. The function checks the
% following properties of the triggers.
%   * The connection of the higher and the lower 4 bits.
%   * The number of the triggers sent and received.
%   * The values of the triggers sent and received.
%   * The pulse width of the triggers sent and received.
%   * The values of the first and last triggers sent and received.
%
%   The inputs of the function
%
%     amplfierStruct - A structure that contains information about the
%     amplifiers connected to the system.
%
%     recordingFilename - A string that contains the directory and the
%     filename of the file where we save the trigger test.
%
%     fs - Sampling frequency.
%
%   The outputs of the function
%
%      success (0/1) - A flag that show the success of the procedure.
%%


function success=parallelPortTriggerTest(amplifierStruct,recordingFilename,fs,parallelPortIOListinhex)
%% Setting the properties of the trigger pulses we send to the amplifier

triggerPulsewidth=10/fs;
numberOfTestIterations=10;
triggerTestValues=[15;240];
triggerPulsewidthStdThreshold=1/fs;

%decParallelPortNumber=hex2dec('2020'); % the port number of the PCI port.

%Check the port number of the PCI port under device manager. Once you click
%on the PCI port under ports in device manager, the port number is the
%first number under the resources tab.


initializeParallelPortTriggerSender(parallelPortIOListinhex)

[success]=startAmps(amplifierStruct,[recordingFilename '_TriggerTest']);


triggerTestContinue=1;
while(triggerTestContinue)
    pause(0.050);
    
    %% Using the inpout library to communicate with the PCI port.
    for(ii=1:numberOfTestIterations)
        for(triggerTestIndex=1:length(triggerTestValues))
            tic;
            sendTrigger(triggerTestValues(triggerTestIndex));
            %calllib('inpout32','Out32',decParallelPortNumber,triggerTestValues(triggerTestIndex));
            while(toc<triggerPulsewidth)
            end
        end
    end
    sendTrigger(0);
    
    %    calllib('inpout32','Out32',decParallelPortNumber,0);
    
    
    pause(0.1);
    %% Reading the trigger data from amplifiers and testing if the received trigger properties are the same as the ones that we sent.
    
    [success,rawData,triggerData]=getAmpsData(amplifierStruct); % The function to get the data from amplifiers.
    
    
    
    
    
    diffTriggerLocs=find(diff(triggerData));
    triggerChangeValues=triggerData(diffTriggerLocs(1:end-1)+1);
    firstTriggerValue=triggerData(1);
    lastTriggerValue=triggerData(end);
    
    uniqueTriggerValues=unique(triggerData);
    if(isempty(find(uniqueTriggerValues==triggerTestValues(1), 1))) % Checking if the lower 4 bits are working properly
        lower4bitsOk=0;
    else
        lower4bitsOk=1;
    end
    
    if(isempty(find(uniqueTriggerValues==triggerTestValues(2), 1))) % Checking if the higher 4 bits are working properly
        higher4bitsOk=0;
    else
        higher4bitsOk=1;
    end
    
    if(firstTriggerValue~=0 || lastTriggerValue~=0) % First and last received trigger values should be zero
        errorMsg='Trigger test failed: Cannot set the trigger to zero.';
        success=0;
        %logError(errorMsg,0);
        break;
    end
    
    
    success=0;
    expectedTriggerValues=repmat(triggerTestValues,numberOfTestIterations,1);
    if(lower4bitsOk && higher4bitsOk)
        if(length(expectedTriggerValues)~=length(triggerChangeValues)) % Checking the number of the received triggers
            errorMsg='Trigger test failed: Unexpected number of trigger pulses';
        else
            if(any(expectedTriggerValues~=round(triggerChangeValues))) % Checking the values of the received triggers
                errorMsg='Trigger test failed: Digital I/O cables might be connected in wrong order. Please swap the cables.';
            else
                if(std(diff(diffTriggerLocs(2:end)))>triggerPulsewidthStdThreshold) % Checking the pulsewidth of the received triggers
                    errorMsg='Trigger test failed: Trigger timing is not accurate.';
                else
                    disp('Trigger test was successful.');
                    success=1;
                end
            end
        end
    elseif(~lower4bitsOk && higher4bitsOk)
        errorMsg='Trigger test failed: First digital I/O cable is not working.';
    elseif(lower4bitsOk && ~higher4bitsOk)
        errorMsg='Trigger test failed: Second digital I/O cable is not working.';
    else
        errorMsg='Trigger test failed: No triggers are received. Please check the connections.';
    end
    
    if(success==1)
        triggerTestContinue=0;
    else
        disp(errorMsg);
        tryAgain=input('Try again? (y/n):','s');
        if(tryAgain=='n')
            triggerTestContinue=0;
        end
    end
end

unloadlibrary('inpout32');
[success,~,~]=getAmpsData(amplifierStruct);
stopAmps(amplifierStruct);

if(success==0 && exist('errorMsg','var'))
    logError(errorMsg,0);
end

end