function status = exportToExcel(fileName, parameterNames, parameterValues, functionData)
% exportToExcel function exports parameters and data to an Excel
% spreadsheet. The function supports to modes of operation that are
% automatically detected depending on data
% Inputs:
%       fileName                File name of xls file
%       parameterNames          1-D cell (N elements) containing the name
%                               of the parameters that were used to generate 
%                               the data. These names will be put on top of
%                               the columns
%       parameterValues         1-D cell (N elements) of vectors containing
%                               the parameter values. The size of each
%                               vector can vary depending on mode of
%                               operation
%       functionData              Struct with M fields, where each field
%                               contains the  that is a function of the  
%                               input parameters. Each field will be put
%                               in a separate sheet. If the field name is
%                               longer than 31 characters, the last 31
%                               characters will be used for sheet name
%                   
% Outputs:
%       status                  1 if .xls file is generated, 0 otherwise.
%
% 
% Depending on the input, this function follows 2 modes of operation:
%
% Mode 0: the vectors in parameterValues are of different sizes
% If so, this function assumes that size of the fields in functionData is
% equal to the product of the dimensions of the parameter vectors and that
% the relation occurs in the following way:
%
% parameterValues{1}(1) parameterValues{2}(1) ... parameterValues{N}(1) -> functionData.field(1)
% parameterValues{1}(2) parameterValues{2}(1) ... parameterValues{N}(1) -> functionData.field(2)
%   .
%   .
%   . 
% parameterValues{1}(1) parameterValues{2}(2) ... parameterValues{N}(1) -> functionData.field(N_1+1)
% parameterValues{1}(2) parameterValues{2}(2) ... parameterValues{N}(1) -> functionData.field(N_1+2)
%   .
%   .
%   .
% parameterValues{1}(N_1) parameterValues{2}(N_2) ... parameterValues{N}(N_N) -> functionData.field(N_1*...*N_N)
%
% In essence, the excel spreadsheet will contain all possible combinations
% of the paramaters with the fastes varying one being the first in the cell
%
% Mode 1:
% There is a one to one correspondence between each parameter value and
% data element. Therefore, all must be of same size
%
% parameterValues{1}(i) parameterValues{2}(i) ... parameterValues{N}(i) -> functionData.field(i)
%
% Limitations: function only supports columns from A-Z i.e 25 parameter vectors
%
% Author: Fernando Quivira
% Date: 9/23/2013
% Version 1.0

if nargin < 4
    error('Not enough arguments')
end

if nargin > 4
    error('Too many arguments')
end

% Eliminate warning when writing excel sheets
warning('off','MATLAB:xlswrite:AddSheet');

% Check if all fields in functionData are of same size
nData = structfun(@numel, functionData);
if ~all(nData == nData(1))
    error('Each field in the functionData must have the same numberof elements')
end
nData = nData(1);

% Compute number of dimension of each parameter vector
nParam = cellfun(@numel, parameterValues);

% Find mode of operation: 
% mode 0 -> number of data poitns equal to product of diemnsions of each
% parameter vector
% mode 1 -> param vectors same size as data
if nData == prod(nParam)
    modeFlag = 0;
elseif all(nParam == nParam(1)) && (nData == nParam(1))
    modeFlag = 1;
else
    error('Check that data and parameters are of correct size for mode 0 or mode 1')
end

% Support columns from A->Z
columnLetters = char(65:90);
sheetNames = fieldnames(functionData);

% The column of data is at N+1
dataColumnLetter = columnLetters(numel(parameterValues) + 1);

% Get number of sheets
nSheets = numel(sheetNames);

% Write depending on mode
switch modeFlag
    case 0
        
        % Create combination of parameter vectors
        parameterValueGrid = permuteVectors(parameterValues);
        
        % for all sheets
        for idxSheet = 1:nSheets
            fieldData = functionData.(sheetNames{idxSheet});            
            
            % Get sheet name limited to last 31 characters
            sheetName = sheetNames{idxSheet}( max(end-30,1) : end );
            
            % Write parameter names on top of each column
            xlswrite(fileName, parameterNames, sheetName, 'A1');
            % Write parameter values right after
            xlswrite(fileName, parameterValueGrid, sheetName, 'A2');
            
            % Write field name and data 
            xlswrite(fileName, sheetNames(idxSheet), sheetName, [dataColumnLetter '1']);
            xlswrite(fileName, fieldData(:), sheetName, [dataColumnLetter '2']);
        end
        
    case 1
        
        parameterValueGrid = reshape(cell2mat(parameterValues), nData, []);
        
        % for all sheets
        for idxSheet = 1:nSheets
            fieldData = functionData.(sheetNames{idxSheet});            
            
            % Get sheet name limited to last 31 characters
            sheetName = sheetNames{idxSheet}( max(end-30,1) : end );
            
            % Write parameter names on top of each column
            xlswrite(fileName, parameterNames, sheetName, 'A1');
            % Write parameter values right after
            xlswrite(fileName, parameterValueGrid, sheetName, 'A2');
            
            % Write field name and data 
            xlswrite(fileName, sheetNames(idxSheet), sheetName, [dataColumnLetter '1']);
            xlswrite(fileName, fieldData(:), sheetName, [dataColumnLetter '2']);
        end
        
end

status = exist(fileName, 'file')>0;

end