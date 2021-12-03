function permutationArray = permuteVectors(vectorsToPermute)
% combineVectors generates an array with all possible permutations of
% elements of the vectors in the input cell
% Inputs:
%       vectorsToPermute        1-D cell with N vectors each one of size
%                               N_i with i=1...N . the vectors are 1 by N_i
%                               vectors (row vectors)
%                   
% Outputs:
%       permutationArray        2-D array of size N_1*...*N_N by N
%                               with the combination of the vector elements
%                               in the input cell
%
% Here is how permutationArray looks 
%
% vectorsToPermute{1}(1)   vectorsToPermute{2}(1)     ...     vectorsToPermute{N}(1) 
% vectorsToPermute{1}(2)   vectorsToPermute{2}(1)     ...     vectorsToPermute{N}(1) 
%   .
%   .
% vectorsToPermute{1}(N_1) vectorsToPermute{2}(2)     ...     vectorsToPermute{N}(1) 
% vectorsToPermute{1}(1)   vectorsToPermute{2}(2)     ...     vectorsToPermute{N}(1)
% vectorsToPermute{1}(2)   vectorsToPermute{2}(2)     ...     vectorsToPermute{N}(1)
%   .
%   .
%   .
% vectorsToPermute{1}(N_1) vectorsToPermute{2}(N_2)   ...     vectorsToPermute{N}(N_N) 
%
% The fastest varying element is the first cell vector
% Author: Fernando Quivira
% Date: 9/23/2013
% Version 1.0

% Get dimensions of input vectors
nVectorElements = cellfun(@numel, vectorsToPermute);

% Get total number of permutations
nPermutations = prod(nVectorElements);
nVectors = length(nVectorElements);

% Pre-allocation
permutationArray = zeros(nPermutations, nVectors);

for idxVector = 1:nVectors
    % This is how body of loop works
    % First vector gets repeated since its the fastest varying one
    % Second vector needs to have each element repeated N_1 times to form a
    % N_1*N_2 vector and then this output will be repeated to fill the
    % combination array
    % So on an so forth
    
    repetitionVector = repmat( vectorsToPermute{idxVector} , nPermutations/prod(nVectorElements(idxVector:end)), 1);
    repetitionVector = reshape(repetitionVector, [], 1);
    permutationArray(:,idxVector) = repmat(repetitionVector, nPermutations/prod(nVectorElements(1:idxVector)), 1);
end

end