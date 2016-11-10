function plotRawEEG( dir , filename )
% PLOTRAWEEG plots all selected runs
%
% SYNTAX :
%  plotRawEEG               -> ui to select files
%  plotRawEEG(dir)          -> ui to select files in directory
%  plotRawEEG(dir,filename) -> normal command
%
% ARGUMENTS
%  dir      -> directory of the files
%  filename -> can be a char or a cell of chars
%


% Check input arguments ---------------------------------------------------

parsePlotArguments, % wrapper


for n = 1:length(filename)
    
    % Load ----------------------------------------------------------------
    
    load([dir filesep filename{n}])
    if ~exist('infos', 'var')
        error('the file does not contain the right data : %s', [dir filesep filename{n}] )
    end
    
    time = (1:infos.DataPoints)*infos.SamplingInterval;
    
    % Plot ----------------------------------------------------------------
    
    figure('Name',[dir filesep filename{n}],'NumberTitle','off');
    
    % EEG channels
    ax(1) = subplot(6,1,1:5);
    hold all
    for channel = 1 : size(EEGdata,1)
        plot(ax(1),time,EEGdata(channel,:) + channel*100,'DisplayName',num2str(channel))
    end
    
    % MRI Volumes
    ax(2) = subplot(6,1,6);
    hold all
    stem(ax(2),time(find(VOLdata)),VOLdata(find(VOLdata)))
    set(ax(2),'YTick',[])
    ylabel(ax(2),'MRI volume')
    
    xlabel('time (s)')
    linkaxes(ax,'x')
    
end

end % function
