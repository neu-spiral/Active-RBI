%% HANDLEVARIABLE    Handle variable class.
% A handlevariable is an object that allows the usage of pass by reference.
% It can contain any type of data to be contained. This allows a function to
% be able to modify a variable.
%
% handleVariable properties:
%   data    - Data of the handle variable. Can be anything.
%

%%
classdef handleVariable < handle
    properties
        data=[]
    end
    methods
        function self=handleVariable(data)
            if(nargin>0)
                self.data=data;
            end
        end
        
    end
    
end