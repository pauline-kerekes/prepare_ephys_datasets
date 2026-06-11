

%%
for pathdata = [string('150326'),string('160326'),string('170326'),string('180326')]
    ephysKilosortPath = char(strcat('W:\mEC_tau_ephys\mHYK20\',pathdata,'\concatenated_file')); %ephysKilosortPath = 'W:\mEC_tau_ephys\mHYK20\110526\concatenated_file'; % like: 'W:\mEC_tau_ephys\mHYK20\110526\concatenated_file'
    manual_check(ephysKilosortPath);
end
















%%
% % Get the screen size
% screenSize = get(0, 'ScreenSize');
% screenWidth = screenSize(3);
% screenHeight = screenSize(4);
% % Define the default figure width and height
% figWidth = 700%560;  % Default MATLAB figure width
% figHeight = 538%420; % Default MATLAB figure height
% % Define an offset from the top of the screen
% topOffset = 100;  % Adjust this value as needed
% % Calculate the position for the new figures
% position = [screenWidth-figWidth, screenHeight-figHeight-topOffset, figWidth, figHeight];
% % Set the default figure position
% set(0, 'DefaultFigurePosition', position);
% figure;
% [x, y] = ginput(1);  