
%% BE CAREFUL THE TRACK LENGTH IS HARDCODED IN store_variables_neuropixels_from_260424_fct

% in this version I changed the exp_ref: now read from vector lat pos

path_to_raw_data = 'W:\mEC_tau_ephys\';


for mouse=[string('MH502')] % CHECK IF THE FUNCTION TO GENERATE THE MATS IS THE ONE YOU WANT


    path_to_cutting_log = strcat('G:\My Drive\tau_log\cutting_log_AD_mec_batch21_HH_update');
    mapping_spreadsheet = 'D:\Projects\AD\Batch_mEC_ephys\read_data\mapping_npix_tau_gr_batch21_HH';
    folder_to_store_the_mats = string('D:\Projects\AD\Batch_mEC_ephys\mats\mEC_tau_new_batches\');
    folder_to_store_the_LFP = string('D:\Projects\AD\Batch_mEC_ephys\LFP_test\');

    %% VERY IMPORTANT CHECK BELOW
    cut='n';
    %%


    % to not change unless the mat files have been stored i two different
    % folders.
    folder_to_store_the_mats2 = folder_to_store_the_mats; % where it will store the new mat files
    
    if ~exist(folder_to_store_the_mats2)
        mkdir(folder_to_store_the_mats2);
        mkdir(folder_to_store_the_LFP);
    end
    
    
    [list_animals_cut_log,list_sessions_cut_log,list_proj_cut_log,list_kilo_cut_log,list_probe_cut_log,list_shankmix_log,list_protocols_log,list_VE_indices_log,list_npixels_log,list_exps_location_log,list_useful_comments_log] = get_sessions_from_cutting_log_apr24(path_to_cutting_log,mouse);
    % [list_animals_cut_log,list_sessions_cut_log,list_proj_cut_log,list_kilo_cut_log,list_probe_cut_log,list_shankmix_log] = get_sessions_from_cutting_log_apr24(path_to_cutting_log, excel_log, mouse); 
    which_kilosort = [list_kilo_cut_log{1}];

    done = [];
    sheet_number = 1;


    i_an=0;

    for i_session = 1:length(list_animals_cut_log)

            tic;
            animalID = list_animals_cut_log(i_session);
            session = list_sessions_cut_log(i_session);
            project = list_proj_cut_log(i_session);
            version_npix = list_probe_cut_log(i_session);
            shankmix = list_shankmix_log(i_session);
            VE_recording_number = list_VE_indices_log(i_session);
            n_pixels_per_meter = list_npixels_log(i_session);
            exp_location = list_exps_location_log(i_session);
            useful_comments = list_useful_comments_log(i_session);
            
            disp(animalID);
            disp(session);
            disp(n_pixels_per_meter);
            disp(exp_location);

    %         [mouse_index,mouse_batch,mouse_implant,reward_type] = get_animal_specs(animalID);        
    %         [folder_names,pos_files,number_recordings,title_trials,LED_direction,line_file,VE_recording_number,RE_recording_number,track_length] = get_folder_names_2_neuropixels(animalID,session);
    %         [path_to_data] = get_data_location_2(animalID,session,mouse_batch,project);
    %         concatenated_folder = fullfile(strcat(path_to_data,'concatenated_file\')); 

            path_to_data_folders = strcat(path_to_raw_data,animalID,'\',session,'\');
    %         [folder_names,pos_files,recording_letters,RE_recording_number] = get_folder_names_feb26(path_to_data_folders, VE_recording_number);
            concatenated_folder = strcat(path_to_data_folders,'concatenated_file\'); 


             if ~exist(strcat(concatenated_folder,'\manual_secondpart\'))
                parts=[1];
%                 disp('no second file for cutting');
             else
                parts=[1,2];
             end


            for part = parts
                %% OLD
                %store_variables_neuropixels_from_260424_fct(recording_letters,session,animalID,part,cut,folder_to_store_the_mats,project,version_npix);
                %store_variables_neuropixels_from_170924_fct(recording_letters,session,animalID,part,cut,folder_to_store_the_mats,project,version_npix);
                %add_LFP_with_delay_neuropixels_091024_fct(recording_letters,session,animalID,part,cut,folder_to_store_the_mats,project,version_npix);
                %add_LFP_and_spk_with_delay0_neuropixels_121024_fct(recording_letters,session,animalID,part,cut,folder_to_store_the_mats,project,version_npix,folder_to_store_LFP,folder_to_find_the_mats)
                %%

                %% CHECK HERE
%                 disp('check the VE track distance inside the following function!!');
%                 keyboard;
                if ismissing(useful_comments) == 1
                    store_variables_neuropixels_from_010326_fct(path_to_raw_data,session,animalID,part,VE_recording_number,cut,mapping_spreadsheet,version_npix,shankmix,folder_to_store_the_LFP,folder_to_store_the_mats,folder_to_store_the_mats2,n_pixels_per_meter,exp_location);
                else
                    if contains(string(useful_comments),string('ephys short'))==1
                        disp(string(useful_comments));
                        store_variables_neuropixels_from_010326_cut_pos_fct(path_to_raw_data,session,animalID,part,VE_recording_number,cut,mapping_spreadsheet,version_npix,shankmix,folder_to_store_the_LFP,folder_to_store_the_mats,folder_to_store_the_mats2,n_pixels_per_meter,exp_location);
                    else
                        store_variables_neuropixels_from_010326_fct(path_to_raw_data,session,animalID,part,VE_recording_number,cut,mapping_spreadsheet,version_npix,shankmix,folder_to_store_the_LFP,folder_to_store_the_mats,folder_to_store_the_mats2,n_pixels_per_meter,exp_location);
                    end
                end
                %% OLD
                % was used before 010326:
                %store_variables_neuropixels_from_081124_fct(recording_letters,session,animalID,part,cut,folder_to_store_the_mats,project,version_npix,folder_to_store_LFP,folder_to_store_the_mats2,shankmix);
                %store_variables_neuropixels_from_081124_cutpos_fct(recording_letters,session,animalID,part,cut,folder_to_store_the_mats,project,version_npix,folder_to_store_LFP,folder_to_store_the_mats2);
            end

            clear recording_letters session animalID ;
            toc;
    end




end








