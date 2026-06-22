
path_to_raw_data = 'W:\mEC_tau_ephys\';
% PARAMETERS TO CHECK
figwidth = 600;
figheight=800;
offset_top=0;
%

for mouse = [string('MH503')]
    path_to_cutting_log = strcat('G:\My Drive\tau_log\cutting_log_AD_mec_batch21_HH_update');
    [list_animals_cut_log,list_sessions_cut_log,list_proj_cut_log,list_kilo_cut_log,list_TTL_log,list_shankmix_log,list_protocols_log,list_VE_indices_log,list_npixels_log] = get_sessions_from_cutting_log_apr24(path_to_cutting_log,mouse);

    for pathdata = list_sessions_cut_log
        disp(pathdata);
        animal_folder_=strcat(path_to_raw_data,mouse,'\',pathdata,'\');
        concatenated_folder = get_concatenated_folder(animal_folder_);
        classification_manual_check(concatenated_folder,figwidth,figheight,offset_top);    
    end

end



%%
folder_session = 'E:\mHYK24\170626\a_shankmix4_17062026_g0__b_shankmix4_17062026_g0\';

% parameters to display the rate maps to check the cell type classification
figwidth = 500;
figheight=700;
offset_top=0;


classification_manual_check(folder_session,figwidth,figheight,offset_top);