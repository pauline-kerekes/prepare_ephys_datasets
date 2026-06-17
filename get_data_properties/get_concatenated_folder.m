
function concatenated_folder = get_concatenated_folder(animal_folder_)

    % get the folder where the concatenated data is
    files_in_folder = dir(animal_folder_);

    for ii = 1:length(files_in_folder)

        path_to_try = strcat(animal_folder_,files_in_folder(ii).name);

        if exist(path_to_try) > 0 && length(char(files_in_folder(ii).name)) > 3
            files_in_folder_2 = dir(path_to_try);
            for iii = 1:length(files_in_folder_2)
                TF = contains(files_in_folder_2(iii).name, 'spikes_combi_meta.mat');
                if TF == 1
                    concatenated_folder = strcat(path_to_try,'\'); 
                    break;
                end
            end
        end

    end
    
end
