%% initializeSignalProcessing
%initializeSignalProcessing
% Initializes the signal processing. It loads the parameters, frontend
% filter
%  information, sets up data acquisition buffers.
%
%   The frontend filter information is contained in a file named as
%   inputFilterCoef.mat. It contains the following structure,
%       frontendFilter - It should have the following fields,
%               frontendFilter.groupDelay - shift to be introduced for
%               triggers in samples frontendFilter.Den - denominator
%               coefficients of the
%                       filter. This should be 1 for FIR filters.
%               frontendFilter.Num - numerator coefficients of the
%                       filter.
%               frontendFilter.filteringFlag - Enables (1)/disables (0) the
%                       frontend filtering before buffering. This flag is
%                       set in this routine from mainBuffer structure
%                       loaded from signal processing parameters.
%
%
%  See also signalProcessing, dataBuffer
%%

    %% filterState: Global variable to define the filter conditions, which will be updated after each filtering operation.
global filterState

    %% Loading the signal processing parameters.
signalProcessingParameters;
    
    %% Loading the frontend filter information.
load 'inputFilterCoef.mat'    
bpFilter = frontEndFilterBP(daqStruct.fs);
frontendFilter.Num=bpFilter.numerator;
grpDel = bpFilter.groupdelay;
frontendFilter.groupDelay=round(grpDel.Data(1));


    %% Calculating the buffer size in samples and creates a dataBuffer class object for non-trigger data.
    bufferLength=DAQClassObj.fs*mainBuffer.bufferDurationSec;
    
bufferType=strcmpi(mainBuffer.bufferingMethod,'linear');

dataBufferObject=dataBuffer(bufferLength,length(daqStruct.channelsToAcquire),bufferType);

    %% If frontend filtering is not enabled, there is no group delay introduced by it.
if(~mainBuffer.frontendFilteringFlag)
    frontendFilter.groupDelay=0;
end
frontendFilter.filteringFlag=mainBuffer.frontendFilteringFlag;

    %% Initializes the dataBuffer object for the trigger signal.
    %Group delay of the frontend filter requires a shift in the triggers.
    %Hence the dataBuffer object corresponding to triggers contain a
    %corresponding shift.
triggerBufferObject=dataBuffer(bufferLength,1,bufferType,frontendFilter.groupDelay);

    %% Initializes the beginning filter conditions as zero.
filterState=zeros(max(length(frontendFilter.Num),length(frontendFilter.Den))-1,length(daqStruct.channelsToAcquire));

    %% calls the initializeArtifactFiltering script
% initializeArtifactFiltering



