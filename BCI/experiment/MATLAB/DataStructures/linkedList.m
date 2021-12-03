classdef linkedList < handle
    % LINKEDLIST  A class to represent a doubly-linked list node.
    % Multiple dlnode objects may be linked together to create linked lists.
    % Each node contains a piece of data and provides access to the next
    % and previous nodes.
    properties
        Head
        Tail
        elementCount=0;
    end
    methods
        function insertBeginning(self,node)
            if(~isa(node,'listNode'))
               node=listNode(node); 
            end
            if(isempty(self.Head))
                self.Head=node;
                self.Tail=node;
            else
            node.Next=self.Head;
            node.Prev=[];
            self.Head.Prev=node;
            self.Head=node;
            end
            self.elementCount=self.elementCount+1;
        end
        function insertEnd(self,node)
            if(~isa(node,'listNode'))
               node=listNode(node); 
            end
            
            if(isempty(self.Tail))
                self.Head=node;
                self.Tail=node;
            else
            node.Prev=self.Tail;
            node.Next=[];
            self.Tail.Next=node;
            self.Tail=node;
            end
            self.elementCount=self.elementCount+1;
        end
        function insertAfter(self,node,newNode)
            if(~isa(newNode,'listNode'))
               newNode=listNode(newNode); 
            end
            if(isempty(node.Next))
                self.insertEnd(newNode);
            else
                newNode.Next=node.Next;
                newNode.Prev=node;
                node.Next.Prev=newNode;
                node.Next=newNode;
            end
            self.elementCount=self.elementCount+1;
        end
        
        function insertBefore(self,node,newNode)
            if(~isa(newNode,'listNode'))
               newNode=listNode(newNode); 
            end
            if(isempty(node.Prev))
                self.insertBeginning(newNode);
            else
                newNode.Prev=node.Prev;
                newNode.Next=node;
                node.Prev.Next=newNode;
                node.Prev=newNode;
            end
            self.elementCount=self.elementCount+1;
        end
        
        function remove(self,node)
            if(~isempty(node.Prev))
                node.Prev.Next=node.Next;
            else
                self.Head=node.Next;
            end
            if(~isempty(node.Next))
                node.Next.Prev=node.Prev;
            else
                self.Tail=node.Prev;
            end
            
            node.Next=[];
            node.Prev=[];
            self.elementCount=self.elementCount-1;
        end
        
        function removeBefore(self,node)
            if(~isempty(node))
           numberofElements2delete=0;
           tempNode=node.Prev;
           while(~isempty(tempNode))
              numberofElements2delete=numberofElements2delete+1;
              tempNode=tempNode.Prev; 
           end
           node.Prev=[];
           self.Head=node;
           self.elementCount=self.elementCount-numberofElements2delete;
            end
        end
        
        function deleteNode(self,node)
            self.remove(node);
            delete(node);
        end
        
        function listCell=toCell(self)
            currentNode=self.Head;
            listCell=cell(1,self.elementCount);
            for(elementIndex=1:self.elementCount)
                listCell{elementIndex}=currentNode.Data;
                currentNode=currentNode.Next;
            end
           
        end
        
        function empty(self)
           self.Head=[]; 
           self.Tail=[];
           self.elementCount=0;
        end
        
        
    end % methods
end % classdef
