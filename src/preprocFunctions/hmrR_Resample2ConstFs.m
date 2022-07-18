% SYNTAX:
% data2 = hmrR_Resample2ConstFs(data, fs)
%
% UI NAME:
% interpolate_to_fs
%
% DESCRIPTION:
% Interpolate data to a constant sampling frequency, intended to be used 
% in cases of small variabilities in sampling frequency rate between 
% samples.
%
% INPUT:
% data - SNIRF data type containing data time course, time vector, and channels.
% fs - new sampling frequency
%
% OUTPUT:
% data2 - SNIRF data type containing the resampled data time course data
%
% USAGE OPTIONS:
% Resample_to Constant_Fs_OpticalDensity: dod = hmrR_Resample2ConstFs(dod, fs)
% Resample_to Constant_Fs_Auxiliary: aux = hmrR_Resample2ConstFs(aux, fs)
%
% PARAMETERS:
% fs: [0.1]
%
% PREREQUISITES:
% Intensity_to_Delta_OD: dod = hmrR_Intensity2OD( intensity )

function [data2] = hmrR_Resample2ConstFs( data, fs )
if isa(data, 'DataClass')
    data2 = DataClass().empty();
elseif isa(data, 'AuxClass')
    data2 = AuxClass().empty();
end

for ii=1:length(data)
    if isa(data, 'DataClass')
        data2(ii) = DataClass(data(ii));
    elseif isa(data, 'AuxClass')
        data2(ii) = AuxClass(data(ii));
    end
    y = data2(ii).GetDataTimeSeries();
    t = data2(ii).GetTime();
    % Check for NaN
    if max(max(isnan(y)))
       warning('Input to hmrR_Resample2ConstFs contains NaN values. Add hmrR_PreprocessIntensity_NAN to the processing stream.');
       return
    end
    % Check for finite values
    if max(max(isinf(y)))
       warning('Input to hmrR_Resample2ConstFs must be finite.');
       return
    end

    % check for identical timestamps
    idInd = diff(t) == 0;
    t(idInd) = [];
    y(idInd,:) = [];

    time0 = t(1) - mod(t(1), fs);
    time1 = t(end) - mod(t(end), fs);
    t2 = time0:fs:time1;
    y2 = interp1(t, y, t2);
    
    data2(ii).SetDataTimeSeries(y2);
    data2(ii).SetTime(t2);
    
end
