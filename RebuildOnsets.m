function [ ONSETdata , ptbVOLdata , StimStruct ] = RebuildOnsets( stimfile , VOLdata, infos )


%% Load stim file

StimStruct = load(stimfile);

ONSETdata = zeros(1,infos.DataPoints);
ptbVOLdata = zeros(1,infos.DataPoints);


%% Find first volume on the EEG data

eegVOL.sample_idx = find(VOLdata);
eegVOL.onset = eegVOL.sample_idx*infos.SamplingInterval;
firstVolume.sample = eegVOL.sample_idx(1);
firstVolume.timestamp = firstVolume.sample * infos.SamplingInterval;


%% Create a volume timeserie from PTB data

ptbVOL.raw = StimStruct.DataStruct.TaskData.KL.KbEvents{1,2};
ptbVOL.idx = find(cell2mat(ptbVOL.raw(:,2)));
ptbVOL.onset = cell2mat(ptbVOL.raw(ptbVOL.idx,1))' + firstVolume.timestamp;


%% Linear regression of the time shift betwwen EEG and PTB

nVolumeEEG = length(eegVOL.onset);
nVolumePTB = length(ptbVOL.onset);

if nVolumePTB > nVolumeEEG % big problem !!
    fprintf('volumes on EEG : %d \n',nVolumeEEG)
    fprintf('volumes on PTB : %d \n',nVolumePTB)
    error('more volumes recored on the PTB compared to EEG : %d', stimfile)
elseif nVolumePTB == nVolumeEEG % unlikely
    onsetVolumeEEG = eegVOL.onset;
    onsetVolumePTB = ptbVOL.onset;
elseif nVolumePTB < nVolumeEEG % hope your in this case
    onsetVolumeEEG = eegVOL.onset(1:nVolumePTB);
    onsetVolumePTB = ptbVOL.onset;
end

TimeshiftPoly = polyfit(onsetVolumePTB,onsetVolumeEEG,1);
TimeshiftFcn = @(x) TimeshiftPoly(1)*x + TimeshiftPoly(2);


%% Apply time shift

% Volumes acquired by PTB (just as diagnostic)
ptbVOL.onset_shifted = TimeshiftFcn(onsetVolumePTB);
ptbVOL.sample = round(ptbVOL.onset_shifted/infos.SamplingInterval);
ptbVOLdata(ptbVOL.sample) = 1;


%% Shift the t0 of stim onsets

for n = 1 : length(StimStruct.names)
    
    for o = 1 : length(StimStruct.onsets{n})
        
        currentOnset = StimStruct.onsets{n}(o);
        currentSample = round( TimeshiftFcn(currentOnset) / infos.SamplingInterval ) + firstVolume.sample;
        
        ONSETdata(currentSample) = n;
        
    end % o for
    
end % n for


if 0
    %% Check if time shift is correct
    
    close all
    figure
    hold all
    
    subplot(2,1,1)
    plot(onsetVolumeEEG,onsetVolumePTB)
    xlabel('volume onset PTB')
    ylabel('volume onset EEG')
    
    subplot(2,1,2)
    plot(onsetVolumeEEG,onsetVolumeEEG-onsetVolumePTB)
    xlabel('time (s)')
    ylabel('onset difference EEGvsPTB')
        
    figure
    hold all
    
    plot(onsetVolumePTB,ptbVOL.onset_shifted-onsetVolumeEEG)
    xlabel('time (s)')
    ylabel('onset difference EEGvsptbVOL.onset_shifted')
    
    
end

end
