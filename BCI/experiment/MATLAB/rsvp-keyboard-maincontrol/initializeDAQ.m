%% initializeDAQ Script
% initializeDAQ is a script which checks Data Acquisition type and
% accordingly calls appropiate function for data acquisition.

%%

% Set parameters and create object

DAQParameters;
%%%

if(strcmp(daqStruct.DAQType,'gUSBAmp'))
    DAQClassObj = DAQgUSBAmp('channelList',daqStruct.channelsToAcquire, ...
                                'fs',daqStruct.fs,...
                                'triggerFlag',logical(daqStruct.triggerFlag), ...
                                'notchFilterNdx',daqStruct.notchFiltexNdx, ...
                                'ampFilterNdx',daqStruct.ampFilterNdx, ...
                                'frontEndFilterFlag', daqStruct.frontEndFilterFlag, ...
                                'testParallelPortFlag', daqStruct.testParallelPortFlag, ...
                                'channelNames', daqStruct.channelNames, ...
                                'calibrationFlag', daqStruct.calibrationOn);
elseif (strcmp(daqStruct.DAQType,'DSI'))  
    DAQClassObj = DAQDSI('channelList',daqStruct.channelsToAcquire, ...
                                'fs',daqStruct.fs,...
                                'triggerFlag',logical(daqStruct.triggerFlag), ...
                                'frontEndFilterFlag', daqStruct.frontEndFilterFlag, ...
                                'testParallelPortFlag', daqStruct.testParallelPortFlag, ...
                                'channelNames', daqStruct.channelNames);
else
    DAQClassObj = DAQnoAmp('channelList', daqStruct.channelsToAcquire, ...
                        'triggerType', 'custom', ...
                        'fs', daqStruct.fs, ...
                        'channelNames', daqStruct.channelNames, ...
                        'frontEndFilterFlag', false);
end
%% Initialize the artificial triggers parameters
presentationParameters
artificialsTriggersParams.ERP.Duration.Target=presentationStruct.Duration.Target;
artificialsTriggersParams.ERP.DutyCycle.Target=presentationStruct.DutyCycle.Target;
artificialsTriggersParams.ERP.Duration.Fixation=presentationStruct.Duration.Fixation;
artificialsTriggersParams.ERP.DutyCycle.Fixation=presentationStruct.DutyCycle.Fixation;
artificialsTriggersParams.ERP.DutyCycle.Trial=presentationStruct.DutyCycle.ERPTrial;
artificialsTriggersParams.ERP.Duration.Trial=presentationStruct.Duration.ERPTrial;
% artificialsTriggersParams.ERP.DutyCycle.FRPTrial=presentationStruct.DutyCycle.FRPTrial;
% artificialsTriggersParams.ERP.Duration.FRPTrial=presentationStruct.Duration.FRPTrial;
artificialsTriggersParams.ERP.Duration.SequenceEnd=presentationStruct.Duration.SequenceEnd;
artificialsTriggersParams.ERP.DutyCycle.SequenceEnd=presentationStruct.DutyCycle.SequenceEnd;


artificialsTriggersParams.FRP=artificialsTriggersParams.ERP;
artificialsTriggersParams.FRP.DutyCycle.Trial=presentationStruct.DutyCycle.FRPTrial;
artificialsTriggersParams.FRP.Duration.Trial=presentationStruct.Duration.FRPTrial;

clear('presentationStruct')
clear('DeveloperMode')


 