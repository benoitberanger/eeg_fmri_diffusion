function plotRun( dir , filename )
% PLOTRUN plots all selected runs
%
% SYNTAX :
%  plotRun               -> ui to select files
%  plotRun(dir)          -> ui to select files in directory
%  plotRun(dir,filename) -> normal command
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
    
    f = figure('Name',[dir filesep filename{n}],'NumberTitle','off');
    nrAX = 4;
    AX = zeros(1,nrAX);
    idxAX = 0;
    
    % Mean of all channels ................................................
    
    idxAX = idxAX + 1;
    AX(idxAX) = subplot(nrAX,1,idxAX,'parent',f);
    plot(AX(idxAX),time,mean(EEGdata,1))
    ylabel(AX(idxAX),'mean(EEG channels)')
    
    % Stim on the EEG data ................................................
    
    mrk = unique(STIMdata); % what values ?
    mrk(mrk==0) = []; % take out 0
    Colors = lines( length(mrk) );
    
    idxAX = idxAX + 1;
    AX(idxAX) = subplot(nrAX,1,idxAX,'parent',f);
    hold all
    for l = 1 : length(mrk)
        stem( AX(idxAX), time(STIMdata ==mrk(l)) , STIMdata(STIMdata ==mrk(l)) , 'Color' , Colors(l,:) )
    end
    ylabel(AX(idxAX),'EEG marker')
    
    % Stim from PTB .......................................................
    
    mrk = unique(ONSETdata); % what values ?
    mrk(mrk==0) = []; % take out 0
    Colors = lines( length(mrk) );
    
    idxAX = idxAX + 1;
    AX(idxAX) = subplot(nrAX,1,idxAX,'parent',f);
    hold all
    for l = 1 : length(mrk)
        stem( AX(idxAX), time(ONSETdata ==mrk(l)) , ONSETdata(ONSETdata ==mrk(l)) , 'Color' , Colors(l,:) )
    end
    ylabel(AX(idxAX),'PTB marker')
    
    % Volumes .............................................................
    
    idxAX = idxAX + 1;
    AX(idxAX) = subplot(nrAX,1,idxAX,'parent',f);
    stem(AX(idxAX),time(find(VOLdata)),VOLdata(find(VOLdata)))
    set(AX(idxAX),'YTick',[])
    ylabel(AX(idxAX),'MRI volume')
    
    % .....................................................................
    
    xlabel('time (s)')
    
    linkaxes(AX,'x')
    
end

end % function
