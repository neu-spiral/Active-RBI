%% S=xls2Structs(xlsFilename)
% xls2Structs is a function that reads an excel file and outputs a vector
% of structs with column names as field names and each row as an element.
% The number of rows, except the first one containing the column names,
% correspond to the number of elements in the structure vector.
%
% Input:  
%       xlsFilename - name of the excel file to read from
%
% Output: 
%       S - vector of structs 
%              Column names of the excel file are the field names of the
%              structure vector.
%
%%
function S=xls2Structs(xlsFilename)

[~,~,raw]=xlsread(xlsFilename);

fields=strrep(raw(1,:),' ','');
S=cell2struct(raw(2:end,:),fields,2);