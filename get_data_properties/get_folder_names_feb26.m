
function [folder_names,pos_files,recording_letters,RE_recording_number] = get_folder_names_feb26(path_to_data_folders,VE_recording_number)

    recording_letters = [];
    folder_names = [];
    pos_files = [];

    d = dir(path_to_data_folders);
    for ii = 1:length(d) % loop on the number of folders recorded
        folder_name_tmp = d(ii).name;
        if sum(contains(string(folder_name_tmp),string('_shank'))) > 0 % if this is an individual recording (either a VE or a RE recording)
            
            recording_folder = strcat(path_to_data_folders,folder_name_tmp,'\');
            
            folder_names = [folder_names,recording_folder];
            recording_letters = [recording_letters,string(folder_name_tmp(1))];
            
            d2 = dir(recording_folder);
            
            for iifolder = 1:length(d2) % loop on the number of folders recorded
                folder_name_tmp2 = d2(iifolder).name;
                if (sum(contains(string(folder_name_tmp2),string('_pos'))) > 0) && (folder_name_tmp2(1) == folder_name_tmp(1))
                    pos_files = [pos_files,string(folder_name_tmp2)];
                    break;
                end
            end

        end
    end
    
    % first check
    if length(folder_names) ~= length(pos_files)
        disp('check the raw data folder: maybe could use the function get_folder_names_feb26_older_batches');
        keyboard;
    end
    
    % second check
    pp = pos_files(1,VE_recording_number);
    if sum(contains(pp,strcat('__',recording_letters(1,VE_recording_number),'_pos'))) == 0
        disp('is that the right VE folder?');
        keyboard;
    end
    
    n_recs = 1:length(pos_files);
    RE_recording_number = find(~ismember(n_recs,VE_recording_number));

end





