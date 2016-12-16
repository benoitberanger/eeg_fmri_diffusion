%% Init

close all      % figures
clear          % workspace
fclose('all'); % law-level I/O
clc            % command window


%% Fetch file list

% Where are the files
upprdir = fileparts(pwd);
path_to_matfile = [upprdir filesep 'export_processing' filesep];
if ~exist(path_to_matfile,'dir')
    error('%s is not a valid directory',path_to_matfile)
end

% Fetch the list
% runList = getAllFilesWithExtention(path_to_matfile, '*.mat', 0);
runList = regexpdir(path_to_matfile, 'DEV', 0);
if isempty(runList)
    error('no file found in %s',path_to_matfile)
else
    disp(runList)
end

% Take out the extension
for f = 1 : length(runList)
    runList{f}(end-3:end) = [];
end


%% List of conditions to segment :

StimConditions = {
    'Horizontal_Checkerboard'; % 1
    'Vertical_Checkerboard';   % 2
    'Right_Audio_Click';       % 3
    'Left_Audio_Click';        % 4
    'Right_Video_Click';       % 5
    'Left_Video_Click';        % 6
    'Audio_Computation';       % 7
    'Video_Computation';       % 8
    'Video_Sentences';         % 9
    'Audio_Sentences';         % 10
    'Cross_Rest';              % 11
    'CLICK_right';             % 12
    'CLICK_left';              % 13
    };

% Window.Time = [ -0.100 ; +1.600+0.500 ];
Window.Time = [
    -0.100 , +1.600+0.500 ; % Horizontal_Checkerboard
    -0.100 , +1.600+0.500 ; % Vertical_Checkerboard
    -0.100 , +2.200+0.500 ; % Right_Audio_Click
    -0.100 , +2.200+0.500 ; % Left_Audio_Click
    -0.100 , +2.200+0.500 ; % Right_Video_Click
    -0.100 , +2.200+0.500 ; % Left_Video_Click
    -0.100 , +2.200+0.500 ; % Audio_Computation
    -0.100 , +1.400+0.500 ; % Video_Computation
    -0.100 , +1.400+0.500 ; % Video_Sentences
    -0.100 , +2.200+0.500 ; % Audio_Sentences
    -0.100 , +2.200+0.500 ; % Cross_Rest
    -1.000 , +1.000+0.000 ; % CLICK_right
    -1.000 , +1.000+0.000 ; % CLICK_left
    ]; % second

SamplingFrequency = 1000;
Window.Sample = Window.Time * SamplingFrequency;


%% Segment and filter conditions

% Load files & add onset time series

allCond = struct;

