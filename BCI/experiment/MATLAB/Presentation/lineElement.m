classdef lineElement < handle
    properties
        lineColor
        width
        visible
        lineStartPoint=[0;0];
        lineEndPoint=[0;0];
        windowHandle
        Parent
        Children
    end
    methods
        function self = lineElement(presentationInfo)
            self.Children=linkedList;
            if(nargin>0)
            self.width=presentationInfo.typingFeedbackBar.BorderInfo.width;
            self.lineColor=presentationInfo.typingFeedbackBar.BorderInfo.color;
            self.visible=presentationInfo.typingFeedbackBar.BorderEnabled;
            self.lineStartPoint(1)=presentationInfo.windowRect(1);
            self.lineEndPoint(1)=presentationInfo.windowRect(3);
            self.windowHandle=presentationInfo.window;
            end
        end
        
            function addGraphicElement(self,element)
        self.Children.insertEnd(listNode(element));
        element.Parent=self;
    end
        
        function Draw(self)
            if(self.visible)
                if(~isempty(self.Parent))
            switch class(self.Parent)
                case 'textElement'
                self.lineStartPoint(2)=self.Parent.YCursor+self.Parent.textSize*self.Parent.vSpacing;
                self.lineEndPoint(2)=self.lineStartPoint(2);
                Screen('DrawLine', self.windowHandle,self.lineColor, self.lineStartPoint(1),self.lineStartPoint(2),self.lineEndPoint(1),self.lineEndPoint(2), self.width);
            end
                end
            end
            
            currentNode=self.Children.Head;
            for(elementIndex=1:self.Children.elementCount)
                currentNode.Data.Draw;
                currentNode=currentNode.Next;
            end
        end
        
         function copyObject=copy(self)
            copyObject=lineElement;
            S=properties(self);
            for(propertyIndex=1:length(S))
                copyObject.(S{propertyIndex})=self.(S{propertyIndex});
            end
            
            if(~isempty(self.Children))
                copyObject.Children=linkedList;
                currentNode=self.Children.Head;
                while(~isempty(currentNode))
                    copyObject.Children.insertEnd(listNode(copy(currentNode.Data)));
                    copyObject.Children.Tail.Data.Parent=copyObject;
                    currentNode=currentNode.Next;
                end
            end
        end
        
%         function copyObject=copy(self)
%             copyObject=lineElement;
%             S=properties(self);
%             for(propertyIndex=1:length(S))
%                 copyObject.(S{propertyIndex})=self.(S{propertyIndex});
%             end
%             if(~isempty(self.startingElement))
%                 copyObject.startingElement=copy(self.startingElement);
%             end
%         end
    end
    
end