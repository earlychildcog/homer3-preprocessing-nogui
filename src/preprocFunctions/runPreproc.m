function out = runPreproc(filename, stim, settings)
% function to automarically run a preprocessing pipeline in a single run
% written by dim-ask for FBNirs 2022
% filename: name of the .snirf file
% trange  : range for dc averaging wrt stimulus marker

arguments
    filename char {mustBeFile}
    stim
    settings
end

%% parse input arguments

trange = settings.trange;

% fprintf('processing run %s... ',filename);
% timeZero = datetime;

%% optional for plotting

plotting = false;

%% Load snirf file 

acquired = SnirfClass(filename);
probe = acquired.probe;

%% create full stim class

allStimNames = arrayfun(@(x)x.name, stim)';
thisStimNames = arrayfun(@(x)x.name, acquired.stim)';

[stimIndexFull, stimIndexThis] = ismember(allStimNames, thisStimNames);

stim(stimIndexFull) = acquired.stim(stimIndexThis(stimIndexFull));



%% manual exclusion settings (can be changed in the future, for now none);

mlActMan = [];
tIncMan = [];
tInc = {ones(size(acquired.data.time))};
tInc0 = {ones(size(acquired.data.time))};

%% preprocessing pipeline

% hmrR_PruneChannels 
dRange = [0.001 10000000]; SNRthresh = 2; SDrange = [0 45];
mlActAuto = hmrR_PruneChannels(acquired.data, probe, mlActMan, tIncMan, dRange, SNRthresh, SDrange);

% hmrR_Intensity2OD
dod = hmrR_Intensity2OD(acquired.data); 

% hmrR_Resample2ConstFs
% fs = 0.1;
% dod = hmrR_Resample2ConstFs( dod, fs );

% hmrR_BandpassFilt
hpf = 0; lpf = 2;
dod = hmrR_BandpassFilt(dod, hpf, lpf);

% hmrR_MotionArtifactByChannel 
tMotion = 1; tMask = 1; STDEVthresh = 13.5; AMPthresh = 0.4;
[~, tIncAutoCh] = hmrR_MotionArtifactByChannel(dod, probe, mlActMan, mlActAuto, tIncMan, tMotion, tMask, STDEVthresh, AMPthresh);

% hmrR_MotionCorrectSpline 
p = 0.99; turnon = 1;
dod = hmrR_MotionCorrectSpline(dod, mlActAuto, tIncAutoCh, p, turnon);

% hmrR_MotionCorrectWavelet
iqr = 0.5; turnon = 1;
[~] = evalc('dod =  hmrR_MotionCorrectWavelet(dod, mlActMan, mlActAuto, iqr, turnon);');

% hmrR_MotionArtifact
tMotion = 2; tMask = 1; STDEVthresh = 20; AMPthresh = 1;
tIncAuto = hmrR_MotionArtifact(dod, probe, mlActMan, mlActAuto, tIncMan, tMotion, tMask, STDEVthresh, AMPthresh);

% hmrR_MotionArtifactByChannel
tMotion = 2; tMask = 1; STDEVthresh = 20; AMPthresh = 1;
[~ ,tIncAutoCh] = hmrR_MotionArtifactByChannel(dod,probe,mlActMan,mlActAuto,tIncMan, tMotion, tMask, STDEVthresh, AMPthresh);

% hmrR_PruneChannels
% dRange = [0.001 10000000]; SNRthresh = 5; SDrange = [0 45];
% mlActAuto = hmrR_PruneChannels(dod, probe, mlActMan, tIncMan, dRange, SNRthresh, SDrange);

% hmrR_BandpassFilt
hpf = 0.01; lpf = 0.5;
dod = hmrR_BandpassFilt(dod, hpf, lpf);

% hmrR_OD2Conc
ppf = [5.1 5.1];
dc = hmrR_OD2Conc(dod, probe, ppf);

% hmrR_BlockAvg
[dcAvg,dcAvgStd,nTrials,dcSum2] = hmrR_BlockAvg(dc, stim, trange);

out = ProcResultClass;
out.dod = dod;
out.dc = dc;
out.dcAvg = dcAvg;
out.dcAvgStd = dcAvgStd;
out.dcSum2 = dcSum2;
out.nTrials = nTrials;

out.misc = struct(...
    'mlActAuto', {mlActAuto}, ...
    'tIncAuto', {tIncAuto}, ...
    'tIncAutoCh', {tIncAutoCh}, ...
    'tInc', {tInc}, ...
    'svs', {[]}, ...
    'nSV', {0.9700}, ...
    'tInc0', {tInc0}, ...
    'stim', stim ...
);

% end message

% timeOne = datetime;
% fprintf('completed in %.0f seconds\n', seconds(timeOne - timeZero))

%% if plotting
if plotting
    % Hb type - {1 -> HbO,  2 -> HbR,  3 -> HbT}
    if ~exist('hbType','var') || isempty(hbType) %#ok<UNRCH> 
        hbType   = 1;
    end
    
    if ~exist('channels','var') || isempty(channels)
        channels = 1;
    end
    
    t = dc.time;
    y = dc.GetDataTimeSeries('reshape');
    PlotData(t, y, hbType, channels);
end


