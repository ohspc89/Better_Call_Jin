% Prepare data by converting into .set format from EEGLab as the input
% format for the toolbox
% Ran Xiao, Emory University, 2/12/2023
% revise for trial stitching across different trial conditions 2/8/2024
% added SATCO condition, and improve file structure 05.2024

%% Initialize directories
clear all
addpath(genpath('./Dependencies/'));

% this is where is data are on your computer
DataDir = './SampleData/';
trialInfo = readtable(strcat(DataDir,'TrialNote_EEGreachingStudy.xlsx'));
%strcat removes trailing white spaces

% MUST CHANGE THESE -modify the participant and visit session for analysis
Pat = 'TD50'; Visit = 'Mon5';

% get all data files of the participants and process one by one
SessionDir = dir(fullfile(DataDir,Pat,Visit,'/*.txt'));

if isempty(SessionDir)
    print('No files found. Please check the patient name and file directory.');
else
    % This will now generate .set files with this naming format:
    %   'TD{X}_Mon{Y}_Trial_{Z}.set'
    extractEEG_biosemi_individual(SessionDir)
end

close all;
% clc;
disp('Done!');