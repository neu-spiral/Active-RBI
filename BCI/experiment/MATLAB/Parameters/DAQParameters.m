%% DAQParameters
% Contains user adjustable parameter file corresponding to data acquisition.
%    It creates a structure (daqStruct) with the following fields,
%
% * daqStruct.fs - sampling frequency
% * daqStruct.ampFilterNdx - Filter index for using built-in bandpass amplifier filter
% * daqStruct.notchFiltexNdx - Filter index for using built-in notch amplifier filter
% * daqStruct.ampBufferLengthSec - Amplifier buffer length in seconds.
% * daqStruct.calibrationOn - Amplifier calibration enable flag
%
%%


%% Sampling Frequency (default 256)%for DSI 300
if (strcmp(RSVPKeyboardParams.DAQType,'DSI')||strcmp(RSVPKeyboardParams.DAQType,'noAmpDSI'))
daqStruct.fs = 300;
else
daqStruct.fs = 256;
end

%% Bandpass filter and notch filter 
% Filter indices for using built-in amplifier filters
%
% For daqStruct.ampFilterNdx, 41 corresponds to 0.01-100 Hz bandpass filter,
% -1 corresponds to no bandpass filter.
%
% For daqStruct.notchFiltexNdx, 3 corresponds to 60 Hz notch filter and -1 corresponds to no notch
% filter.
%
% An example of valid filters for 256 Hz sampling frequency
%     To find filter indices for given sample rate - type
%     gUSBampShowFilter(fs) on command window
%
%     Valid Bandpass Filters for 256 Hz:
%     Filter:	HP:		LP:		Order:	Type:
%     __________________________________________
%     32		0.10	0.00	8		butter
%     33		1.00	0.00	8		butter
%     34		2.00	0.00	8		butter
%     35		5.00	0.00	8		butter
%     36		0.00	30.00	8		butter
%     37		0.00	60.00	8		butter
%     38		0.00	100.00	8		butter
%     39		0.01	30.00	6		butter
%     40		0.01	60.00	8		butter
%     41		0.01	100.00	8		butter
%     42		0.10	30.00	8		butter
%     43		0.10	60.00	8		butter
%     44		0.10	100.00	8		butter
%     45		0.50	30.00	8		butter
%     46		0.50	60.00	8		butter
%     47		0.50	100.00	8		butter
%     48		2.00	30.00	8		butter
%     49		2.00	60.00	8		butter
%     50		2.00	100.00	8		butter
%     51		5.00	30.00	8		butter
%     52		5.00	60.00	8		butter
%     53		5.00	100.00	8		butter
% 
%     Valid Notch Filters for 256 Hz:
%     Filter:	HP:		LP:		Order:	Type:
%     __________________________________________
%     2		48.00	52.00	4		butter
%     3		58.00	62.00	4		butter
daqStruct.ampFilterNdx = -1; 
daqStruct.notchFiltexNdx = -1; 

%% Amplifier buffer length 
% It sets the buffer of the data acquisition toolbox. If set to infinity the
% data acquisition toolbox continually acquires data.
daqStruct.ampBufferLengthSec = Inf;   %in seconds

%% Calibration flag
% Enables (1)/disables (0) the calibration of the amplifiers. If it is
% disabled, amplifiers will initialize quicker but might contain unusal
% offsets or scales. It is recommended not to disable it during the experiments.
daqStruct.calibrationOn=0;

%% frontFiltered flag
% Enables (true)/ disables(false). If it is disable it collects raw data.
% If it is enable it aplies after fronted filtered. 
 
daqStruct.frontEndFilterFlag= false;

%% channel List
if (strcmp(RSVPKeyboardParams.DAQType,'DSI')||strcmp(RSVPKeyboardParams.DAQType,'noAmpDSI'))
daqStruct.channelsToAcquire=[1:20];
daqStruct.channelNames={'P3','C3','F3','Fz','F4','C4','P4','Cz','A1','Fp1','Fp2','T3','T5','O1','O2','F7','F8','A2','T6','T4'};
daqStruct.extension='.csv';
else
daqStruct.channelsToAcquire=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
daqStruct.channelNames={'Fp1','Fp2','F3','F4','Fz','Fc1','Fc2','Cz','P1','P2','C1','C2','Cp3','Cp4','P5','P6'};
daqStruct.extension='.bin';
end

%Enables (true) / disables(false) testParallelPort Flag
daqStruct.testParallelPortFlag=true; 

%% Mode of acquisition system.

% Available options are 'gUSBAmp' and 'noAmp'.
%
% * 'gUSBAmp': Acquires data from gTec's g.USBAmp amplifier
% * 'noAmp' : Uses no amplifiers to record. It generates artificial signals or can play a previously
daqStruct.DAQType=RSVPKeyboardParams.DAQType;

%% triggerFlag
daqStruct.triggerFlag=1;

if(strcmp(RSVPKeyboardParams.DAQType,'noAmpDSI'))
    RSVPKeyboardParams.DAQType='noAmp';
    daqStruct.DAQType='noAmp';
end