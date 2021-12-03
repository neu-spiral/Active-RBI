%% [success]=signalProcessing(amplifierStruct,dataBufferObject,triggerBufferObject,frontendFilter)
%signalProcessing(amplifierStruct,dataBufferObject,triggerBufferObject,frontendFilter)
%   fetches the data from the amplifier(s), applies the initial signal
%   processing of bandpass filtering and buffering.
%
%   The inputs of the function
%          amplifierStruct - A structure that contains the amplifier
%          information.
%
%          dataBufferObject - a dataBuffer class object containing the
%          buffer corresponding to non-trigger data. After the call of the
%          function, the object will be modified using the newly acquired
%          data.
%
%          triggerBufferObject - a dataBuffer class object containing the
%          buffer corresponding to trigger signal. After the call of the
%          function, the object will be modified using the newly acquired
%          data of the trigger channel.
%
%          frontendFilter - the structure containing the frontend filter
%          information. It should have the following fields,
%               frontendFilter.groupDelay - shift to be introduced for triggers in samples
%               frontendFilter.Den - denominator coefficients of the
%                       filter. This should be 1 for FIR filters.
%               frontendFilter.Num - numerator coefficients of the
%                       filter.
%
%   The outputs of the function
%          success (0/1) - a flag to show the success of the operation
%
%   See also dataBuffer, initializeSignalProcessing
%%

function [success,filteredData] = signalProcessing(rawData,triggerData,dataBufferObject,triggerBufferObject,frontendFilter)

    %% Global variable to define state of the filter
    global filterState;
    filteredData = [];

    try
        
        %% If the fetched data is non-empty, filter and buffer it.
        if(~isempty(rawData))
            
            %% If filtering is enabled, apply the filter on non-trigger channels.
            if(frontendFilter.filteringFlag)
                
                [filteredData, filterState] = filter(frontendFilter.Num,frontendFilter.Den,rawData,filterState,1);
                
            else
                
                filteredData = rawData;
                
            end

            %% Buffer the new data and triggers into corresponding buffer objects.
            dataBufferObject.addData(filteredData);
            triggerBufferObject.addData(triggerData);

        end
        success = true;
        
    catch ME
        
        logError(ME);
        success = false;
        
    end

end