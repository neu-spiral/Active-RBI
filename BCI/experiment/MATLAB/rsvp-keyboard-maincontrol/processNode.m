%% classdef processNode < handle
% Encapsulates the learning and operation of a specific cluster of data.
%%

classdef processNode < handle
    
    %% Properties
    %
    %   operatorHandle - Handle, points to the operator function being used by the node.
    %
    %   operationMode - Double, used to determine the mode of operation of the node. Default value: 0.
    %
    %   operators - Object or array of objects, created by the operator handle function. The objects contains the learn and operate functions being used by the node.
    %
    %   operatorParameters - Array, contains the variables being used by the operator handle function.
    %
    %%
    
    properties
        
        operatorHandle
        operationMode = 0;
        operators
        operatorParameters
        
    end
    
    methods
        
        %% function self = processNode(operatorHandle,operationMode,operatorParameters)
        % Constructor.
        %
        %   The inputs of the function:
        %
        %       operatorHandle - Handle, points to the operator function being used by the node.
        %
        %       operationMode - Double, used to determine the mode of operation of the node. Default value: 0.
        %
        %       operatorParameters - Array, contains the variables being used by the operator handle function.
        %
        %%
        
        function self = processNode(operatorHandle,operationMode,operatorParameters)
            
            % Set the value of the operator handle.
            self.operatorHandle = operatorHandle;
            
            % Check if the number of input variables is greater than or equal to 2, and if the variable operationMode is not empty.
            if (nargin >= 2) && ~isempty(operationMode)
                
                % Set the value of the operation mode.
                self.operationMode = operationMode;
                
            end
            
            % Check if the number of input variables is greater than or equal to 3.
            if nargin >= 3
                
                % Set the value of the operation parameters.
                self.operatorParameters = operatorParameters;
                
            end
            
        end
        
        
        
        %% function learn(self,data,labels,trials)
        % Evaluates the conditions of the provided data, creates the operator objects by evaluating the operator handle and parameters, and then executes the learn function of the operators object.
        %
        %   The inputs of the function:
        %
        %       data - Cell array, contains the data being learnt and operated upon by the nodes.
        %
        %       labels - Array, contains the labels that nominatively represent the data.
        %
        %       trials - Array, used to determine the data and label elements that come from trials.
        %
        %%
        
        function learn(self,data,labels,trials)
            
            % Check if the operation mode of this object is 0.
            if self.operationMode == 0
                
                % Check if there are any operator parameters.
                if isempty(self.operatorParameters)
                    
                    % Set the operator of this object to the evaluated result of the operator handle.
                    self.operators = feval(self.operatorHandle);
                    
                else
                    
                    % Set the operator of this object to the evaluated result of the operator handle using the operator parameters.
                    self.operators = feval(self.operatorHandle,self.operatorParameters);
                    
                end
                
                % Check if the variable data is a cell array.
                if(iscell(data))
                    
                    % Create a buffer copy of the data cell array.
                    temp = cat(1,data{:});
                    
                    % Get the size of the data array.
                    tempSize = size(temp);
                    
                    % Reshape the buffer data array, converting it from an n-dimensional array into a 2-dimensional array.
                    temp = reshape(temp,prod(tempSize(1:end-1)),tempSize(end));
                    
                    % Check if the number of input variables is 4.
                    if nargin == 4
                        
                        % Makes the buffer data array only contain trial data.
                        temp = temp(:,trials);
                        
                        % Creates a buffer array of labels, containing only trial data labels.
                        tempLabels = labels(trials);
                        
                    else
                        
                        % Create a buffer copy of the label array.
                        tempLabels = labels;
                        
                    end
                    
                    % Execute the learn function in the operators object, using the buffer data array and the buffer label array as input variables.
                    self.operators.learn(temp,tempLabels);
                    
                else
                    
                    % Get the size of the data array.
                    tempSize = size(data);
                    
                    % Create a buffer copy of the data array and reshape it, converting it from an n-dimensional array into a 2-dimensional array.
                    temp = reshape(data,prod(tempSize(1:end-1)),tempSize(end));
                    
                    % Check if the number of input variables is 4.
                    if nargin == 4
                        
                        % Makes the buffer data array only contain trial data.
                        temp = temp(:,trials);
                        
                        % Creates a buffer array of labels, containing only trial data labels.
                        tempLabels = labels(trials);
                        
                    else
                        
                        % Create a buffer copy of the label array.
                        tempLabels = labels;
                        
                    end
                    
                    % Execute the learn function in the operators object, using the buffer data array and the buffer label array as input variables.
                    self.operators.learn(temp,tempLabels);
                    
                end
                
            % Otherwise, check if the operation mode of this object is greater than 0.
            elseif self.operationMode > 0
                
                % Check if the variable data is a cell array.
                if iscell(data)
                    
                    %self.operators=zeros(1,length(data));
                    
                    % Set the variable operatorCnt to the length of the data array.
                    operatorCnt = length(data);
                    
                    % Check if there are no operator parameters.
                    if isempty(self.operatorParameters)
                        
                        % Iterate backwards over the length of the data.
                        for cellIndex = operatorCnt:-1:1
                            
                            % Check if the current cell is last cell in the data.
                            if cellIndex == operatorCnt
                                
                                % Create a buffer operator object by evaluating the operator handle of this object, without any parameters.
                                tempOperator = feval(self.operatorHandle);
                                
                                % Sets the operators of this object to an array that contains multiple copies of the buffer operator object.
                                self.operators = repmat(tempOperator,1,operatorCnt);
                                
                            else
                                
                                % Set the current element of the operators variable from this object to the evaluation of the operator handle of this object, without any parameters.
                                self.operators(cellIndex) = feval(self.operatorHandle);
                                
                            end
                            
                            % Create a buffer variable that contains the current element of the data array.
                            temp = data{cellIndex};
                            
                            % Get the size of the current element of the data array.
                            tempSize = size(temp);
                            
                            % Check if the number of input variables is 4.
                            if nargin == 4
                                
                                %....................................................................................................
                                
                                % Create a string to be evaluated.
                                evalString = ['temp=temp(' repmat(':,',1,length(tempSize) - 1) 'trials);'];
                                
                                % Evaluate the string. This will set the buffer variable to an array that contains multiple copies of itself (?).
                                eval(evalString);
                                
                                % Creates a buffer array of labels, containing only trial data labels.
                                tempLabels = labels(trials);
                                
                            else
                                
                                % Create a buffer copy of the label array.
                                tempLabels = labels;
                                
                            end
                            
                            % Execute the learn function in the current element's operators object, using the buffer data array (minus any singleton dimensions) and the buffer label array as input variables.
                            self.operators(cellIndex).learn(squeeze(temp),tempLabels);
                            
                        end
                        
                    else
                        
                        % Iterate backwards over the length of the data.
                        for cellIndex = operatorCnt:-1:1
                            
                            % Check if the current cell is last cell in the data.
                            if cellIndex == operatorCnt
                                
                                % Create a buffer operator object by evaluating the operator handle of this object, without any parameters.
                                tempOperator = feval(self.operatorHandle);
                                
                                % Sets the operators of this object to an array that contains multiple copies of the buffer operator object.
                                self.operators = repmat(tempOperator,1,operatorCnt);
                                
                            else
                                
                                % Set the current element of the operators variable from this object to the evaluation of the operator handle of this object, without any parameters.
                                self.operators(cellIndex) = feval(self.operatorHandle);
                                
                            end
                            
                            % Create a buffer variable that contains the current element of the data array.
                            temp = data{cellIndex};
                            
                            % Get the size of the current element of the data array.
                            tempSize = size(temp);
                            
                            % Check if the number of input variables is 4.
                            if nargin == 4
                                
                                %....................................................................................................
                                
                                % Create a string to be evaluated.
                                evalString = ['temp=temp(' repmat(':,',1,length(tempSize)-1) 'trials);'];
                                
                                % Evaluate the string. This will set the buffer variable to an array that contains multiple copies of itself (?).
                                eval(evalString);
                                
                                % Creates a buffer array of labels, containing only trial data labels.
                                tempLabels = labels(trials);
                                
                            else
                                
                                % Create a buffer copy of the label array.
                                tempLabels = labels;
                                
                            end
                            
                            % Execute the learn function in the current element's operators object, using the buffer data array (minus any singleton dimensions) and the buffer label array as input variables.
                            self.operators(cellIndex).learn(squeeze(temp),tempLabels);
                            
                        end
                        
                    end
                    
                else
                    
                    % Get the size of the data.
                    dataSize = size(data);
                    
                    % Set the variable operatorCnt to the length of the data array.
                    operatorCnt = dataSize(self.operationMode);
                    
                    %self.operators=zeros(1,dataSize(self.operationMode));
                    
                    % Check if there are no operator parameters.
                    if isempty(self.operatorParameters)
                        
                        % Iterate backwards over the length of the data.
                        for cellIndex = operatorCnt:-1:1
                            
                            % Check if the current cell is last cell in the data.
                            if cellIndex == operatorCnt
                                
                                % Create a buffer operator object by evaluating the operator handle of this object, without any parameters.
                                tempOperator = feval(self.operatorHandle);
                                
                                % Sets the operators of this object to an array that contains multiple copies of the buffer operator object.
                                self.operators = repmat(tempOperator,1,operatorCnt);
                                
                            else
                                
                                % Set the current element of the operators variable from this object to the evaluation of the operator handle of this object, without any parameters.
                                self.operators(cellIndex) = feval(self.operatorHandle);
                                
                            end
                            
                            % Check if the number of input variables is 4.
                            if nargin == 4
                                
                                %....................................................................................................
                                
                                % Create a string to be evaluated.
                                evalString = ['temp=data(' repmat(':,',1,self.operationMode - 1) 'cellIndex,' repmat(':,',1,length(dataSize) - self.operationMode - 1) 'trials);'];
                                
                                % Creates a buffer array of labels, containing only trial data labels.
                                tempLabels = labels(trials);
                                
                            else
                                
                                %....................................................................................................
                                
                                % Create a string to be evaluated.
                                evalString = ['temp=data(' repmat(':,',1,self.operationMode - 1) 'cellIndex,' repmat(':,',1,length(dataSize) - self.operationMode - 1) ':);'];
                                
                                % Create a buffer copy of the label array.
                                tempLabels = labels;
                                
                            end
                            
                            % Evaluate the string. This will set the buffer variable to an array that contains multiple copies of itself (?).
                            eval(evalString);
                            
                            % Execute the learn function in the current element's operators object, using the buffer data array (minus any singleton dimensions) and the buffer label array as input variables.
                            self.operators(cellIndex).learn(squeeze(temp),tempLabels);
                            
                        end
                        
                    else
                        
                        % Iterate backwards over the length of the data.
                        for cellIndex = operatorCnt:-1:1
                            
                            % Check if the current cell is last cell in the data.
                            if cellIndex == operatorCnt
                                
                                % Create a buffer operator object by evaluating the operator handle of this object, without any parameters.
                                tempOperator = feval(self.operatorHandle,self.operatorParameters);
                                
                                % Sets the operators of this object to an array that contains multiple copies of the buffer operator object.
                                self.operators = repmat(tempOperator,1,operatorCnt);
                                
                            else
                                
                                % Set the current element of the operators variable from this object to the evaluation of the operator handle of this object.
                                self.operators(cellIndex) = feval(self.operatorHandle,self.operatorParameters);
                                
                            end
                            
                            % Check if the number of input variables is 4.
                            if nargin == 4
                                
                                %....................................................................................................
                                
                                % Create a string to be evaluated.
                                evalString = ['temp=data(' repmat(':,',1,self.operationMode-1) 'cellIndex,' repmat(':,',1,length(dataSize)-self.operationMode-1) 'trials);'];
                                
                                % Creates a buffer array of labels, containing only trial data labels.
                                tempLabels = labels(trials);
                                
                            else
                                
                                %....................................................................................................
                                
                                % Create a string to be evaluated.
                                evalString = ['temp=data(' repmat(':,',1,self.operationMode-1) 'cellIndex,' repmat(':,',1,length(dataSize)-self.operationMode-1) ':);'];
                                
                                % Create a buffer copy of the label array.
                                tempLabels = labels;
                                
                            end
                            
                            % Evaluate the string. This will set the buffer variable to an array that contains multiple copies of itself (?).
                            eval(evalString);
                            
                            % Execute the learn function in the current element's operators object, using the buffer data array (minus any singleton dimensions) and the buffer label array as input variables.
                            self.operators(cellIndex).learn(squeeze(temp),tempLabels);
                            
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
        
        
        %% function output = operate(self,data,trials)
        % Evaluates the conditions of the provided data, then executes the operate function of the operators object, and returns the data obtained from those executed functions.
        %
        %   The inputs of the function:
        %
        %       data - Cell array, contains the data to be operated upon by the nodes.
        %
        %       trials - Array, used to determine the data elements that come from trials.
        %
        %   The outputs of the function:
        %
        %       output - Cell array, contains the data that has been operated upon by the nodes.
        %
        %%
        
        function output = operate(self,data,trials)
            
            % Check if the operation mode of this object is 0.
            if self.operationMode == 0
                
                % Check if the data is a cell array.
                if iscell(data)
                    
                    % Create a buffer copy of the data array.
                    temp = cat(1,data{:});
                    
                    % Get the size of the data cell array.
                    tempSize = size(temp);
                    
                    % Reshape the buffer data array, converting it from an n-dimensional array into a 2-dimensional array.
                    
                          temp = reshape(temp,prod(tempSize(1:end-1)),tempSize(end));
                    
                    
                    % Check if the number of input variables is 3.
                    if nargin == 3
                        
                        % Makes the buffer data array only contain trial data.
                        temp = temp(:,trials);
                        
                    end
                    
                    % Set the output to the value of the operate function called from the operators object of this object, using the buffer data array as the input variable.
                    output = self.operators.operate(temp);
                    
                else
                    
                    % Get the size of the data cell array.
                    tempSize = size(data);
                    
                    % Create a buffer copy of the data array and reshape it, converting it from an n-dimensional array into a 2-dimensional array.
                    % checks for the case of a single trial
                    if length(tempSize)>2
                        temp = reshape(data,prod(tempSize(1:end-1)),tempSize(end));
                    else
                        temp=reshape(data,prod(tempSize(1:end)),1);
                    end
                    % Check if the number of input variables is 3.
                    if nargin == 3
                        
                        % Makes the buffer data array only contain trial data.
                        temp = temp(:,logical(trials));
                        
                    end
                    
                    % Set the output to the value of the operate function called from the operators object of this object, using the buffer data array as the input variable.
                    output = self.operators.operate(temp);
                    
                end
                
            % Otherwise, check if the operation mode of this object is greater than 0.
            elseif self.operationMode > 0
                
                % Set the output to a cell array that is the size of the operators array in this object.
                output = cell(size(self.operators));
                
                % Check if the data is a cell array.
                if iscell(data)
                    
                    % Iterate over the length of the operators array of this object.
                    for cellIndex = 1:length(self.operators)
                        
                        % Create a buffer variable that contains the current element of the data array.
                        temp = data{cellIndex};
                        
                        % Get the size of the current element of the data array.
                        tempSize = size(temp);
                        
                        % Check if the number of input variables is 3.
                        if nargin == 3
                            
                            %....................................................................................................
                                
                            % Create a string to be evaluated.
                            evalString = ['temp=temp(' repmat(':,',1,length(tempSize) - 1) 'trials);'];
                            
                            % Evaluate the string. This will set the buffer variable to an array that contains multiple copies of itself (?).
                            eval(evalString);
                            
                        end
                        
                        % Set the current element of the output to the value of the operate function called from the operators object of this object, using the buffer data array as the input variable (minus any singleton dimensions).
                        output{cellIndex} = self.operators(cellIndex).operate(squeeze(temp));
                        
                    end
                    
                else
                    
                    % Get the size of the data array.
                    dataSize = size(data);
                    
                    % Iterate over the length of the operators array of this object.
                    for cellIndex = 1:length(self.operators)
                        
                        % Check if the number of input variables is 3.
                        if nargin == 3
                            
                            %....................................................................................................
                            
                            % Create a string to be evaluated.
                            evalString = ['temp=data(' repmat(':,',1,self.operationMode-1) 'cellIndex,' repmat(':,',1,length(dataSize)-self.operationMode-1) 'trials);'];
                            
                        else
                            
                            %....................................................................................................
                            
                            % Create a string to be evaluated.
                            evalString = ['temp=data(' repmat(':,',1,self.operationMode-1) 'cellIndex,' repmat(':,',1,length(dataSize)-self.operationMode-1) ':);'];
                            
                        end
                        
                        % Evaluate the string. This will set the buffer variable to an array that contains multiple copies of itself (?).
                        eval(evalString);
                        
                        % Set the current element of the output to the value of the operate function called from the operators object of this object, using the buffer data array as the input variable (minus any singleton dimensions).
                        output{cellIndex} = self.operators(cellIndex).operate(squeeze(temp));
                        
                    end
                    
                end
                
                % Gets the numbers of elements in the each of the element arrays of the output array.
                outputNumels = cellfun(@numel,output);
                
                % Check if all the numbers of elements of each of the arrays in the output array are equal.
                if ~any(outputNumels ~= outputNumels(1))
                    
                    % Iterate over the length of the output array
                    for cellIndex = 1:length(output)
                        
                        % Get the size of the current element of the output array.
                        outputSize = size(output{cellIndex});
                        
                        % Reshape the curent element of the output array into an (n x 1 x m) array, where (n + m = self.operationMode).
                        output{cellIndex} = reshape(output{cellIndex},[outputSize(1:self.operationMode-1) 1 outputSize(self.operationMode:end)]);
                    
                    end
                    
                    % Append the operation mode to the beginning of the output array.
                    output = cat(self.operationMode,output{:});
                
                end
                
            end
            
        end
        
    end
    
end