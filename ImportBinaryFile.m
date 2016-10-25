function [ EEGdata , STIMdata , VOLdata, infos ] = ImportBinaryFile( filenameNoExtensionNoPath , pathOfFiles )
%%IMPORTBINARYFILE read a binary file from BrainVisionAnalyzer2
%
% The function uses .dat .vhdr .vmrk, optimized for 64 channels EEG data
%
% See also

allExtensions = {'.dat', '.vhdr', '.vmrk'};


%% Check input

if ~( ischar(filenameNoExtensionNoPath) && size(filenameNoExtensionNoPath,1)==1 && size(filenameNoExtensionNoPath,2)>0 )
    error('input(1) must be a char(1,n)')
end
if ~( ischar(pathOfFiles) && size(pathOfFiles,1)==1 && size(pathOfFiles,2)>0 )
    error('input(2) must be a char(1,n)')
end

if ~isempty( strfind(filenameNoExtensionNoPath, '.') )
    error('%s has an extension', filenameNoExtensionNoPath)
end


%% Check exist

% Path
if exist(pathOfFiles,'dir') == 0
    error('%s is not a folder', pathOfFiles)
end

%Check if .dat .vhdr .vmrk are present
for e = 1 : length(allExtensions)
    
    fileName = [pathOfFiles filesep filenameNoExtensionNoPath allExtensions{e}];
    
    if exist(fileName,'file') == 0
        error('%s is not file', fileName)
    end
    
end


%% Fetch the number of samples in .vhdr

fileName = [pathOfFiles filesep filenameNoExtensionNoPath '.vhdr'];

% Open file
fileID = fopen(fileName, 'r');
if fileID < 3
    error('%s could not be open',fileName)
end

% Read file as single char of string
fileContent = fread(fileID,'*char')';
fclose(fileID);

% Fetch the number of samples
osef1 = regexp(fileContent, 'DataPoints=(\d*)','tokens','once');
DataPoints = str2double( osef1{1} );
infos.DataPoints = DataPoints;

% Fetch the number of channels
osef2 = regexp(fileContent, 'NumberOfChannels=(\d*)','tokens','once');
NrChannels = str2double( osef2{1} );
infos.NrChannels = NrChannels;

% Fetch the sampling interval
osef3 = regexp(fileContent, 'SamplingInterval=(\d*)','tokens','once'); % in microsecond (µs)
SamplingInterval = str2double( osef3{1} )/1e6; % convert to second
infos.SamplingInterval = SamplingInterval;


%% Import the .dat

fileName = [pathOfFiles filesep filenameNoExtensionNoPath '.dat'];

% Open file
fileID = fopen(fileName, 'r');
if fileID < 3
    error('%s could not be open',fileName)
end

EEGdata  = single(zeros(NrChannels,DataPoints));
STIMdata = uint8(zeros(1,DataPoints));
VOLdata  = false(size(STIMdata));

EEGdata(1:NrChannels,:) = fread(fileID,[NrChannels DataPoints],'float32');
fclose(fileID);

% EEGdata(:,end) = []; % it's only zeros
EEGdata = single(EEGdata); % data are encoded in singles (32), not doubles (64)


%% Append the markers from .vmrk

fileName = [pathOfFiles filesep filenameNoExtensionNoPath '.vmrk'];

% Open file
fileID = fopen(fileName, 'r');
if fileID < 3
    error('%s could not be open',fileName)
end

% Read file as single char of string
fileContent = fread(fileID,'*char')';
fclose(fileID);

% Parse the file to fetch ther marker lines
expression = 'Mk(\d+)=([a-zA-Z_\s]+),([0-9a-zA-Z_\s]+|),(\d+),(\d),(\d)';
tokens = regexp(fileContent, expression, 'tokens');
markers = cell(length(tokens),6);
for mrk = 1 : length(tokens)
    markers(mrk,:) = tokens{mrk};
end

% In marker lines, fetch the Stimulus
volPattern = 'S  \d+';
stimMarkers_idx = regexp(markers(:,3),volPattern);
stimMarkers_idx = ~cellfun(@isempty, stimMarkers_idx);
stimMarkers_idx = find(stimMarkers_idx);

% In EMGdata, add the Stimulus marker to the corresponding sample
for smrk = 1 : length(stimMarkers_idx)
    stimValue = sscanf( markers{stimMarkers_idx(smrk),3} , 'S  %d' );
    STIMdata(str2double(markers{stimMarkers_idx(smrk),4})) = stimValue;
end


% In marker lines, fetch the Volume
volPattern = 'R128';
volMarkers_idx = find(strcmp(markers(:,3),volPattern));

% In EMGdata, add the Volume marker to the corresponding sample
for vmrk = 1 : length(volMarkers_idx)
    VOLdata(str2double(markers{volMarkers_idx(vmrk),4})) = 1;
end


end
