

function store_corrected_grid_score_and_scale(animal_folder_,TTL_type,pixels_per_meter,m_per_bin,target_brain_region,spike_sampling_rate,pos_sampling_rate)

    concatenated_folder = get_concatenated_folder(animal_folder_);
    
    if exist(strcat(concatenated_folder,'\cell_type_classification\cell_list_classification_checked.xlsx'),'file') && ~exist(strcat(concatenated_folder,'\cell_type_classification\cell_list_classification_checked_with_scores.xlsx'),'file')
                
        [~, ~, file_exp] = xlsread(strcat(concatenated_folder,'\cell_type_classification\cell_list_classification_checked.xlsx'));
        clusters_cell_list = cell2mat(file_exp(2:end,1));
        cell_types_checked = string(file_exp(2:end,3));
        
        load(strcat(concatenated_folder,'\cell_type_classification\classification_scores.mat'));
        clusters = scores{:,["clusters"]};
        SI_scores = scores{:,["SI_scores"]};
        HD_scores = scores{:,["HD_scores"]};
        GC_scores = scores{:,["GC_scores"]};
        BC_scores = scores{:,["BC_scores"]};
        
        GC_scores_a = [];
        BC_scores_a = [];
        HD_scores_a = [];
        SI_scores_a = [];
        cell_types_a = [];
        GC_scales_a = [];

        recording_type = string('RE');
        [pos, dir_head, list_clusters, list_clusters_spikes] = get_spikes_pos_from_raw_data_file(animal_folder_,recording_type,TTL_type,spike_sampling_rate,pos_sampling_rate);
        
        for cell_i = clusters_cell_list'
            if cell_types_checked(find(clusters_cell_list==cell_i)) == string('GC')
                spikes_stamps = [list_clusters_spikes{1,find(list_clusters==cell_i)}];
                [GC_score,GC_scale] = get_GC_adjusted_score(pos,spikes_stamps,spike_sampling_rate,pos_sampling_rate,pixels_per_meter,m_per_bin);
                GC_scores_a = [GC_scores_a;round(GC_score,3)];
                GC_scales_a = [GC_scales_a;round(GC_scale,3)]; % GC scale is given in cm by the function get_GC_adjusted_score
                clear GC_score GC_scale;
            else
                GC_scores_a = [GC_scores_a;round(GC_scores(find(clusters_cell_list==cell_i)),3)];
                GC_scales_a = [GC_scales_a;NaN];
            end
            BC_scores_a = [BC_scores_a;round(BC_scores(find(clusters_cell_list==cell_i)),3)];
            HD_scores_a = [HD_scores_a;round(HD_scores(find(clusters_cell_list==cell_i)),3)];
            SI_scores_a = [SI_scores_a;round(SI_scores(find(clusters_cell_list==cell_i)),3)];
            cell_types_a = [cell_types_a;cell_types_checked(find(clusters_cell_list==cell_i))];
            
        end
        
        % save the new cell classification
        cd(strcat(concatenated_folder,'\cell_type_classification\'));
        cell_list1 = 'cell_list_classification_checked_with_scores.xlsx';

        writematrix(string('cluster ID'),cell_list1,'Sheet',1,'Range',char(strcat('A1')));
        writematrix(string('cell type (after check)'),cell_list1,'Sheet',1,'Range',char(strcat('C1')));
        writematrix(string('GC score'),cell_list1,'Sheet',1,'Range',char(strcat('D1')));
        writematrix(string('BC score'),cell_list1,'Sheet',1,'Range',char(strcat('E1')));
        writematrix(string('SI score'),cell_list1,'Sheet',1,'Range',char(strcat('F1')));
        writematrix(string('HD score'),cell_list1,'Sheet',1,'Range',char(strcat('G1')));
        writematrix(string('GC scale (cm)'),cell_list1,'Sheet',1,'Range',char(strcat('H1')));


        range_descr=strcat('A',num2str(2),':','A',num2str(1+length(cell_types_a)));
        writematrix(clusters_cell_list,cell_list1,'Sheet',1,'Range',char(range_descr));

        range_descr=strcat('C',num2str(2),':','C',num2str(2+length(cell_types_a)));
        writematrix(cell_types_a,cell_list1,'Sheet',1,'Range',char(range_descr));
        
        range_descr=strcat('D',num2str(2),':','D',num2str(2+length(cell_types_a)));
        writematrix(GC_scores_a,cell_list1,'Sheet',1,'Range',char(range_descr));
        
        range_descr=strcat('E',num2str(2),':','E',num2str(2+length(cell_types_a)));
        writematrix(BC_scores_a,cell_list1,'Sheet',1,'Range',char(range_descr));
        
        range_descr=strcat('F',num2str(2),':','F',num2str(2+length(cell_types_a)));
        writematrix(SI_scores_a,cell_list1,'Sheet',1,'Range',char(range_descr));
        
        range_descr=strcat('G',num2str(2),':','G',num2str(2+length(cell_types_a)));
        writematrix(HD_scores_a,cell_list1,'Sheet',1,'Range',char(range_descr));
        
        range_descr=strcat('H',num2str(2),':','H',num2str(2+length(cell_types_a)));
        writematrix(GC_scales_a,cell_list1,'Sheet',1,'Range',char(range_descr));

        
    end

end