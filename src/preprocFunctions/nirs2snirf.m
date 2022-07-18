function nirs2snirf(nirsFolder, dataFolder)


filenames = arrayfun(@(x)x.name, dir(strcat(nirsFolder,'*.nirs')), 'UniformOutput',false);
fileN = length(filenames);

parfor f = 1:fileN
    thisFile = filenames{f};
    inFile = [nirsFolder thisFile];
    if contains(thisFile, 'block1')
        block = 1;
    elseif contains(thisFile, 'block2')
        block = 2;
    else
        error("no block?");
    end
    subj = extractBefore(thisFile,' ');
    warning off
    mkdir([dataFolder subj])
    warning on
    newFilename = sprintf('%s_%d.snirf', subj, block);
    outFile = [dataFolder subj '/' newFilename];
    nirs = load(inFile, '-mat');

    snirf = SnirfClass(nirs);
    snirf.Save(outFile);
    fprintf("saved %s\n", outFile)
end



