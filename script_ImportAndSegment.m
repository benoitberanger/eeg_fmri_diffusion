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
runList = getAllFilesWithExtention(path_to_binarydata, '*.dat', 0);
if isempty(runList)
    error('no .dat file found in %s',path_to_binarydata)
end

% Take out the extension
for f = 1 : length(runList)
    runList{f}(end-3:end) = [];
end


%% Load files & segement them

for f = 1 : length(runList)
    
    % Echo in CommandWindow
    fprintf('%d | importation of %s \n',f,runList{f,1})
    
    % Import the data
    [ EEGdata , STIMdata , VOLdata ] = ImportBinaryFile( runList{f,1} , path_to_binarydata );
    
    
end
