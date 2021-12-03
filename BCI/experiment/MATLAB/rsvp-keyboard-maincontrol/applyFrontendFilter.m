%%[afterFrontendFilterData,afterFrontendFilterTrigger] = applyFrontendFilter(rawData,triggerSignal,frontendFilteringFlag,frontendFilter)
% If frontendFilteringFlag is true, the function applies a filter to rawData. Otherwise, returns the original data. The filter applied is affected by the given frontend filter struct.
%
%	The inputs of the function:
%
%		rawData - A vector of data that is to be filtered by the function.
%
%		triggerSignal - A vector of data that is used to track properties of the frontend filter.
%
%		frontendFilteringFlag - A boolean variable that determines if the frontend filter is to be applied or not.
%
%		frontendFilter - A struct that determines the nature of the applied filter.
%
%	The outputs of the function:
%
%		afterFrontendFilterData - A vector of data that is the filtered value of the rawData variable. If frontendFilteringFlag is true, then this is the data that is parsed through the filter. Otherwise, this is just the rawData input.
%
%		afterFrontendFilterTrigger - A vector of data that is the updated value of the triggerSignal variable. If the frontendFilteringFlag is true, then this has a set of zeros appended to the beginning of the vector. The number of zeros appended is specified by frontendFilter.groupDelay.
%
%%

function [afterFrontendFilterData,afterFrontendFilterTrigger] = applyFrontendFilter(rawData,triggerSignal,frontendFilteringFlag,frontendFilter)
 
	%Check if frontendFilteringFlag is true. If it is, then proceed with the filtering operation. Otherwise, pass the input rawData and triggerSignal to the output variables without applying any filter.
	if(frontendFilteringFlag)

		%filterState = zeros(max(length(frontendFilter.Num),length(frontendFilter.Den))-1,size(rawData,2));

		%Perform the filter on the raw data, using the Matlab filter function (http://www.mathworks.com/help/matlab/ref/filter.html). Uses the numerator coefficient specified by frontendFilter.Num and the denominator coefficient specified by frontendFilter.Den. Accept an initial condition of an empty vector. Operate across 1 dimension.
		afterFrontendFilterData = filter(frontendFilter.Num,frontendFilter.Den,rawData,[],1);

		%Append a set of zeros to the beginning of the afterFrontendFilterTrigger variable. The number of zeros appended is specified by frontendFilter.groupDelay.
		afterFrontendFilterTrigger = [zeros(frontendFilter.groupDelay,1);triggerSignal(1:end-frontendFilter.groupDelay)];

		%filteredData=filteredData(

	else

		%Set the output afterFrontendFilterData to the input rawData.
		afterFrontendFilterData = rawData;

		%Set the output afterFrontendFilterTrigger to the input triggerSignal.
		afterFrontendFilterTrigger = triggerSignal;

	end

end