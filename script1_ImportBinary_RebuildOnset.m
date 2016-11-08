%% Init

close all      % figures
clear          % workspace
fclose('all'); % law-level I/O
clc            % command window


%% Fetch file list

% Where are the files
path_to_binarydata = [fileparts(pwd) filesep 'BrainVisionAnalyzer2' filesep 'export'];
if ~exist(path_to_binarydata,'dir')
    error('%s is not a valid directory',path_to_binarydata)
end

% Fetch the list
runList = regexpdir(path_to_binarydata, '.dat$', 0);

for f = 1 : length(runList)
    [~, name, ~] = fileparts(runList{f});
    runList{f} = name;
end

if isempty(runList)
    error('no .dat file found in %s',path_to_binarydata)
end

%% Fetch onset list

% Where are the files
path_to_onsets = [fileparts(pwd) filesep 'BrainVisionAnalyzer2' filesep 'stim'];
if ~exist(path_to_onsets,'dir')
    error('%s is not a valid directory',path_to_onsets)
end

% Fetch the list
onsetsList = getAllFilesWithExtention(path_to_onsets, '*.mat', 0);
if isempty(runList)
    error('no .dat file found in %s',path_to_onsets)
end


%% Load files & add onset time series

for f = 1 : length(runList)
    
    % Echo in CommandWindow
    fprintf('%d | importation of %s \n',f,runList{f,1})
    
    % Import the data
    [ EEGdata , STIMdata , VOLdata, infos ] = ImportBinaryFile( runList{f,1} , path_to_binarydata );
    
    volumeSample_idx = find(VOLdata);
    firstVolume.sample = volumeSample_idx(1);
    firstVolume.timestamp = firstVolume.sample * infos.SamplingInterval;
    
    S = load([path_to_onsets filesep onsetsList{f,1}]);
    ONSETdata = zeros(size(STIMdata));
    
    for n = 1 : length(S.names)
        
        for o = 1 : length(S.onsets{n})
            
            currentOnset = S.onsets{n}(o);
            currentSample = round( currentOnset / infos.SamplingInterval ) + firstVolume.sample;
            
            ONSETdata(currentSample) = n;
            
        end % o for
        
    end % n for
    
    
    ptbVOL = S.DataStruct.TaskData.KL.KbEvents{1,2};
    ptbVOL_idx = find(cell2mat(ptbVOL(:,2)));
    ptbVOL_onset = cell2mat(ptbVOL(ptbVOL_idx,1));
    ptbVOL_sample = round(ptbVOL_onset*1000) + firstVolume.sample;
    
    ptbVOLdata = zeros(size(STIMdata));
    
    ptbVOLdata(ptbVOL_sample) = 1;
    
    
    save(runList{f},'EEGdata','STIMdata','VOLdata','infos','ONSETdata','S','ptbVOLdata')
    
end



if 0
    
    time = (1:infos.DataPoints)*infos.SamplingInterval;

    
    %%
    
    close all
    figure
    AX(1) = subplot(5,1,1);
    plot(time,EEGdata(5,:))
    AX(2) = subplot(5,1,2);
    plot(time,STIMdata)
    AX(3) = subplot(5,1,3);
    plot(time,VOLdata)
    AX(4) = subplot(5,1,4);
    plot(time,ptbVOLdata)
    AX(5) = subplot(5,1,5);
    plot(time,ONSETdata)
    linkaxes(AX,'x')
    
    
    %%
    
    close all
    figure
    hold all
    plot(time,VOLdata)
    plot(time,ptbVOLdata*0.99)
    ScaleAxisLimits
    
    
    %%
    
    figure
    hold all
    
    plot(volumeSample_idx(1:end-1)-ptbVOL_sample')
    
end

