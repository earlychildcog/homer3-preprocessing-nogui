function stim = getDefaultStim(folder)
arguments
    folder string {mustBeFolder}
end
% filename must be a .snirf

filenames = getSubfolderStructure(folder,"*.snirf");
filenames = cat(2,filenames{:})';
nFile = length(filenames);
dummyStim = '@';
stimArray = repmat(dummyStim,1,nFile);
parfor f = 1:nFile;
    thisFile = char(filenames(f));
    acquired = SnirfClass(thisFile);
    stimName = arrayfun(@(x)x.name,acquired.stim);
    stimArray(f) = stimName
end
stimArray(stimArray == dummyStim) = [];
stimArray = unique(stimArray);
stim = arrayfun(@(x)StimClass(x), stimArray);

