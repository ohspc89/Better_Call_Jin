function extractEEG_biosemi_individual(SessionDir)
% convert raw .txt files to EEGLAB .set files
% modified `extractEEG_biosemi.m`

% edited 08. 2025 (Jinseok Oh)

trial_idx = 1:length(SessionDir);
if ~isempty(trial_idx)
    timing_info = table();

    for i = 1:length(trial_idx)
        % Construct full path to the data file
        % A file is a .txt file (ex. Trial_1 - 2048Hz_export...txt)
        FilePath = fullfile(SessionDir(trial_idx(i)).folder, ...
            SessionDir(trial_idx(i)).name);

        % Read the table data from the file
        data = readtable(FilePath);
        try 
            % Select 32 channel EEG data; sampling rate (srate) of 2048
            % Again, TMM may be consistent regarding column names
            % Try to make use of specific column names (ex. 'CH1')
            channels = arrayfun(@(x) ['CH' num2str(x)], 1:32,...
                'UniformOutput', false);
            % ' at the end of this code means transpose
            % So `EEGdata` will be a 32-by-N matrix.
            EEGdata = table2array(data(:, channels))';
        catch
            continue;
        end

        % Remove timepoints at the end of data showing all NaNs
        indNaN = find(isnan(sum(EEGdata, 1)));
        if ~isempty(indNaN)
            EEGdata(:, indNaN) = [];
        end

        % construction original time table for later reference
        timing_info.fid(i) = trial_idx(i);% the index of files
        
        % Open the file
        fileID = fopen(FilePath, 'r');
        % Read the file contents
        fileContents = fread(fileID, '*char')';
        fclose(fileID);
        
        % Define the regular expression pattern to match the date and time stamp
        patternDate = '\d{1,2}-\d{1,2}-\d{4}'; % Pattern for date in the format 'D-M-YYYY' or 'DD-MM-YYYY'
        patternTime = '\d{2}:\d{2}:\d{2}:\d{3}'; % Pattern for time in the format 'HH:MM:SS:FFF'
        
        % Extract the date and time using the defined patterns
        dateMatch = regexp(fileContents, patternDate, 'match');
        timeMatch = regexp(fileContents, patternTime, 'match');
        
        % Combine the date and time into a single datetime string
        datetimeString = sprintf('%s %s', dateMatch{1}, timeMatch{1});
        
        % Convert the datetime string to a MATLAB datetime object
        dateTime = datetime(datetimeString, 'InputFormat', ...
            'd-M-yyyy HH:mm:ss:SSS');

        timing_info.startDT(i) = dateTime;
        if i == 1
            timing_info.sid_start(i) = 1;% the starting index of samples
            timing_info.sid_end(i) = size(EEGdata,2);% the starting index of samples
        else
            timing_info.sid_start(i) = max(timing_info.sid_end(1:i-1))+1;% the starting index of samples
            timing_info.sid_end(i) = max(timing_info.sid_end(1:i-1))+size(EEGdata,2);% the starting index of samples
        end

        if isempty(EEGdata)
            disp("No valid EEG available");
            return;
        end

        % Load necessary libraries or toolboxes
        eeglab nogui; % Start EEGLAB if it's not already running

        % Load data into EEGLAB
        % 'dataformat' ['array|matlab|ascii|float32']: format of the input
        % 'nbchan': number of channel in data
        % 'data' ['varname'|'filename']: import a file or variable
        %   into the EEG structure of EEGLAB
        % 'srate': data sampling rate
        % 'pnts': number of point per frame in the data (epoched data only)
        % 'xmin': starting time in second
        EEG = pop_importdata('dataformat', 'array', ...
            'nbchan', 32, 'data', EEGdata, 'srate', 2048, ...
            'pnts', 0, 'xmin', 0);
        % Check consistency of dataset fields
        EEG = eeg_checkset(EEG);
    
        % Load channel file
        % Originally 'lookup' parameter was set - which is redundant
        EEG = pop_chanedit(EEG, 'load', ...
            {'./Dependencies/BioSemi_32Ch.ced', 'filetype', 'autodetect'});
        EEG = eeg_checkset(EEG);
    
        % Re-reference to T7-T8
        EEG = pop_reref(EEG, [7, 24], 'keepref', 'on');
        EEG = eeg_checkset(EEG);
        
        % Define the regular expression for extracting patterns like TD08 or
        % Mon4 or month 4 or month4 or Month 4
        %pattern = 'TD\d+|Mon\d+';
        pattern = '(?i)TD\d+|(?i)Mon\s?\d+|(?i)Month\s?\d+';
    
        % Use regexp to find matches to get the participant name and session
        % month
        matches = regexp(SessionDir(trial_idx(i)).folder, pattern, 'match');
    
        % save data into EEGLab .set format
        % TMM - 'Trial_X - 2048Hz_...' is the new nomenclature?
        pop_saveset(EEG, 'filename', ...
            [matches{1},'_', matches{2}, ...
            '_Trial_', num2str(trial_idx(i)), '.set'], ...
            'filepath', SessionDir(trial_idx(i)).folder);
            % 'filepath', fileparts(SessionDir(trial_idx(i)).folder));
    end % end of the for-loop
    
    % save the timing info, including the original trial type, trial id,
    % and the sample start and end sample index for each trial (2048 hz)
    save(fullfile(...
        SessionDir(trial_idx(i)).folder, ...
        [matches{1},'_', matches{2}, '_ori_timing_info.mat']), ...
        'timing_info');
end
end