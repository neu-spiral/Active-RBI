%% classdef processFlow < handle
% Used to store a list of processNode objects, which can then be made to learn and operate upon the specified data in batch processes.
%%

classdef processFlow < handle
    
    %% Properties
    %
    %   processList - Object, linked list of nodes to be processed.
    %
    %%
    
    properties
        
        processList
       
    end
    
    methods 
        
        %% function self = processFlow
        % Constructor.
        %%
        
        function self = processFlow
            
            self.processList = linkedList;
           
        end
        
        
        
        %% function add(self,thisProcessNode)
        % Appends the specified processNode object to the processList object.
        %
        %   The inputs of the function:
        %
        %       thisProcessNode - Object, processNode to be appended to the processList object.
        %
        %%
        
        function add(self,thisProcessNode)
            
            % Append thisProcessNode to processList.
            self.processList.insertEnd(listNode(thisProcessNode));
            
        end
        
        
        
        %% function output = learn(self,data,labels,trials)
        % Iterates through each of the nodes in the list and executes their learn function, using the specified input variables. Returns the value of the operate function of the second last node in the list.
        %
        %   The inputs of the function:
        %
        %       data - Cell array, contains the data being learnt and operated upon by the nodes.
        %
        %       labels - Array, contains the labels that nominatively represent the data.
        %
        %       trials - Array, used to determine the data and label elements that come from trials.
        %
        %   The outputs of the function:
        %
        %       output - Cell array, contains the data that has been operated upon by the nodes.
        %
        %%
        
        function output = learn(self,data,labels,trials)
            
            % Make currentNode a pointer to the head of the processList.
            currentNode = self.processList.Head;
            
            % Iterate over the number of elements specified by self.processList.elementCount.
            for elementIndex = 1:self.processList.elementCount
                
                % Check if this is the first element being iterated through and if the number of input variables specified is 4.
                if elementIndex == 1 && nargin == 4
                    
                    % Execute the learn function in the head node, using all 3 input variables.
                    currentNode.Data.learn(data,labels,trials);
                
                else
                    
                    % Execute the learn function in the head node, using only 2 input variables.
                    currentNode.Data.learn(data,labels);
                    
                end
                
                % Check if the next node in the list is empty.
                if(isempty(currentNode.Next))
                 % Check if the number of output variables is greater than 0.
                    if(nargout>0)
                         if(elementIndex==1 && nargin ==4)
                          output=currentNode.Data.operate(data,trials); 
                    else
                        
                        % Set the output to the value of the operate function as performed by the current node.
                        %....................................................................................................
                        output = currentNode.Data.operate(data);
                        
                    end
                                
                    end

                else
                    if(elementIndex==1 && nargin ==4)
                          data=currentNode.Data.operate(data,trials); 
                          labels=labels(trials);
                    else
                    
                    % Set the data to the value of the operate function as performed by the current node.
                    %....................................................................................................
                    data = currentNode.Data.operate(data);
                   
                    end
                end
                
                % Iterate to the next node in the list.
                currentNode = currentNode.Next;
                
            end
            
        end
        
        
        
        %% function output = operate(self,data,trials)
        % Iterates through each of the nodes in the list, making each operate upon the given data. Returns the data once it has been operated upon by all the nodes.
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
            
            % Make currentNode a pointer to the head of the processList.
            currentNode = self.processList.Head;
            
            % Iterate over all the elements specified by self.processList.elementCount.
            for elementIndex = 1:self.processList.elementCount
                
                % Check if the element index is 1 and if the number of input variables is 3.
                if elementIndex == 1 && nargin == 3
                    
                     % Set the data to the value of the operate function as performed by the current node, including trials as an input variable.
                    data = currentNode.Data.operate(data,trials);
                
                else
                    
                    % Set the data to the value of the operate function as performed by the current node.
                    data = currentNode.Data.operate(data);
                
                end
                
                % Iterate to the next node in the list.
                currentNode = currentNode.Next;
            
            end
            
            % Set the output to the processed data.
            output = data;
             
        end
        
    end
    
end