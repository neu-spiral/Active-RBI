classdef listGraphicElement < handle
    
    properties
        
        Children
        Parent
        data
        numRows
        colorData
        x_pos
        y_pos
        textSize
        rowHeight
        windowHandle
        windowDimensions
        
    end
    
    methods
        
        function self = listGraphicElement(list,colorMatrix,x,y,fontSize,presentationInfo)
            
            self.Children = linkedList;
            
            if ~iscell(list)
                
                error('listGraphicElement given invalid table - list is not a cell array.');
                
            end
            
            sizeMatrix = size(list);
            if (length(sizeMatrix) ~= 2) || (sizeMatrix(2) ~= 1)
                
                error('listGraphicElement given invalid data - list is not a column array.');
                
            end
            
            self.data = list;
            
            self.numRows = sizeMatrix(1);
            
            sizeMatrix = size(colorMatrix);
            if sizeMatrix(1) ~= self.numRows
                
                error(['listGraphicElement given invalid data - colorMatrix has ',num2str(sizeMatrix(1)),' rows when it should have ',num2str(self.numRows),' rows.']);
                
            end
            
            if sizeMatrix(2) ~= 3
                
                error(['listGraphicElement given invalid data - colorMatrix has ',num2str(sizeMatrix(2)),' columns when it should have 3 columns.']);
                
            end
            
            self.colorData = colorMatrix;
            
            if ~isnumeric(x)
                
                error('listGraphicElement given invalid data - x is not numeric.');
                
            end
            
            self.x_pos = x;
            
            if ~isnumeric(y)
                
                error('listGraphicElement given invalid data - y is not numeric.');
                
            end
            
            
            self.y_pos = y;
            
            if ~isnumeric(fontSize)
                
                error('listGraphicElement given invalid data - fontSize is not numeric.');
                
            end
            
            if fontSize <= 0
                
                error('listGraphicElement given invalid data - fontSize is less than or equal to 0.');
                
            end
            
            self.textSize = fontSize;
            self.rowHeight = fontSize * 1.25;
            
            self.windowHandle = presentationInfo.window;
            
            self.windowDimensions = presentationInfo.windowRect;
            
        end
        
        function addGraphicElement(self,element)
            
            self.Children.insertEnd(listNode(element));
            element.Parent = self;
            
        end
        
        function Draw(self)
            
            % Draw strings
            oldTextSize = Screen(self.windowHandle,'TextSize',self.textSize);
            for i = 1:self.numRows
                
                Screen(self.windowHandle,'DrawText',self.data{i},self.windowDimensions(1) + self.x_pos,self.windowDimensions(2) + self.y_pos + ((i - 1) * self.rowHeight),self.colorData(i,:));
                
            end
            Screen(self.windowHandle,'TextSize',oldTextSize);
            
            % Draw children.
            currentNode = self.Children.Head;
            for elementIndex = 1:self.Children.elementCount
                
                currentNode.Data.Draw;
                currentNode = currentNode.Next;
                
            end
            
        end
        
        function copyObject = copy(self)
            
            copyObject = listGraphicElement;
            S = properties(self);
            
            for propertyIndex = 1:length(S)
                
                copyObject.(S{propertyIndex}) = self.(S{propertyIndex});
                
            end
            
            if ~isempty(self.Children)
                
                copyObject.Children = linkedList;
                currentNode = self.Children.Head;
                
                while ~isempty(currentNode)
                    
                    copyObject.Children.insertEnd(listNode(copy(currentNode.Data)));
                    copyObject.Children.Tail.Data.Parent = copyObject;
                    currentNode = currentNode.Next;
                    
                end
                
            end
            
        end
        
    end
    
end

