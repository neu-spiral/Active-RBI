function [ optimizedParameterValues,meanAUC ] = gridSearch(SupervisedProcessesStruct,crossValidationObject,tempTrialData,trialTargetness)
%gridSearch(SupervisedProcessesStruct,crossValidationObject,tempTrialData,trialTargetness)
%   This function is doing a grid search to find the optimum value for
%   optimizable parameters.

parameterValueLimits=[];
parameterResolution=[];
parameterNumber=0;
for j=1:length(SupervisedProcessesStruct.operationParameters)
    allParameterNames=fieldnames(SupervisedProcessesStruct.operationParameters{j});
    for i=1:length(allParameterNames)
        % Loading current paramter limits from the RSVPKeboard Parameter file.
        thisParameterLimits=eval(['SupervisedProcessesStruct.operationParameters{' num2str(j) '}.' allParameterNames{i} ';'] );
        % Cheking if this parameter should be optimized or it has a
        % pre-assigned value.
        if length(thisParameterLimits)>1
            parameterNumber=parameterNumber+1;
            
            if parameterNumber==1
                parameterValueLimits= [min(thisParameterLimits),max(thisParameterLimits)];
                parameterResolution= eval(['SupervisedProcessesStruct.operationParameters{' num2str(j) '}.gridResolution.' allParameterNames{i} ';'] );
                defaultVal=thisParameterLimits(3);
            else
                parameterValueLimits=[parameterValueLimits ;min(thisParameterLimits),max(thisParameterLimits)];
                parameterResolution= [parameterResolution eval(['SupervisedProcessesStruct.operationParameters{' num2str(j) '}.gridResolution.' allParameterNames{i} ';'] )];
                defaultVal=[defaultVal,thisParameterLimits(3)];
            end
            
        end
    end
end
%%
% Grid search
if prod(parameterResolution)~=0
    minValueToCheck=realmax;
    x=parameterValueLimits(:,1);
    optimizedParameterValues=x;
    x(end)=x(end)-parameterResolution(end);
    while x(1)<=parameterValueLimits(1,2)
        x(end)=x(end)+parameterResolution(end);
        for i=length(x):-1:2
            if x(i)>parameterValueLimits(i,2)
                x(i-1)=x(i-1)+parameterResolution(i-1,2);
                x(i)=parameterValueLimits(i,1);
            end
        end
        if  x(1)<=parameterValueLimits(1,2)
            meanAUC=functionToOptimize(SupervisedProcessesStruct,x,crossValidationObject,tempTrialData,trialTargetness);
            if meanAUC<minValueToCheck
                optimizedParameterValues=x;
                minValueToCheck=meanAUC;
            end
        end
    end
else
    disp('Please check the gridResolution for all parameters!')
    disp('Parameters set to default values.')
    optimizedParameterValues=defaultVal;
    meanAUC=functionToOptimize(SupervisedProcessesStruct,defaultVal,crossValidationObject,tempTrialData,trialTargetness);
end
end

