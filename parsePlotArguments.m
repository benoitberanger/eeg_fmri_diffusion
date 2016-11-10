if nargin == 0
    [filename,dir] = uigetfile('*.mat', ...
        'Select a run file', ...
        'MultiSelect','on');
    if isnumeric(filename) && filename == 0
        error('No file selected')
    end
end

if nargin == 1
    [filename,dir] = uigetfile('*.mat', ...
        'Select a run file', ...
        dir, ...
        'MultiSelect','on');
    if isnumeric(filename) && filename == 0
        error('No file selected')
    end
end

if nargin == 2
    
    % dir
    if ~ischar(dir)
        error('dir must be a char, not a %s',class(dir))
    else
        if ~exist(dir,'dir')
            error('invalid dir : %s',dir)
        end
    end
    
    % filename
    if iscell(filename)
        if ~isvector(filename)
            error('filename mus be a vector cell of strings, or a string')
        end
        for n = 1:length(filename)
            if ~ischar(filename{n})
                error('filename{%d} is not a char : %s',n,class(filename{n}))
            elseif ~exist([dir filesep filename{n}],'file')
                error('file does not exist : %s',[dir filesep filename{n}])
            end
        end
    elseif ischar(filename)
        if ~isvector(filename)
            error('filename mus be a vector cell of strings, or a string')
        end
        if ~exist([dir filesep filename],'file')
            error('file does not exist : %s',[dir filesep filename])
        end
    end
    
end

if ischar(filename)
    filename = {filename};
end

if strcmp(dir(end),filesep)
    dir(end) = [];
end
