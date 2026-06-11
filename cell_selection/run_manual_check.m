

%%
path_to_raw_data = 'W:\mEC_tau_ephys\';
mouse=string('mHYK20'); % CHECK IF THE FUNCTION TO GENERATE THE MATS IS THE ONE YOU WANT
path_to_cutting_log = strcat('D:\Projects\AD\Batch_mEC_ephys\read_data\cutting_log_AD_mec_batch21_HH_update');
[list_animals_cut_log,list_sessions_cut_log,list_proj_cut_log,list_kilo_cut_log,list_probe_cut_log,list_shankmix_log,list_protocols_log,list_VE_indices_log,list_npixels_log] = get_sessions_from_cutting_log_apr24(path_to_cutting_log,mouse);


for pathdata = list_sessions_cut_log %[string('260326'),string('270326'),string('280326'),string('290326'),string('300326'),string('310326')]
    disp(strcat('session',pathdata));
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