function out = subjPreproc(in)
% preprocessing at subject level
dcAvgRuns = arrayfun(@(x)x.dcAvg, in, 'UniformOutput',false);
mlActRuns = arrayfun(@(x)x.misc.mlActAuto, in, 'UniformOutput',false);
nTrialsRuns = arrayfun(@(x)x.nTrials, in, 'UniformOutput',false);

% hmrS_RunAvg
[dcAvg, nTrials] = hmrS_RunAvg(dcAvgRuns,mlActRuns,nTrialsRuns);

% hmrS_RunAvgStd
dcAvgStd = hmrS_RunAvgStd(dcAvgRuns);

out = ProcResultClass;

out.dcAvg = dcAvg;
out.dcAvgStd = dcAvgStd;
out.nTrials = nTrials;




