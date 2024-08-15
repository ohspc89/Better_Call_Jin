% Prepare data by converting into .set format from EEGLab as the input
% format for the toolbox
%
% New version, modified to create a set file for each trial
% and is now self-contained.
% Annotated by Jinseok Oh [JO], 8/14/24

%% get list of files
% JO: Check where your eeblab2024 folder is.
% '.' indicates the current path. '..' indicates the parent path.
% For example, if you're in /Users/nremec/Downloads/InfantEEGProcessing2022-main,
% '.' is the same as your current path,
% '..' is /Users/nremec/Downloads/

% this is where is data are on your computer, path added 8-24 **fix
% JO: I think the line below should be similar to this one,
% particularly if you're using (and updating) the 'SampleData' folder
% inside 'EEGWISE-main' folder.
DataDir = '/Applications/EEG/EEGWISE-main/SampleData/';
% DataDir = 'Applications/EEG/eeglab2024.1/SampleData/';

% modify the participant and visit session for analysis
Pat = 'TD08'; Visit = 'Mon1';

% get all data files of the participants and process one by one
% `strcat(text, text, text, ...)` concatenates text. 
% Therefore, the value of the variable `folder` is 
% '/Applications/EEG/EEGWISE-main/SampleData/TD08/Mon1/'.
folder = strcat(DataDir,Pat,'/',Visit,'/');
% `dir(folder)` lists the files in a folder.
% '*' is a wildcard character. It means 'ANYTHING'
% So strcat(folder, '*.txt') will generate
% '/Applications/EEG/EEGWISE-main/SampleData/TD08/Mon1/*.txt'
% and when this is asked to be searched for, MATLAB will search
% ALL .txt files in /Applications/EEG/EEGWISE-main/SampleData/TD08/Mon1/
% If there are for example 12 txt files, SessionDir is a 12x1 struct.
SessionDir = dir(strcat(folder,'*.txt'));

