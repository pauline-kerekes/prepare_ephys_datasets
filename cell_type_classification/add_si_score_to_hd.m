
mouse = string('MH503');

path_to_cutting_log = strcat('G:\My Drive\tau_log\cutting_log_AD_mec_batch21_HH_update');

% pathdata = string('020924');
[list_animals_cut_log,list_sessions_cut_log,list_proj_cut_log,list_kilo_cut_log,list_probe_cut_log,list_shankmix_log,list_protocols_log,list_VE_indices_log,list_npixels_log] = get_sessions_from_cutting_log_apr24(path_to_cutting_log,mouse);


for pathdata = list_sessions_cut_log

    folder_session = strcat('W:\mEC_tau_ephys\',mouse,'\',pathdata,'\');
    ephysKilosortPath = get_concatenated_folder(folder_session);
    
    if exist(strcat(ephysKilosortPath,'\cell_type_classification\cell_list_classification_checked.xlsx'))
        [~, ~, file_exp] = xlsread(strcat(ephysKilosortPath,'\cell_type_classification\cell_list_classification_checked.xlsx'));
        load(strcat(ephysKilosortPath,'\cell_type_classification\classification_scores.mat'));

        clusters = scores{:,["clusters"]};
        SI_scores = scores{:,["SI_scores"]};
        HD_scores = scores{:,["HD_scores"]};

        clusters_cell_list = cell2mat(file_exp(2:end,1));
        cell_types_checked = string(file_exp(2:end,3));

        df  = find(cell_types_checked==string('HD'));
        disp(pathdata);
        disp(length(df));
        new_cell_types_checked = cell_types_checked;

        for ii = df'

            cluster_ii = clusters_cell_list(ii);
            si_cluster_ii = SI_scores(clusters==cluster_ii);

            if si_cluster_ii < 1.3
                new_cell_types_checked(ii) = string('HD_low_SI');
            else
                new_cell_types_checked(ii) = string('HD_high_SI');
            end

        end

        cd(strcat(ephysKilosortPath,'\cell_type_classification\'));
        cell_list1 = 'cell_list_classification_checked.xlsx';

        writematrix(string('cluster ID'),cell_list1,'Sheet',1,'Range',char(strcat('A1')));
        writematrix(string('cell type (after check)'),cell_list1,'Sheet',1,'Range',char(strcat('C1')));

        range_descr=strcat('A',num2str(2),':','A',num2str(1+length(new_cell_types_checked)));
        writematrix(clusters_cell_list,cell_list1,'Sheet',1,'Range',char(range_descr));

        range_descr=strcat('C',num2str(2),':','C',num2str(2+length(new_cell_types_checked)));
        writematrix(new_cell_types_checked,cell_list1,'Sheet',1,'Range',char(range_descr));

    end
end

