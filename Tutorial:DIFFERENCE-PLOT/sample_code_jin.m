% Steps to draw a 'diference' plot
% For this example, I ran the sample data, TD08.
% 
% 1) Load RelPowers of Baseline and Reach
%    If you just double click .mat files, you will have only
%    ONE variable named 'RelPower' in your Workspace
%    (Try yourself!)
%    Therefore, you need to distinguish which RelPower is from
%    which condition. You can do this by making two different
%    variables.
%    Please replace "..." with the name of the correct *_RelPw.mat file.
%    Hint 1. CHECK YOUR CURRENT PATH. WHERE ARE YOU?
%    Do you see *_RelPw.mat from the 'Current Folder' tab?
%    If you see it,
%    If you do not see it, what should you do?
%    What would you do to run this code, regardless of what
%    your current PATH is?
RelPowerBaseline = load("TD08_Mon1_Baseline.set_Step4_RelPw.mat");
RelPowerReach = load("TD08_Mon1_reach.set_Step4_RelPw.mat");


% 2) You then create two different mu_motor arrays.
% change these two as needed
electrodes = [8,11,23,32]; 
frequencies = 11:20; %5-9HZ
% There's one more thing to learn - 
mu_motor = RelPower(electrodes, frequencies);

ax=axes();
hold(ax, 'on');
for i=1:length(electrodes)
    plot(mu_motor(i,:), 'DisplayName', num2str(electrodes(i)))

end
hold(ax, 'off');
legend()
