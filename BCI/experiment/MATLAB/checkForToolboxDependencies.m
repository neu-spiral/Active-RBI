function []=checkForToolboxDependencies(path)
if nargin<1
    path='.';
end
foldersTree=getSubfolderTree(path);
mFilesFullPath=[];
for i=1:length(foldersTree)
    mFilesInfo = dir(fullfile('.',[foldersTree{i},'/*.m']));
    mFilesNames={mFilesInfo.name};
    mFilesFullPath=[mFilesFullPath,strcat([foldersTree{i} '/'],mFilesNames)];
end
toolBoxesNames = dependencies.toolboxDependencyAnalysis(mFilesFullPath);
toolBoxesNames(ismember(toolBoxesNames,{'MATLAB'}))=[];
thisMatlabInfo=ver;
fullToolBoxFlag=true;
missingToolBoxes=[];
for i=1:length(toolBoxesNames)
    if any(strcmp(toolBoxesNames{i}, {thisMatlabInfo.Name}))
        fullToolBoxFlag=false;
        if isempty(missingToolBoxes)
            missingToolBoxes= toolBoxesNames(i);
        else
            missingToolBoxes= [missingToolBoxes,toolBoxesNames(i)];
        end
    end
end
disp('This matlab toolboxes status:')
disp('---------------------------------------------------------------------------------------------------------------')
disp(' ')
if ~fullToolBoxFlag
    disp('   All required toolboxes are available.');
else
    disp('   Following toolboxes are missing:');
    disp('   ................................');
    for i=1: length(missingToolBoxes)
        disp(['      ' missingToolBoxes{i}]);
        disp(' ');
    end
end
disp('---------------------------------------------------------------------------------------------------------------')
end