% check that files were found, fprintf prints to command window
% `isempty(X)` returns True (1) if X is an empty array; 0 otherwise
% `fprintf(fid, FORMAT, A) applies the FORMAT to all elements of array A
% So in our example, the format is 'No files found in %s\n'
% '\n' is a symbol for line break or newline.
% '%s' is a symbol to indicate string/character.
% So for all elements of `folder`, which in our case it is only one string
% array, will be plugged into the format '%s\n'.
% In our example, it will be:
%   'No files found in /Applications/EEG/EEGWISE-main/SampleData/'
% fid 2 means standard error, so the entire line is telling MATLAB
% that if SessionDir is an emptry array, meaning no .txt file was found in
% 'folder', then return a standard error message (red color).
% `return` command is not meaningful - you can comment it out.
if isempty(SessionDir)
    fprintf(2, 'No files found in %s\n', folder);
    %return
end


%% process files one by one
%  process = do the same pipeline and turn each into the expected input for
%  EEGlab

% iterate through each
% If there were .txt files in 'folder', you will loop over those .txt files
for i = 1:length(SessionDir)
    % for every i, changing from 1 to the number of .txt files in 'folder'
    % `extractEEG_biosemi_new(SessionDir, trial_idx)` is defined below.
    extractEEG_biosemi_new(SessionDir, i)
    % This time `fprintf(FORMAT, A, B)`.
    % Check that there are two `%i` in the FORMAT: 'done with %i of %i\n'
    % `%i` means an integer.
    % A is `i`, the looping index - so this number will change every time
    % B is `length(SessionDir)`, which is a fixed number, the number of
    % .txt files in 'folder'. In the last iteration, `i` is the same as
    % `length(SessionDir)`.
    % Given there's no fid provided to the function, this message will be
    % printed normally, and not as a red error message.
    fprintf('done with %i of %i\n', i, length(SessionDir))
end
% Display the message - 'finished' when you are done with the loop.
disp('finished')


%% this is a tweaked version of the extractEEG_biosemi function
%  the main change is that is does not concatenate the activities
%  and it saves each activity as a separate file
%  the function is embeded inside, so it is only a single file -??

function extractEEG_biosemi_new(SessionDir, trial_idx)
% stitch EEG of specifified trial_types, convert to EEGLAB .set file,
% and save to file directory
% Input, SessionDir icnluding file directories
%        Sess_trialType, the trial types for each trial in the session
%       trial_type, the specific trial type to extract EEG, 'reach',
%       'Baseline', 'SATCO', or 'all' which stiches all trials including SACCO ones
% Output: EEGLAB .set structure with trials of the specific types
% stitched together ***this is no longer the case? confirm w/joh
% Ran Xiao, Emory University, 2/2024
% rev. 05.2024, added SATCO condition.

% if strcmp(trial_type, 'all')
%     trial_idx = 1:length(SessionDir);
% else
%     trial_idx = find(contains(Sess_trialType,trial_type,'IgnoreCase',true));
% end
% `assert(cond)` will throw an error if `cond` is false.
% `isnumeric(X)` returns true if X is a number, false otherwise.
assert(isnumeric(trial_idx))

% just to keep the nested formatting to make comparisons easier
if true % JO. This is not necessary

    for i = 1:length(trial_idx)

        % Construct full path to the data file
        % `fullfile(FOLDERNAME, FILENAME)` will make a full file name..
        % this is just the same as strcat(FOLDERNAME, '/', FILENAME)
        
        % `SessionDir(trial_idx).folder` is accessing the 'folder' field of
        % SessionDir struct array. To learn more about struct array,
        % mathworks.com/help/matlab/ref/struct.html
        % You can also double click `SessionDir` created in your Workspace.
        % Then check what are the values of the 'folder' field,
        % and what are the values of the 'name' field.
        FilePath = fullfile(SessionDir(trial_idx).folder, SessionDir(trial_idx).name);

        % Read the table data from the file
        data = readtable(FilePath);

        % Select 32 channel EEG data, assuming a sample rate (srate) of 2048
        % JO: output of `readtable()` is a table
        % (mathworks.com/help/matlab/tables.html)
        % `table2array(table)` converts a table to an array.
        % Noe that there's ['] at the end, so transposed table is converted
        % Each row corresponds to each electrode (total 32 rows)
        % Each column corresponds to a timepoint.
        % The number of columns at this point will be somewhere around
        % 2048 (Hz) * 59.xxx (or whatever actual time recording happened)
        EEGdata = table2array(data(:, 2:33))';

        % Remove timepoints at the end of data showing all NaNs
         % JO: sum(X, 1) will calculate the column sum of X
        % Each column will have 32 values (one value from each electrode)
        % In MATLAB, the sum of an array will be NaN if there's more than one NaN value
        % included in the array (ex. sum([1, 2, NaN]) returns NaN)
        % So if a column sum is NaN, that means at least one electrode recording value is NaN.
        % isnan(X) will return 1(True) if an entry is NaN and 0(False) if not.
        % (ex. isnan([1, 2, NaN]) returns an array: 0 0 1)
        % Finally, find(X) returns indices of 1s.
        % (ex. find(isnan([1, 2, NaN])) will be find([0, 0, 1]), so it returns 3)
        % indNaN will therefore be the indices of columns whose columnsums are NaNs.
        indNaN = find(isnan(sum(EEGdata, 1)));
         % ~ means NOT. isempty returns 1 if an array is empty, 0 if not.
        % (ex. isempty([]) returns 1. ~isempty([]) returns 0;
        %  isempty([1, 2, 44]) returns 0. ~isempty([1, 2, 44]) returns 1.)
        % if statement is in effect if the condition is True (1).
        % Therefore, it means that if there's at least more than one column
        % where its column sum is NaN, execute whatever commands located
        % between 'if' and 'end'.
        if ~isempty(indNaN)
            EEGdata(:, indNaN) = [];
        end
        
        EEG_raw = EEGdata;  % keep the variable name the same for below
    end

    % Load necessary libraries or toolboxes
    eeglab nogui; % Start EEGLAB if it's not already running

    % Load data into EEGLAB
    EEG = pop_importdata('dataformat', 'array', 'nbchan', 32, 'data', EEG_raw, 'srate', 2048, 'pnts', 0, 'xmin', 0);
    EEG = eeg_checkset(EEG);

    % Load channel file
    EEG = pop_chanedit(EEG, 'lookup', './Dependencies/BioSemi_32Ch.ced', 'load', {'./Dependencies/BioSemi_32Ch.ced', 'filetype', 'autodetect'});
    EEG = eeg_checkset(EEG);

    % Re-reference to T7-T8
    EEG = pop_reref(EEG, [7, 24], 'keepref', 'on');
    EEG = eeg_checkset(EEG);
    
    % Define the regular expression for extracting patterns like TD08 or Mon4
    % JO: See 'mathworks.com/help/matlab/matlab_prog/regular-expressions.html'
    %     [Metacharacters] table and [Quantifiers] table to understand \d+
    % '|' means OR, so the string below translates to...
    % 'TD{some numbers} OR Mon{some numbers}
    pattern = 'TD\d+|Mon\d+';
    
    % Use regexp to find matches to get the participant name and session
    % month
    % 'matches' will be a 1x2 cell array. Usually characters are saved
    % in a cell array. For cell, read mathworks.com/help.matlab/ref/cell.html
    matches = regexp(SessionDir(trial_idx).folder, pattern, 'match');
    
    % split by a separator, a whitespace.
    % A typical 'SessionDir(trial_idx).name' will be (see \d)
    % 'Activity\d - 2048Hz_export_EEG_2cameras_OPAL.txt'
    % If you split this character array by whitespace (' '),
    % you will again get a cell array.
    % The elements of this cell array will be:
    %   - 'Activity\d'
    %   - '-'
    %   - '2048Hz_export_EEG_2cameras_OPAL.txt'
    activity = split(SessionDir(trial_idx).name, ' ');
    % You take only the first element, which is 'Activity\d'
    activity = activity{1};
    % strcat again...
    filename = strcat(matches{1},'_', matches{2},'_', activity, '.set');

    % save data into EEGLab .set format
    EEG = pop_saveset( EEG, 'filename', filename, 'filepath', SessionDir(trial_idx(i)).folder);
end
end
