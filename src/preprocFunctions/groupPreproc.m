function out = groupPreproc(in)
fprintf('processing group\n');
dcAvgSubjs = arrayfun(@(x)x.dcAvg, in, 'UniformOutput',false);
nTrialsSubjs = arrayfun(@(x)x.nTrials, in, 'UniformOutput',false);

[dcAvg,nTrials] = hmrG_SubjAvg(dcAvgSubjs,nTrialsSubjs);
dcAvgStd = hmrG_SubjAvgStd(dcAvgSubjs);

out = ProcResultClass;

out.dcAvg = dcAvg;
out.nTrials = nTrials;
out.dcAvgStd = dcAvgStd;

