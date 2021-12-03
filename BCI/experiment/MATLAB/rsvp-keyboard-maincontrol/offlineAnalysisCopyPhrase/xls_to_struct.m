
% Function used for converting the excel file into the Matlab struct
function S=xls_to_struct(xlsFilename)

[~,~,raw]=xlsread(xlsFilename);

fields=strrep(raw(1,:),' ','');
S=cell2struct(raw(2:end,:),fields,2);
end