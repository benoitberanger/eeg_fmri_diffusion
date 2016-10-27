%% Init

close all      % figures
clear          % workspace
fclose('all'); % law-level I/O
clc            % command window


%% Fetch file list

% Where are the files
path_to_matfile = pwd;
if ~exist(path_to_matfile,'dir')
    error('%s is not a valid directory',path_to_matfile)
end

% Fetch the list
runList = getAllFilesWithExtention(path_to_matfile, '*.mat', 0);
if isempty(runList)
    error('no .mat file found in %s',path_to_matfile)
end

% Take out the extension
for f = 1 : length(runList)
    runList{f}(end-3:end) = [];
end


%% List of conditions to segment :

StimConditions = {
    'Horizontal_Checkerboard';
    'Vertical_Checkerboard';
    %     'Right_Audio_Click';
    %     'Left_Audio_Click';
    %     'Right_Video_Click';
    %     'Left_Video_Click';'Audio_Computation';
    %     'Video_Computation';
    %     'Video_Sentences';
    %     'Audio_Sentences';
    %     'Cross_Rest';
    %     'CLICK_right';
    %     'CLICK_left';
    };

Window.Time = [ -0.100 ; +1.600+0.500 ];
SamplingFrequency = 1000;
Window.Sample = Window.Time * SamplingFrequency;

%% Load files & add onset time series


Segments_Horizontal_Checkerboard = [];
Segments_Vertical_Checkerboard = [];

for f = 1 : length(runList)
    
    % Echo in CommandWindow
    fprintf('segmentation of %s \n',runList{f,1})
    
    [ Segments ] = SegmentCondition( runList{f,1} , 1 , Window.Sample(1) , Window.Sample(2) );
    Segments_Horizontal_Checkerboard = cat( 3 , Segments_Horizontal_Checkerboard , Segments);
    
end

Segments_Horizontal_Checkerboard(:,:,21) = [];

Mean_baseline_Horizontal_Checkerboard = mean(Segments_Horizontal_Checkerboard(:,1:abs(Window.Sample),:),2);
Mean_baseline_Horizontal_Checkerboard = repmat(Mean_baseline_Horizontal_Checkerboard,[1 size(Segments_Horizontal_Checkerboard,2), 1 ]);

unfiltered_Horizontal_Checkerboard = Segments_Horizontal_Checkerboard - Mean_baseline_Horizontal_Checkerboard;
mean_unfiltered_Horizontal_Checkerboard = mean(unfiltered_Horizontal_Checkerboard,3);


%% BP filter : 1-40Hz

filtered_Horizontal_Checkerboard = zeros(size(unfiltered_Horizontal_Checkerboard),'single');

Hd = bp_eeg;



for trial = 1 : size(unfiltered_Horizontal_Checkerboard,3)
    
    fprintf('filtering trial %d \n',trial)
    
    %     filtered_Horizontal_Checkerboard(:,:,trial) = fliplr(filter(Hd,fliplr(unfiltered_Horizontal_Checkerboard(:,:,trial))')');
    filtered_Horizontal_Checkerboard(:,:,trial) = filter(Hd,unfiltered_Horizontal_Checkerboard(:,:,trial)')';
    
end


%% Mean

mean_filtered_lHorizontal_Checkerboard = mean(filtered_Horizontal_Checkerboard,3);


%%

channel = 20;


if 0
    %%
    
    close all
    figure
    
    hold all
    for p = 1 : size(Segments_Horizontal_Checkerboard,3)
        plot(Segments_Horizontal_Checkerboard(channel,:,p),'DisplayName',num2str(p))
    end
    
end


if 0
    %%
    close all
    figure
    
    subplot(2,1,1)
    hold all
    for p = 1 : size(Segments_Horizontal_Checkerboard,3)
        plot(unfiltered_Horizontal_Checkerboard(channel,:,p),'DisplayName',num2str(p))
    end
    
    subplot(2,1,2)
    hold all
    for p = 1 : size(Segments_Horizontal_Checkerboard,3)
        plot(filtered_Horizontal_Checkerboard(channel,:,p),'DisplayName',num2str(p))
    end
    
end


if 0
    %%
    close all
    
    plotFFT(mean_unfiltered_Horizontal_Checkerboard(channel,:),1000,[1 80])
    plotFFT(mean_filtered_Horizontal_Checkerboard(channel,:),1000,[1 80])
    
    
end


if 0
    %%
    
    close all
    
    figure
    hold all
    for m = 1 : size(mean_unfiltered_Horizontal_Checkerboard,1)
        if m ~= 32 % ECG
            plot(mean_unfiltered_Horizontal_Checkerboard(m,:),'DisplayName',num2str(p))
        end
    end
    
    
    figure
    hold all
    for m = 1 : size(mean_filtered_lHorizontal_Checkerboard,1)
        if m ~= 32 % ECG
            plot(mean_filtered_lHorizontal_Checkerboard(m,:),'DisplayName',num2str(p))
        end
    end
    
end