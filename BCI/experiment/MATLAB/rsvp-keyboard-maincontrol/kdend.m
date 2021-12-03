classdef kdend < handle
    %%  A kdend is an object that contains a data matrix that we want to calculate its kernel density distribution. When a
    %   kdend is constructed, kernel width will be calculated using the input data. The constructor returns a handle to this object.
    %
    %  kdend properties:
    %   kernelWidth         - sigma of normal distribution fitted on each data
    %                         point for kernel density estimation. If it is
    %                         multidimensional it contains the corresponding
    %                         bandwidth scale. For one dimensional case it is
    %                         estimated using Silverman's rule of thumb.
    %   data                - an (Nxd) matrix that we want to estimate the
    %                         kernel density function with. N is the number of
    %                         samples and d is the number of dimensions.
    %
    %  kdend methods:
    %   probs        - Estimates kernel density function of a given data
    
    
    properties
        kernelWidth
        data
    end
    %% Methods of the kdend class
    methods
        %% kdend(data)
        % Constructor for the kdend object. It initializes the empty
        % kdend object with data and the kernelWidth parameter
        function self=kdend(data,diagonalityFlag)
            if(size(data,2)==1)
                self.kernelWidth=1.06*min(std(data),iqr(data)/1.34)*length(data)^-0.2; %Silverman's rule of thumb
            else
                if(~exist('diagonalityFlag','var') || diagonalityFlag==0)
                    [N,d]=size(data);
                    anisotropic = 1;
                    bounds = [-5 5];
                    p_norm = 2;
                    weights = ones(1 , N) /N ;
                    gamma = Inf * ones(1 , N );
                    KernelType = 'Gaussian';
                    
                    cov_knn = Calculate_Covariance_Matrix (data' , anisotropic);
                    sigma_opt  = Optimal_Kernel_Width (data',bounds,cov_knn,KernelType,gamma,p_norm,weights);
                    self.kernelWidth=sigma_opt^2*reshape(cell2mat(cov_knn),[size(cov_knn{1}) length(cov_knn)]);
                    %self.kernelWidth = cellfun(@(x) sigma_opt^2*x, cov_knn,'UniformOutput',false);
                else
                    [N,d]=size(data);
                    temp=1/(d+4);
                    self.kernelWidth=((4/(d+2))^temp)*min(std(data,0,1),iqr(data,1)/1.34)*N^-temp;
                end
            end
            self.data=data;
            
        end
        %% probs(x)
        % probs(X)function estimates the kernel density function for given x using a Gaussian kernel.
        %   X is an N x d matrix where N is the number of samples and d is
        %   the number of dimensions.
        function p=probs(self,X)
            p=zeros(size(X,1),1);
            for(xi=1:size(X,1))
                if(size(self.kernelWidth,3)>1)
                    p(xi)=sum(mvnpdf(X(xi,:),self.data,self.kernelWidth));
                else
                pointpdf=ones(size(self.data,1),1);
                for(di=1:size(X,2))
                    pointpdf=pointpdf.*normpdf(X(xi,di),self.data(:,di),self.kernelWidth(di));
                end
                p(xi)=sum(pointpdf);
                end
            end
            p=p/size(self.data,1);
            
        end
        %% getSample(sampleCount)
        % getSample(sampleCount) gives back the number of random samples in sampleCount, from the distribution
        % x is (sampleCount x dim) a samples matrix
        function x=getSample(self,sampleCount)
            x=bsxfun(@times,randn(sampleCount,size(self.data,2)),self.kernelWidth)+self.data(randi(size(self.data,1),[sampleCount,1]),:);
        end
    end
    
    
    
end