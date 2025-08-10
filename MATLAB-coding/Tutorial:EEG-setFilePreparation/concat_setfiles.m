function concat_setfiles(dotSetFiles, Sess_trialType, trial_type)
% stitch EEG of specifified trial_types, convert to EEGLAB .set file,
% and save to file directory
% Input, dotSetFiles icnluding file directories
%        Sess_trialType, the trial types for each trial in the session
%       trial_type, the specific trial type to extract EEG, 'reach',
%       'Baseline', 'SATCO', or 'all' which stiches all trials including SACCO ones
% Output: EEGLAB .set structure with trials of the specific types
% stitched together
% Ran Xiao, Emory University, 2/2024
% rev. 05.2024, added SATCO condition.
% edited 08. 2025 (Jinseok Oh)

switch trial_type
    case 'all'
        trial_idx = 1:length(dotSetFiles);
    case 'Baseline & reach'
        trial_idx = find(contains(Sess_trialType, {'Baseline', 'reach'}, ...
            'IgnoreCase', true));
    otherwise
        trial_idx = find(contains(Sess_trialType, trial_type, ...
            "IgnoreCase", true));
end

if ~isempty(trial_idx)
    EEG_merged = [];
    
    for i = 1:length(trial_idx)

        % Construct full path to the data file
        % A file is a .txt file (ex. Trial_1 - 2048Hz_export...txt)
        FilePath = fullfile(dotSetFiles(trial_idx(i)).folder, ...
            dotSetFiles(trial_idx(i)).name);
        EEG_current = pop_loadset('filename', FilePath);

        % If EEG_merged is empty
        if isempty(EEG_merged)
            EEG_merged = EEG_current;
        else
            % Merge the current dataset with the merged one
            % 1 concatenates along the data dimension
            EEG_merged = pop_mergeset(EEG_merged, EEG_current, 1);
        end
    end

    % Save the merged data
    pattern = '(?i)TD\d+|(?i)Mon\s?\d+|(?i)Month\s?\d+';
    
    % Use regexp to find matches to get the participant name and session
    % month
    matches = regexp(dotSetFiles(trial_idx(i)).folder, pattern, 'match');
    
    % save data into EEGLab .set format
    pop_saveset(EEG_merged, 'filename', ...
        [matches{1},'_', matches{2}, '_', trial_type, '.set'],...
        'filepath', dotSetFiles(trial_idx(i)).folder);
else
    disp('Check your trial_type value.')
end

end