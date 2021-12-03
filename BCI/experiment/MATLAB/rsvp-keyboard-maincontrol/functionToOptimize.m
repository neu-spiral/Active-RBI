function [ output,xString ] = functionToOptimize(SupervisedProcessesStruct,parameterValuesVector,crossValidationObject,trialData,trialTargetness)
%function2Optimize(SupervisedProcessesStruct,parameterValuesVector,crossValidationObject,trialData,trialTargetness)
% is a function which includes limits for constranits to be solvable with
% fminsearch Matlab function.
xString=[];
output=0;
parameterNumber=0;
if nargin > 2
    
    for j=1:length(SupervisedProcessesStruct.operationParameters)
        parameterNames=fieldnames(SupervisedProcessesStruct.operationParameters{j});
        for i=1:length(parameterNames)
            % Loading current paramter limits from the RSVPKeboard Parameter file.
            thisParameterLimits=eval(['SupervisedProcessesStruct.operationParameters{' num2str(j) '}.' parameterNames{i} ';']);
            % Cheking if this parameter should be optimized or it has a
            % pre-assigned value.
            if length(thisParameterLimits)>1
                % Cheking if the value for parameter is out side the limits if
                % will assign nan to output and breaks the for loop.
                parameterNumber=parameterNumber+1;
                if parameterValuesVector(parameterNumber)>=min(thisParameterLimits)&&  parameterValuesVector(parameterNumber)<=max(thisParameterLimits)
                    % If the value for the paprameter is inside the limits it
                    % will assign that value to the value in the structure.
                    eval(['SupervisedProcessesStruct.operationParameters{' num2str(j) '}.' parameterNames{i} '=' num2str(parameterValuesVector(parameterNumber)) ';']);
                else
                    % If the value is outside of the limits the loop is
                    % terminated.
                    output=nan;
                    break;
                end
            end
        end
        % If a parameter is outside of the limit the loop is terminated.
        if isnan(output);break;end
    end
    % if all parameters are in the range the supervised flow is formed and the
    % crossvalidation is evaluated.
    if ~isnan(output)
        SupervisedProcessFlow = formProcessFlow(SupervisedProcessesStruct);
        scores=crossValidationObject.apply(SupervisedProcessFlow,trialData,trialTargetness);
        [meanAuc,stdAuc]=calculateAuc(scores,trialTargetness,crossValidationObject.crossValidationPartitioning,crossValidationObject.K);
        output=-meanAuc;
    else
        % If values are outside of the loop the output is set as maximum value
        % possible.
        output=realmax;
    end
else
    % In this mode the function would only extract parameter values as the
    % initial point for optimization algorithm from the RSVPKeyboardParamters.
    %
    % Here the xString represents a string which will be used in the 
    % fminsearch function to show the number of parameters to be optimized. 
    if nargin==1
        
        parameterValuesVector=[];
        for j=1:length(SupervisedProcessesStruct.operationParameters)
            parameterNames=fieldnames(SupervisedProcessesStruct.operationParameters{j});
            for i=1:length(parameterNames)
                % Loading current paramter limits from the RSVPKeboard Parameter file.
                thisParameterLimits=eval(['SupervisedProcessesStruct.operationParameters{' num2str(j) '}.' parameterNames{i} ';'] );
                % Cheking if this parameter should be optimized or it has a
                % pre-assigned value.
                if length(thisParameterLimits)>1
                    % Cheking if the value for parameter is out side the limits if
                    % will assign nan to output and breaks the for loop.
                    parameterNumber=parameterNumber+1;
                    if parameterNumber==1
                        parameterValuesVector= thisParameterLimits(3);
                        xString='[x(1)';
                    else
                        parameterValuesVector=[parameterValuesVector thisParameterLimits(3)];
                        xString=[xString , ';x(' num2str(parameterNumber) ')'];
                    end
                    
                end
            end
        end
        xString=[xString , ']'];
        output=  parameterValuesVector;
    % In this mode the function is assign the user specified values from
    % the function input to the optimizable parameters and the parameters
    % with fixed values in RSVPKeyboardParamters would have their own
    % values.
    else if nargin==2
            
            for j=1:length(SupervisedProcessesStruct.operationParameters)
                parameterNames=fieldnames(SupervisedProcessesStruct.operationParameters{j});
                for i=1:length(parameterNames)
                    % Loading current paramter limits from the RSVPKeboard Parameter file.
                    thisParameterLimits=eval(['SupervisedProcessesStruct.operationParameters{' num2str(j) '}.' parameterNames{i} ';']);
                    % Cheking if this parameter should be optimized or it has a
                    % pre-assigned value.
                    if length(thisParameterLimits)>1
                        parameterNumber=parameterNumber+1;
                        eval(['SupervisedProcessesStruct.operationParameters{' num2str(j) '}.' parameterNames{i} '=' num2str(parameterValuesVector(parameterNumber)) ';']);
                        
                    end
                end
                
            end
            output=SupervisedProcessesStruct;
        end
        
    end
end
end