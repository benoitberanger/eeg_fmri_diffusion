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
    
    plotRun(path_to_save, [ runList{f} '.mat'])
    drawnow
    
end
