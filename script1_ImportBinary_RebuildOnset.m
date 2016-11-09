%% Init

close all      % figures
clear          % workspace
fclose('all'); % law-level I/O
clc            % command window

upperdir = fileparts(pwd);
path_to_save = [upperdir filesep 'export_processing' filesep];


%% Fetch file list

% Where are the files
path_to_binarydata = [fileparts(pwd) filesep 'BrainVisionAnalyzer2' filesep 'export'];
if ~exist(path_to_binarydata,'dir')
    error('%s is not a valid directory',path_to_binarydata)
end

% Fetch the list
runList = regexpdir(path_to_binarydata, '.dat$', 0);
if isempty(runList)
    error('no .dat file found in %s',path_to_binarydata)
end
for f = 1 : length(runList)
    [~, name, ~] = fileparts(runList{f});
    runList{f} = name;
end




%% Fetch onset list

% Where are the files
path_to_onsets = [fileparts(pwd) filesep 'BrainVisionAnalyzer2' filesep 'stim'];
if ~exist(path_to_onsets,'dir')
    error('%s is not a valid directory',path_to_onsets)
end

% Fetch the list
onsetsList = regexpdir(path_to_onsets, '.mat$', 0);
if isempty(runList)
    error('no .mat file found in %s',path_to_onsets)
end
for o = 1 : length(onsetsList)
    [~, name, ~] = fileparts(onsetsList{o});
    onsetsList{o} = name;
end


%% Load files & add onset time series

for f = 1 : length(runList)
    
    % Echo in CommandWindow
    fprintf('%d | importation of %s \n',f,runList{f,1})
    
    % Import the data
    [ EEGdata , STIMdata , VOLdata, infos ] = ImportBinaryFile( runList{f,1} , path_to_binarydata );
    
    [ ONSETdata , ptbVOLdata , StimStruct ] = RebuildOnsets( [path_to_onsets filesep onsetsList{f,1}] , VOLdata, infos );
    
    save([path_to_save runList{f}],'EEGdata','STIMdata','VOLdata','infos','ONSETdata','StimStruct','ptbVOLdata')
    
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
    
    close all
    figure
    hold all
    
    plot(ptbVOL_onset,volumeSample_idx(1:end-1)-ptbVOL_sample')
    xlabel('time (s)')
    ylabel('sample difference EEGvsPTB')
    
    
     %%
    
    close all
    figure
    hold all
    
    plot(volumeSample_idx(1:end-1),ptbVOL_sample')
    xlabel('time (s)')
    ylabel('sample difference EEGvsPTB')
    
    p = polyfit(volumeSample_idx(1:end-1),ptbVOL_sample',1)
    
end

