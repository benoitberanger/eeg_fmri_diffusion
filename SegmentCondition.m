function [ Segments ] = SegmentCondition( filename , condition , samplesBefore , samplesAfter )

% Load data
RawData = load(filename);

% Find condition onset
condition_index = find(RawData.ONSETdata == condition);

% Segement the time series around the condition
Segments = zeros(size(RawData.EEGdata,1), 1-samplesBefore+samplesAfter ,length(condition_index),'single');

for index = 1 : length(condition_index)
    Segments(:,:,index) = RawData.EEGdata(:, (condition_index(index)+samplesBefore):(condition_index(index)+samplesAfter) );
end

end % function
