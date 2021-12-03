%% signalProcessingParameters
% Contains user adjustable parameter file corresponding to signal processing. It creates the
% following structure,
%
%   mainBuffer: Contains the parameters for the initial signal processing after fetching the data.
%   The processing consists of bandpass filtering and buffering. The following fields are set as
%   parameters,
% * mainBuffer.bufferingMethod - Buffering type ('linear'/'circular')
% * mainBuffer.bufferDurationSec - Length of the buffer in seconds
% * mainBuffer.frontendFilteringFlag - Enables (1)/disables (0) the frontend filtering before
% buffering
%
%%

%% Buffering type
% Sets the buffering data structure, it can be set to linear or circular.
% If it is set to linear, setting a high buffer duration might cause delays
% in the system.
mainBuffer.bufferingMethod = 'circular'; % 'linear' / 'circular'

%% Buffer duration
% Sets the size of the data buffer in seconds.
mainBuffer.bufferDurationSec=100; %in seconds.

%% Front end filtering enabled flag
% Enables (1)/disables (0) the frontend filtering before buffering. The
% filter coefficients contained in inputFilterCoef.mat. Filter information
% is hold in a structure named frontendFilter with the fields groupDelay,
% Den and Num.
mainBuffer.frontendFilteringFlag=1;


