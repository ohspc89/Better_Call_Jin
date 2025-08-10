% This is prepared to concatenate timestamp added *.set files.
% The script is modified from 'DataPreparation_Biosemi.m'.

% Commented by Jinseok Oh, 8/6/2025
% - shortened lines
% - removed unused/unnecessary lines
%% Initalize directoris
clear all
% Adds all (sub)folders within './Dependencies/' to MATLAB's search path.
% Any functions or scripts within those folders can be called.
addpath(genpath('./Dependencies/'));

% Defines the directory where the EEG data is stored.
% By now you know '.' indicates your current working directory.
% Where are you located now? Do you see 'SampleData' folder within your
% current working directory?
% [extra] Previously, it was:
%   `DataDir = './SampleData/'`
% It is easy to forget about '/'. You can just give the folder name. Then
% instead of using `strcat`, which concatenates strings, use `fullfile`.
% For more, type `help fullfile` and hit return.
DataDir = 'SampleData';
trialInfo = readtable(fullfile(DataDir, 'TrialNote_EEGreachingStudy.xlsx'));

% Reads the trial information from an Excel file named 'TrialNote_EEGreachingStudy.xlsx' located in the DataDir.
% This creates a table named 'trialInfo' containing said information.
% strcat removes trailing white spaces, readtable creates a table, 
% uesd w/text files where each line consists of the same number of fields, 
% separated by a fixed "sep" character [colon, tab, or white space]

%% MUST CHANGE THESE -modify the participant and visit session for analysis
Pat = 'TD50'; Visit = 'Mon5';
% Defines the participant ID ('Pat') and visit session ('Visit') to be analyzed. 
% These values MUST BE CHANGED to match the desired participant and session.

% gets all data files of the participant and process one by one
% SessionDir = dir(strcat(DataDir,Pat,'/',Visit,'/*.set'));
% This is actually no longer a `SessionDir`...
% This should be labeled `dotSetFiles` or something similar...
dotSetFiles = dir(fullfile(DataDir, Pat, Visit, '*.set'));

% Assume the following hierarchy

% .                 (current working directory)
% |-- SampleData
% |   |-- TD08
% |   |   |-- Mon1
% |   |   |   |-- TD08_Mon1_Trial_1.fdt
% |   |   |   |-- TD08_Mon1_Trial_1.set  (event timestamps added)
% |   |   |   |-- TD08_Mon1_Trial_2.fdt
% |   |   |   |-- TD08_Mon1_Trial_2.set
% |   |   |   |-- ...

% (Below is false if you run 'DataPreparation_Biosemi_250809.m')
% If your .set files are sitting dirrectly under the folder: TD08,
% your line defining `SessionDir` should change like this:
%   dotSetFiles = dir(fullfile(DataDir, Pat, '*.set'));

if isempty(dotSetFiles)
    print('No files found. Please check the patient name and file directory.');
else
    Sess_trialIdx_str = cellfun(@(x) regexp(x, '\d+', 'match'), ...
        {dotSetFiles.name}, 'UniformOutput', false);
    Sess_trialIdx = cellfun(@(x) str2double(x{3}), Sess_trialIdx_str);
    

    % reorder session files in the file directory; in some systems
    % trial10 might rank higher than trial 2, 3, etc. 
    [~, ind_asc] = sort(Sess_trialIdx);
     % Sorts the 'dotSetFiles' structure based on the trial indices, 
     % ensuring that files are processed in ascending order.
    dotSetFiles_asc = dotSetFiles(ind_asc);

    % find rows in 'trialInfo' that match the current participant and visit
    % strcmp = compares str1 & str2, if same (True) returns 1
    ind = find(strcmp(trialInfo.ParticipantID, Pat) & ...
        (trialInfo.Month==str2double(Visit(end))));
    
    % extracts the trial info (columns 4 & 5) for the patient and visit
    % In case the column orders change... use column names instead
    Sess_trialInfo = trialInfo(ind, {'Activity', 'TrialType'});
    % Sess_trialInfo = trialInfo(ind,[4 5]);

    % makes sure Sess_trialInfo from excel file is ordered in ascending order
    [~, ind_asc2] = sort(Sess_trialInfo.Activity);
    % Sorts 'Sess_trialInfo' based on the 'Activity' column, ensures in ascending order.
    Sess_trialInfo = Sess_trialInfo(ind_asc2, :);

    % extracts trial types for trialInd that match trialType.Activity, 
    % Extracts the trial types from 'Sess_trialInfo' that correspond to the trial indices in 'SessionDir'.
    Sess_trialType = Sess_trialInfo.TrialType( ...
        ismember(Sess_trialIdx, Sess_trialInfo.Activity));

    % Expand/Reduce this cell array if needed
    % (ex. `trial_Types = {'Baseline'}`
    %   if only 'Baseline' .set files to be concatenated)
    trial_Types = {'Baseline', 'reach', 'Baseline & reach'};

    for i=1:length(trial_Types)
        concat_setfiles(dotSetFiles_asc, Sess_trialType, trial_Types{i})
    end

end

close all;
%closes all open figured 
% clc; clc= clears command window, this is commented out
disp('Done!');
% displays 'Done!'
