function [ ONSETdata , ptbVOLdata , StimStruct ] = RebuildOnsets( stimfile , VOLdata, infos )


%% Load stim file

StimStruct = load(stimfile);
ONSETdata = zeros(1,infos.DataPoints);


%% Find first volume on the EEG data

volumeSample_idx = find(VOLdata);
firstVolume.sample = volumeSample_idx(1);
firstVolume.timestamp = firstVolume.sample * infos.SamplingInterval;


%% Shift the t0 of stim onsets

for n = 1 : length(StimStruct.names)
    
    for o = 1 : length(StimStruct.onsets{n})
        
        currentOnset = StimStruct.onsets{n}(o);
        currentSample = round( currentOnset / infos.SamplingInterval ) + firstVolume.sample;
        
        ONSETdata(currentSample) = n;
        
    end % o for
    
end % n for


%% Create a volume timeserie from PTB data

ptbVOL = StimStruct.DataStruct.TaskData.KL.KbEvents{1,2};
ptbVOL_idx = find(cell2mat(ptbVOL(:,2)));
ptbVOL_onset = cell2mat(ptbVOL(ptbVOL_idx,1))';
ptbVOL_sample = round(ptbVOL_onset*1000) + firstVolume.sample;

ptbVOLdata = zeros(1,infos.DataPoints);

ptbVOLdata(ptbVOL_sample) = 1;


%% Linear regression of the time shift betwwen EEG and PTB

nVolumeEEG = length(volumeSample_idx);
nVolumePTB = length(ptbVOL_sample);

if nVolumePTB > nVolumeEEG % big problem !!
    fprintf('volumes on EEG : %d \n',nVolumeEEG)
    fprintf('volumes on PTB : %d \n',nVolumePTB)
    error('more volumes recored on the PTB compared to EEG : %d', stimfile)
elseif nVolumePTB == nVolumeEEG % unlikely
    samplesVolumeEEG = volumeSample_idx;
    samplesVolumePTB = ptbVOL_sample;
elseif nVolumePTB < nVolumeEEG % hope your in this case
    samplesVolumeEEG = volumeSample_idx(1:nVolumePTB);
    samplesVolumePTB = ptbVOL_sample;
end

p = polyfit(samplesVolumePTB-firstVolume.sample,samplesVolumeEEG-firstVolume.sample,1)
p = polyfit(samplesVolumePTB,samplesVolumeEEG,1)

newPTB = round(samplesVolumePTB*p(1) + p(2));


%%

close all
figure
hold all

subplot(2,1,1)
plot(volumeSample_idx(1:end-1),ptbVOL_sample)
xlabel('volume sample PTB')
ylabel('volume sample EEG')

subplot(2,1,2)
plot(ptbVOL_onset,volumeSample_idx(1:end-1)-ptbVOL_sample)
xlabel('time (s)')
ylabel('sample difference EEGvsPTB')

% p = polyfit(volumeSample_idx(1:end-1),ptbVOL_sample',1)

figure
hold all

plot(ptbVOL_onset,newPTB-samplesVolumeEEG)
xlabel('time (s)')
ylabel('sample difference EEGvsNEWPTB')


end
