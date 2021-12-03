function [ resultProcessFlow ] = formProcessFlow( processStruct2Add,currentProcessFlow )
%formProcessFlow( processStruct2Add,currentProcessFlow ) is a function to
% create a process flow using a process structure. Besides this function can
% be used to append a new process flow to an existing one.

% If there is no currentProcessFlow this function will create a new flow
% out of processStruct2Add structure. 
if nargin>1
    resultProcessFlow=currentProcessFlow;
else
    resultProcessFlow=processFlow;
end
for processNodeIndex = 1:length(processStruct2Add.operatorHandles)
    
    % Check if the processStruct2Add.operationParameters{processNodeIndex} variable is empty.
    if isempty(processStruct2Add.operationParameters{processNodeIndex})
        
        % Set the value of the tempNode variable to a new processNode object.
        tempNode = processNode(processStruct2Add.operatorHandles{processNodeIndex},processStruct2Add.operationModes(processNodeIndex));
        
    else
        
        % Set the value of the tempNode variable to a new processNode object.
        tempNode = processNode(processStruct2Add.operatorHandles{processNodeIndex},processStruct2Add.operationModes(processNodeIndex),processStruct2Add.operationParameters{processNodeIndex});
        
    end
    
    % Append the tempNode variable to the resultProcessFlow object.
    resultProcessFlow.add(tempNode);
    
end

end

