function [ Segments ] = SegmentConditionCLICK( filename , condition , samplesBefore , samplesAfter )

% Load data
RawData = load(filename);

% Find condition onset
condition_index = find(RawData.ONSETdata == condition);

% Segement the time series around the condition
Segments = zeros(size(RawData.EEGdata,1), 1-samplesBefore+samplesAfter ,length(condition_index),'single');

for index = 1 : length(condition_index)
    Segments(:,:,index) = RawData.EEGdata(:, (condition_index(index)+samplesBefore):(condition_index(index)+samplesAfter) );
end


if 0
    %%
    
    Right_Audio_Click = RawData.ONSETdata == 3;
    Left_Audio_Click = RawData.ONSETdata == 4;
    Right_Video_Click = RawData.ONSETdata == 5;
    Left_Video_Click = RawData.ONSETdata == 6;
    
    CLICK_right = RawData.ONSETdata == 12;
    CLICK_left = RawData.ONSETdata == 13;
    
    % close all
    
    figure
    hold all
    
    plot(Right_Audio_Click*3)
    plot(Left_Audio_Click*4)
    plot(Right_Video_Click*5)
    plot(Left_Video_Click*6)
    
    plot(CLICK_right*12)
    plot(CLICK_left*13)
    
end


end % function
