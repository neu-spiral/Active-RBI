function [obj,success] = GetNodeHandle(processFlow,nodeClassName)
%GetNodeHandle searching through the processFlow retrives the handle to the
%nodeClassNam
%
%   Input(s):
%       - processFlow : a processFlow object
%       - nodeClassName : the class of the target node
%
%   Output(s):
%       - obj : contains the handle to the target object.
%       - success : A flag indicating sucessfull operation.
%

% $Author(s): Hooman Nezamfar $
% $Date: 2016/11/11 20:14:00 $
% Copyright: Cognitive Systems Laboratory, Northeastern University 2016

success = 0;
obj = [];
if isprop(processFlow,'processList')
    currentPFlow = processFlow.processList;
else
    currentPFlow = processFlow;
end

if isprop(currentPFlow,'Head')
    if isa(currentPFlow.Head.Data.operators,nodeClassName)
        obj = currentPFlow.Head.Data.operators;
        success = 1;
    else
        [obj,success] = GetNodeHandle(currentPFlow.Head.Next,nodeClassName);
    end
else
    if isprop(currentPFlow,'Data')
        if isa(currentPFlow.Data.operators,nodeClassName)
            obj = currentPFlow.Data.operators;
            success = 1;
        else
            [obj,success] = GetNodeHandle(currentPFlow.Next,nodeClassName);
        end            
    end    
end

end