function fnirsPreproc(settings)

%% pipeline file
%filePath = fileparts(matlab.desktop.editor.getActiveFilename);


%% settings
folderSnirf = settings.folderSnirf;
saveData = settings.saveData;
doGroupResultFile = settings.doGroup;
outFolder = settings.outFolder;


groupName = regexp(folderSnirf, '.*/(\w*)$','tokens','once');


if ~settings.homerOn
    homerpath = fullfile(fileparts(mfilename('fullpath')) ,'..', 'Homer3');
    try
        run(fullfile(homerpath, "setpaths.m"));
    catch err
        warning(err.message);       % sometimes some system stuff may fail in linux? but paths are added before so ok
    end
    settings.homerOn = true;
end



%% get default stimuli from all snirf files

timeZero = datetime;
fprintf('gathering stimuli events... ')
stim = getDefaultStim(folderSnirf);
timeOne = datetime;
fprintf('completed in %.0f seconds\n', seconds(timeOne - timeZero))

%% preprocess runs
timeZero = datetime;
fprintf('preprocessing runs...\n')

[filenames, subfolders] = getSubfolderStructure(folderSnirf,'*.snirf');
subjN = length(filenames);
maxRuns = max(cellfun(@length,filenames));
runs = repmat(ProcResultClass,subjN, maxRuns);


parfor s = 1:subjN
    fprintf('processing runs in subject %s\n',subfolders(s));
    theseFilenames = filenames{s};
    for f = 1:maxRuns
        if length(theseFilenames) >= f        % control in parallel loop for the number of runs per subject
            filename = theseFilenames(f);
            runs(s,f) = runPreproc(filename, stim, settings);
        end
    end
end

timeOne = datetime;
fprintf('completed in %.0f seconds\n', seconds(timeOne - timeZero))
%% preprocess subjects

timeZero = datetime;
fprintf('preprocessing subjects...\n')
subj = repmat(ProcResultClass,subjN, 1);

parfor s = 1:subjN
    subjRuns = runs(s,:);
    subjRuns = subjRuns(1:length(filenames{s}));
    fprintf('processing subject %s\n',subfolders(s));
    subj(s) = subjPreproc(subjRuns);
end

timeOne = datetime;
fprintf('completed in %.0f seconds\n', seconds(timeOne - timeZero))
%% preprocess group (right now one group only)

timeZero = datetime;
fprintf('preprocessing group...\n')

group1 = groupPreproc(subj);

timeOne = datetime;
fprintf('completed in %.0f seconds\n', seconds(timeOne - timeZero))
%% save results

if saveData
    fprintf('Saving data...')
    mkdir(fullfile(folderSnirf,outFolder))
    if doGroupResultFile
        group = GroupClass;
        group.path = folderSnirf;
        group.outputDirname = outFolder;
        group.updateParentGui = @Update;
        group.iGroup = 1;

        %     group.procStream.output = group1;

        for s = 1:subjN
            group.subjs(s) = SubjClass;
            %         group.subjs(s).procStream.output = subj(s);
            group.subjs(s).path = folderSnirf;
            group.subjs(s).outputDirname = outFolder;
            group.subjs(s).updateParentGui = @Update;
            group.subjs(s).iSubj = s;
            group.subjs(s).name = subfolders{s};
            group.subjs(s).iGroup = 1;
            for r = 1:size(filenames{s},1)
                thisName = [char(subfolders(s)) '/' cell2mat(regexp(filenames{s}(r),'.*/(\w*.snirf)$','tokens','once'))];
                group.subjs(s).runs(r) = RunClass;
                group.subjs(s).runs(r).updateParentGui = @Update;
                group.subjs(s).runs(r).acquired = SnirfClass(filenames{s}{r});
                group.subjs(s).runs(r).path = folderSnirf;
                group.subjs(s).runs(r).outputDirname = outFolder;
                group.subjs(s).runs(r).iSubj = s;
                group.subjs(s).runs(r).name = thisName;
                group.subjs(s).runs(r).iRun = r;
                group.subjs(s).runs(r).iGroup = 1;
                %             group.subjs(s).runs(r).procStream.output = run(s,r);
            end
        end

        save(fullfile(folderSnirf, outFolder, "groupResults.mat"),'group')
    end
    output = group1;
    save(fullfile(folderSnirf, outFolder, strcat(groupName,'.mat')),'output')

    for s = 1:subjN
        subjFolder = fullfile(folderSnirf, outFolder, subfolders(s));
        mkdir(subjFolder);
        output = subj(s);
        save(fullfile(subjFolder, subfolders(s) + ".mat"), 'output')
        for f = 1:length(filenames{s})
            [~, thisFile] = fileparts(filenames{s}(f));
            output = runs(s,f);
            save(fullfile(subjFolder, thisFile + ".mat"), 'output')
        end
    end
    fprintf(' completed.\n')
end
