%% CROSSVALIDATION class
% crossValidation is an object that contains the below mentioned properties and methods. The constructor returns a handle to this object. When a
%   handle to a dataBuffer object is copied, for example during assignment or when passed
%   to a MATLAB function, the handle is copied but not the underlying
%   object property values.
%
%  crossValidation properties:
%   crossValidationPartitioning   - row vector with the size of Labels that
%   has a number 1:k for each index in random or uniform order according to
%   partitioning type(uniform/random)(dimension: 1 x L)
%
%  crossValidation methods:
%   crossValidation      - constructor
%   apply                - applies cross validation
%
%    *(Access=private):
%   partition            - fills crossValidationPartitioning propertis of
%   the crossValidation object with a partition vector in random or uniform
%   order
%
%    *(Static):
%   pPartition           - partitions data to k fold uniformly
%
%   see also learn.
%%

classdef crossValidation < handle
    
    properties
        crossValidationPartitioning
        
        %         performanceEstimationType = 'Aggregate';
        K = 10;
        partitioningType = 'Uniform';
        
    end
    %%  Methods of the crossValidation class
    methods
        %% crossValidation(parameters)
        % Constructor for the crossValidation object. It initializes the
        % empty crossValidation object with the parameters K(number of folds for crossValidation), partitioningType(uniform/random)numberOfChannels
        % that are components of the input structure
        function self=crossValidation(parameters)
            if(nargin > 0)
                %         if(isfield(parammeters,'performanceEstimationType'))
                %             self.performanceEstimationType=parameters.performanceEstimationType;
                %         end
                if(isfield(parameters,'K'))
                    self.K=parameters.K;
                end
                if(isfield(parameters,'partitioningType'))
                    self.partitioningType=parameters.partitioningType;
                end
                
            end
        end
        
        
        function output=apply(self,flowHandle,data,labels,updateNode,nodeName)
            %    apply(self,flowHandle,data,labels) applies cross validation on data for given classification process. It
            %    partitions data and calculate scores for each fold of cross-validation fold
            %   The inputs of the function
            %      flowHandle - processFlow containing classification steps
            %      data       - data to apply cross validation on, might be multidimensional but the
            %      last dimension should correspond to trials.
            %      labels     - contains a vector of labels corresponding to all labels.
            %
            %   The outputs of the function
            %      output - scores
            
            % performanceEstimationType='Uniform'
            self.partition(length(labels));
            
            %valSets=unique(crossValidationPartitioning);
            output=zeros(1,length(labels));
            
            for k=1:self.K
                trials=self.crossValidationPartitioning==k;
                flowHandle.learn(data,labels,~trials);                 
                if exist('updateNode','var') && ~isempty(updateNode)
                    % flowHandle.learn creats buffer objects that
                    % disconnect the connection with the previousely found
                    % handle. Hence it is required to get the new handle
                    % after each call to learn method.
                    [updateNode, ~] = GetNodeHandle(flowHandle,nodeName);
                    flowHandle.operate(data,~trials);
                    updateNode.update([],labels(~trials));
                end
                output(trials)=flowHandle.operate(data,trials);
            end
            %output=self.crossValidationPartitioning;
        end
        
        
    end
    
    methods (Access=private)
        function partition(self,L)
            %  partition(self,L) uses pPartition to generate a partition vector
            %  explained in pPartition function(read pPartition) and check to see if
            %  partitioning type is random or not. If so, make the partition vector in
            %  random order. And fill crossValidationPartitioning with this vector.
            
            switch self.partitioningType
                case 'Uniform'
                    self.crossValidationPartitioning=crossValidation.pPartition(L,self.K);
                case 'Random'
                    temp=crossValidation.pPartition(length(labels),self.K);
                    self.crossValidationPartitioning=temp(randperm(L));
            end
        end
        
    end
    
    methods (Static)
        function partitionOutput=pPartition(L,K)
            % %  pPartition(L,K) gets L(number of features or labels) and K(number of folds for crossValidation)
            %    and assign a partion number(1:K) for each index of Labels(or feature
            %    vectores). Since K is not allways dividable to K, number of labels in
            %    each partion may vary from one from partion to partition.
            %    The inputs of the function
            %      K - number of partitions(for K-fold cross-validation).
            %      L - number of Labels
            %
            %   The output of the function
            %      partitionOutput - row vector with the size of Labels that has a number 1:k for each index (dimension: 1 x L).
            
            baseValSize=floor(L/K);
            extraValSampleCount=mod(L,K);
            
            temp1=repmat(1:extraValSampleCount,baseValSize+1,1);
            temp2=repmat(extraValSampleCount+1:K,baseValSize,1);
            partitionOutput=[reshape(temp1,1,numel(temp1)), reshape(temp2,1,numel(temp2))];
            
        end
    end
    % end
end