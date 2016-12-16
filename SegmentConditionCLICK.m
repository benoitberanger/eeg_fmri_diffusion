function [ Segments ] = SegmentConditionCLICK( filename , condition , samplesBefore , samplesAfter )

% Load data
RawData = load(filename);

time = (1:RawData.infos.DataPoints)*RawData.infos.SamplingInterval;

% Find condition onset
cond_vect = RawData.ONSETdata == condition;
cond_idx = find(cond_vect);
click_onset = time(cond_vect);
diff_click = diff(click_onset);
assumed_condition = diff_click > 1; % seconds
condition_index = cond_idx(find(assumed_condition)+1);
condition_index = [cond_idx(1) condition_index];
    
% Segement the time series around the condition
Segments = zeros(size(RawData.EEGdata,1), 1-samplesBefore+samplesAfter ,length(condition_index),'single');

for index = 1 : length(condition_index)
    Segments(:,:,index) = RawData.EEGdata(:, (condition_index(index)+samplesBefore):(condition_index(index)+samplesAfter) );
end

end % function
