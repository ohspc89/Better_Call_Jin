% Steps to draw a 'diference' plot
% For this example, I ran the sample data, TD08.
% 
%% 1) First move to the 'Result directory'
% You set this when you ran EEGWISE.mlapp.
% Do you see *_RelPw.mat files from the 'Current Folder' tab?

%% 2) What's the PATH of a *_RelPw.mat file?
% (Hint. Remember which month's data you just processed?
%  If it was 'Mon1', do you see a 'Mon1_results' folder
%  at the top and all other files below that, with some
%  indendation? What would that mean?)

%% 3) Load two RelPw.mat files. 
% One is Baseline and the other one is Reach. 
% You are going to 'load' and save each of them to 
% a distinct variable: RelPowerBaseline & RelPowerReach
% You need to make changes in the two lines below. First, change the
% file names according to your choice (ex. TD46_Mon5_....).
% Then edit each file name so that it can be an ABSOLUTE PATH.
% (ex. /Users/joh/Downloads/EEGWISE-main/Results/WHAT_NEXT?)
RelPowerBaseline = load("TD08_Mon1_Baseline.set_Step4_RelPw.mat");
RelPowerReach = load("DO IT FOR YOURSELF");

% 3-1) Let's learn about a data type of MATLAB: structure
%      Please take a look at https://www.mathworks.com/help/matlab/structures.html
%      The two variables, `RelPowerBaseline` and `RelPowerReach` are
%      structures.
%      If you made to step 3, you should have the two variables in your
%      Workspace. Please double click and open one of the two variables.
%      Do you see that there are two 'fields' named 'f' and 'RelPower'?
%      In MATLAB, you can access a field of a structure by '.'
%      For example, uncomment the line below and run it.
% RelPowerBaseline.f

%% Step 4. Create TWO different mu_motor arrays
% change these two as needed
electrodes = [8,11,23,32]; 
frequencies = 11:20; %5-9HZ
% Make `mu_motor_baseline` and `mu_motor_reach`. 
mu_motor_baseline = RelPowerBaseline.RelPower(electrodes, frequencies);
mu_motor_reach = "DO IT FOR YOURSELF!";

% Also, I just prepared the names of the elctrodes here...
electrode_names = {'Fp1','AF3','F7','F3','FC1','FC5','T7','C3','CP1','CP5',...
    'P7','P3','Pz','PO3','O1','Oz','O2','PO4','P4','P8','CP6','CP2','C4',...
    'T8','FC6','FC2','F4','F8','AF4','Fp2','Fz','Cz'};
%% 5) Let's first overlay lines.
% One effective visualization is to plot each channel separately.
% See what happens when you change values of in section 4
% (ex. electrodes = [8,9,10,11,12,23,32,33]; or
%      frequencies = 11:30;)
% and re-run lines below
numplots = length(electrodes);
% tiledlayout: https://www.mathworks.com/help/matlab/ref/tiledlayout.html
% When you use it like `tiledlayout(m, n)``
% you're creating m x n tile arrangement that can display
% up to m*n plots.
tiledlayout(ceil(numplots/2), ceil(numplots/2))
% You will plot in the following order:
% 1st electrode, 2nd electrode, ..., {numplots}-th electrode
for i = 1:numplots
    % nexttile will move from the top to bottom
    % For example, if your `tiledlayout`command had m=3 and n=2,
    % two top row plots > two middle row plots > two bottom row plots
    ax = nexttile;
    plot(mu_motor_baseline(i, :), 'DisplayName', 'Baseline')
    % `hold` is the command to overlay lines on the current axis.
    hold(ax, 'on');
    plot(mu_motor_reach(i, :), 'DisplayName', 'Reach')
    hold(ax, 'off');
    % show plot legends
    legend()
    % plot title
    title(ax, char(electrode_names(electrodes(i))), 'FontSize', 13)
    % This is just to make the tick labels more meaningful
    ticksToShow = 1:2:length(frequencies);
    xticks(ticksToShow)
    xticklabels(compose('%d', frequencies(ticksToShow)))
    % label x and y axes
    xlabel('Frequency (Hz)')
    ylabel('Relative Power')
end

%% 6) Plot the difference!
% This part is similar to the one above...
numplots = length(electrodes);
tl = tiledlayout(ceil(numplots/2), ceil(numplots/2));
for i = 1:numplots
    ax = nexttile;
    plot(mu_motor_baseline(i, :) - "WHAT DO YOU SUBTRACT?")
    title(ax, char(electrode_names(electrodes(i))), 'FontSize', 13)
    % This is just to make the tick labels more meaningful
    ticksToShow = 1:2:length(frequencies);
    xticks(ticksToShow)
    xticklabels(compose('%d', frequencies(ticksToShow)))
    xlabel('Frequency (Hz)')
    ylabel('Relative Power')
end
title(tl, "Difference: Baseline - Reach", 'FontWeight',...
    'bold', 'FontSize', 18)