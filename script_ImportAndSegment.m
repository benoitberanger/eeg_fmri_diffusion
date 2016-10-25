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


%% Load files & segement them

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
    
    save(runList{f},'EEGdata','STIMdata','VOLdata','infos','ONSETdata','S')
    
    
%     figure
%     AX(1) = subplot(4,1,1);
%     plot(EEGdata(20,:))
%     AX(2) = subplot(4,1,2);
%     plot(STIMdata)
%     AX(3) = subplot(4,1,3);
%     plot(VOLdata)
%     AX(4) = subplot(4,1,4);
%     plot(ONSETdata)
%     linkaxes(AX,'x')
    
    
end
