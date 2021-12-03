classdef screenNode < handle
    properties
        Children
        Parent
        windowHandle
        duration=0;        
        VBLTimeStamp
        StimulusOnsetTime
        FlipTimestamp
        Missed
        Beampos
        FlipTime=0;
        halfInterFlipInterval=0.0085; %1/60
        triggerValue=0;
    end
    methods
        function self=screenNode(windowHandle,interFlipInterval,duration)
            self.Children=linkedList;
            if(nargin>0)
            
            %self.backgroundGraphicElementList=linkedList;
            self.windowHandle=windowHandle;
            if(nargin>=2)
                self.halfInterFlipInterval=interFlipInterval/2;
            end
            if nargin>=3
                self.duration=duration;
            end
            end
        end
        
        function addGraphicElement(self,element)
            self.Children.insertEnd(listNode(element));
            element.Parent=self;
        end
        
        function Draw(self)
            currentNode=self.Children.Head;
            for(elementIndex=1:self.Children.elementCount)
                currentNode.Data.Draw;
                currentNode=currentNode.Next;
            end
        end
        
        function setFlipTime(self,nextNode)
            if(~isempty(nextNode))
            if(self.duration==0)
                nextNode.FlipTime=0;
            else
                nextNode.FlipTime=self.duration+self.VBLTimeStamp-self.halfInterFlipInterval;
            end
            end
        end
        
        function Flip(self)
            %imageArray=Screen('GetImage',self.windowHandle);
            %imwrite(imageArray,['../TestResults/Temp/' num2str(cputime) '.png'],'png');
            
            
            [self.VBLTimeStamp self.StimulusOnsetTime self.FlipTimestamp self.Missed self.Beampos]=Screen('Flip',self.windowHandle,self.FlipTime,0,0);
            
            
        end
        
        
        function setTriggerValue(self,triggerValue)
           self.triggerValue=triggerValue; 
        end
        
        function copyObject=copy(self)
            copyObject=screenNode;
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
        
    end
    

end