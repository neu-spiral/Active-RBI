function [sequenceSet]=matrixSequenceGenerator(trials,presentationParadigm,matrixSize,imageStructs)

%imageStructs=xls2Structs('imageList.xls');
fullMatrixSet=cell2mat({imageStructs(find(cell2mat({imageStructs.showInMatrix}))).ID});

if isempty(matrixSize) || ischar(matrixSize) || length(fullMatrixSet)>prod(matrixSize)
    
    numOfRows=floor(sqrt(length(fullMatrixSet)));
    numOfColumns=floor(length(fullMatrixSet)/numOfRows)+(rem(length(fullMatrixSet),numOfRows)>0);
else
    numOfRows=matrixSize(1); numOfColumns=matrixSize(2);
end
presentationMatrix=nan(numOfRows,numOfColumns);
for i2=1:numOfRows
    for i1=1:numOfColumns
        if (i2-1)*numOfColumns+i1<=length(fullMatrixSet)
            presentationMatrix(i2,i1)=fullMatrixSet((i2-1)*numOfColumns+i1);
        end
    end
end
switch presentationParadigm
    case{'RC'}
        
        nextTrial=zeros(1,length(fullMatrixSet));
        
%         rows2Show=[];
%         columns2Show=[];
%         for i=1:length(trials)
%             [r,c]=find(presentationMatrix==trials(i));
%             rows2Show=[rows2Show,r];columns2Show=[columns2Show,c];
%         end
        [r,c]=size(presentationMatrix);
        rows2Show=1:r;
        columns2Show=1:c;
        
        rows2Show=unique(rows2Show);
        columns2Show=unique(columns2Show);
       
        for i=1:length(rows2Show)
            tmpTrialset=nextTrial;
            tmpIndicies=presentationMatrix(rows2Show(i),:);
            tmpIndicies(isnan(tmpIndicies))=[];
            tmpTrialset(tmpIndicies)=1;
            if exist('sequenceSet','var') && length(sequenceSet)>=1
                tmpTrialset=mat2str(tmpTrialset);
                tmpTrialset(findstr(tmpTrialset,' '))=[];
                sequenceSet=[sequenceSet,tmpTrialset(2:end-1)];
            else
                tmpTrialset=mat2str(tmpTrialset);
                tmpTrialset(findstr(tmpTrialset,' '))=[];
                sequenceSet={tmpTrialset(2:end-1)};
            end
            
        end
        
        for i=1:length(columns2Show)
            tmpTrialset=nextTrial;
            tmpIndicies=presentationMatrix(:,columns2Show(i))';
            tmpIndicies(isnan(tmpIndicies))=[];
            tmpTrialset(tmpIndicies)=1;
            if exist('sequenceSet','var') && length(sequenceSet)>=1
                tmpTrialset=mat2str(tmpTrialset);
                tmpTrialset(findstr(tmpTrialset,' '))=[];
                sequenceSet=[sequenceSet,tmpTrialset(2:end-1)];
            else
                tmpTrialset=mat2str(tmpTrialset);
                tmpTrialset(findstr(tmpTrialset,' '))=[];
                sequenceSet={tmpTrialset(2:end-1)};
            end
            
        end
        sequenceSet=sequenceSet(randperm(length(sequenceSet)));
    case{'Single'}
        for i=1:length(trials)
            nextTrial=zeros(1,length(fullMatrixSet));
            nextTrial(trials(i))=1;
            nextTrial=mat2str(nextTrial);
            nextTrial(findstr(nextTrial,' '))=[];
            if exist('sequenceSet','var') && length(sequenceSet)>=1
                
                sequenceSet=[sequenceSet,nextTrial(2:end-1)];
            else
                sequenceSet={nextTrial(2:end-1)};
            end
            
        end
        
        
end



end