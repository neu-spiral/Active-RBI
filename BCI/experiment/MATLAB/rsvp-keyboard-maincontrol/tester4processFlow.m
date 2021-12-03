%% tester4ProcessFlow
% This script is for checking ProcessFlow and ProcessNode processes
%%
X0=randn(20,5,1000);
X1=randn(20,5,300)+0.1;
ss=length(size(X0));
L0=zeros(1,size(X0,ss));
L1=ones(1,size(X1,ss));
L=[L0 L1];
X=cat(ss,X0,X1);
p=randperm(length(L));
L=L(p);
evalString=['X=X(' repmat(':,',1,length(size(X))-1) 'p);'];
eval(evalString);

%%
pfobj=processFlow;
node1=processNode(@downsampleObject,2);
pfobj.add(node1);

pcaParameters.minimumRelativeEigenvalue=1e-5;
node2=processNode(@pca,2,pcaParameters);
pfobj.add(node2);

rdaParameters.lambda=0.9;
rdaParameters.gamma=0.1;
node3=processNode(@rda,0,rdaParameters);
pfobj.add(node3);


Y=pfobj.learn(X,L);


crossValidationParameters.K=10;
crossValidationParameters.partitioningType='Uniform';
cv=crossValidation(crossValidationParameters);

output=cv.apply(pfobj,X,L);

[meanAuc,stdAuc]=calculateAuc(output,L,cv.crossValidationPartitioning,cv.K);


%%
RSVPKeyboardParameters
pfobj=processFlow;
for(processNodeIndex=1:length(RSVPKeyboardParams.FeatureExtraction.operatorHandles))
    if(isempty(RSVPKeyboardParams.FeatureExtraction.operationParameters{processNodeIndex}))
        tempNode=processNode(RSVPKeyboardParams.FeatureExtraction.operatorHandles{processNodeIndex},RSVPKeyboardParams.FeatureExtraction.operationModes(processNodeIndex));
    else
        tempNode=processNode(RSVPKeyboardParams.FeatureExtraction.operatorHandles{processNodeIndex},RSVPKeyboardParams.FeatureExtraction.operationModes(processNodeIndex),RSVPKeyboardParams.FeatureExtraction.operationParameters{processNodeIndex});
    end
    pfobj.add(tempNode);
end

Y=pfobj.learn(X,L);