for cond = 1 : length(StimConditions)
    
    % Echo in CommandWindow
    fprintf('Conditin %s , %d \n',StimConditions{cond},cond)
    
    allCond.(StimConditions{cond}).rawSegments = [];
    
    for f = 1 : length(runList)
        
        % Echo in CommandWindow
        fprintf('segmentation of %s \n',runList{f,1})
        
        switch StimConditions{cond}
            case 'CLICK_right'
                [ rawSegments ] = SegmentConditionCLICK( runList{f,1} , cond , Window.Sample(cond,1) , Window.Sample(cond,2) );
            case 'CLICK_left'
                [ rawSegments ] = SegmentConditionCLICK( runList{f,1} , cond , Window.Sample(cond,1) , Window.Sample(cond,2) );
            otherwise
                [ rawSegments ] = SegmentCondition( runList{f,1} , cond , Window.Sample(cond,1) , Window.Sample(cond,2) );
        end
        % [ rawSegments ] = SegmentCondition( runList{f,1} , cond , Window.Sample(cond,1) , Window.Sample(cond,2) );
        allCond.(StimConditions{cond}).rawSegments = cat( 3 , allCond.(StimConditions{cond}).rawSegments , rawSegments);
        
    end
    %     allCond.(StimConditions{cond}).rawSegments(:,:,21) = []; % bad trial
    allCond.(StimConditions{cond}).Mean_baseline = mean(allCond.(StimConditions{cond}).rawSegments(:,1:abs(Window.Sample),:),2);
    allCond.(StimConditions{cond}).Mean_baseline = repmat(allCond.(StimConditions{cond}).Mean_baseline,[1 size(allCond.(StimConditions{cond}).rawSegments,2), 1 ]);
    allCond.(StimConditions{cond}).unfiltered = allCond.(StimConditions{cond}).rawSegments - allCond.(StimConditions{cond}).Mean_baseline;
    allCond.(StimConditions{cond}).mean_unfiltered = mean(allCond.(StimConditions{cond}).unfiltered,3);
    
    
    % BP filter : 1-40Hz
    allCond.(StimConditions{cond}).filtered = zeros(size(allCond.(StimConditions{cond}).unfiltered),'single');
    Hd = bp_eeg;
    for trial = 1 : size(allCond.(StimConditions{cond}).unfiltered,3)
        
        fprintf('filtering trial %d \n',trial)
        
        %     allCond.(StimConditions{cond}).filtered(:,:,trial) = fliplr(filter(Hd,fliplr(allCond.(StimConditions{cond}).unfiltered(:,:,trial))')');
        allCond.(StimConditions{cond}).filtered(:,:,trial) = filter(Hd,allCond.(StimConditions{cond}).unfiltered(:,:,trial)')';
        
    end
    
    
    % Mean
    allCond.(StimConditions{cond}).mean_filtered = mean(allCond.(StimConditions{cond}).filtered,3);
    
end

%% Save

% save('benoit2brainstorm',...
%     'allCond.(StimConditions{cond})','allCond.(StimConditions{cond}).unfiltered','allCond.(StimConditions{cond}).mean_unfiltered.unfiltered','allCond.(StimConditions{cond}).filtered','allCond.(StimConditions{cond}).filtered',...
%     'allCond.Vertical_Checkerboard','unfiltered_Vertical_Checkerboard','mean_unfiltered_Vertical_Checkerboard','filtered_Vertical_Checkerboard','filtered_Vertical_Checkerboard')

for cond = 1 : length(StimConditions)
    fieldNames = fieldnames(allCond.(StimConditions{cond}));
    for signal = 1 : length(fieldNames)
        
        v = genvarname([StimConditions{cond} '_' fieldNames{signal}]);
        eval([v ' = allCond.(StimConditions{cond}).(fieldNames{signal});'])
        fprintf('saving : %s \n',v)
        save([path_to_matfile v],v)
        
    end
end

fprintf('\n')
fprintf('saving : DONE \n')


%%

channel = 12;
StimConditions = {
    'Horizontal_Checkerboard';
    'Vertical_Checkerboard';
    'Right_Audio_Click';
    'Left_Audio_Click';
    'Right_Video_Click';
    'Left_Video_Click';
    'Audio_Computation';
    'Video_Computation';
    'Video_Sentences';
    'Audio_Sentences';
    'Cross_Rest';
    'CLICK_right';
    'CLICK_left';
    };
cond = 12;

if 0
    %%
    
    close all
    figure
    
    hold all
    for p = 1 : size(allCond.(StimConditions{cond}).rawSegments,3)
        plot(allCond.(StimConditions{cond}).rawSegments(channel,:,p),'DisplayName',num2str(p))
    end
    
    
    %%
    close all
    figure
    
    subplot(2,1,1)
    hold all
    for p = 1 : size(allCond.(StimConditions{cond}).rawSegments,3)
        plot(allCond.(StimConditions{cond}).unfiltered(channel,:,p),'DisplayName',num2str(p))
    end
    
    subplot(2,1,2)
    hold all
    for p = 1 : size(allCond.(StimConditions{cond}).rawSegments,3)
        plot(allCond.(StimConditions{cond}).filtered(channel,:,p),'DisplayName',num2str(p))
    end
    
    
    %%
    close all
    
    plotFFT(allCond.(StimConditions{cond}).mean_unfiltered(channel,:),1000,[1 80])
    plotFFT(allCond.(StimConditions{cond}).mean_filtered(channel,:),1000,[1 80])
    
    
    %%
    
    close all
    
    figure
    hold all
    for m = 1 : size(allCond.(StimConditions{cond}).mean_unfiltered,1)
        if m ~= 32 % ECG
            plot(allCond.(StimConditions{cond}).mean_unfiltered(m,:),'DisplayName',num2str(p))
        end
    end
    
    
    figure
    hold all
    for m = 1 : size(allCond.(StimConditions{cond}).mean_filtered,1)
        if m ~= 32 % ECG
            plot(allCond.(StimConditions{cond}).mean_filtered(m,:),'DisplayName',num2str(p))
        end
    end
    
end