function  demo_fnirsPreprocess(project)
arguments
    project string {mustBeMember(project, ["beliefForm", "outcome", "outcome_test", "beliefForm_test"])}
end
% an example of calling the preprocessing scripts through calling "fnirsPreproc" function with suitable arguments

%% include homer paths
try
    path2homer = "../../libraries/fnirs/Homer3/setpaths.m";
    run(path2homer);
catch err
    warning(err);
end



settings = struct;
settings.project = "NAME_OF_PROJECT";
settings.testType = project;
% some settings that may depend on the project
if startsWith(settings.testType, "outcome")
    settings.trange = [-3 46];
elseif startsWith(settings.testType, "beliefForm")
    settings.trange = [-10 34];
end
% where data exists
settings.folderSnirf = "data/snirf/" + settings.testType;
settings.homerOn = true;
settings.saveData = true;
settings.doGroup = false;
settings.outFolder = "scriptOutput";
%% preproc

fnirsPreproc(settings)