
mouse = string('MH498');
path_to_cutting_log = strcat('G:\My Drive\tau_log\cutting_log_AD_mec_batch21_HH_update');
[list_animals_cut_log,list_sessions_cut_log,list_proj_cut_log,list_kilo_cut_log,list_probe_cut_log,list_shankmix_log,list_protocols_log,list_VE_indices_log,list_npixels_log] = get_sessions_from_cutting_log_apr24(path_to_cutting_log,mouse);

ctypes = [string('GC'),string('BC'),string('SC'),string('HD_low_SI'),string('UN_low_SI')];
cscoretypes = [string('GC_scores'),string('BC_scores'),string('SI_scores'),string('HD_scores')];

all_scores  = cell(length(ctypes),length(cscoretypes));

for score_type = cscoretypes
    
    for pathdata = list_sessions_cut_log

        folder_session = strcat('W:\mEC_tau_ephys\',mouse,'\',pathdata,'\');
        ephysKilosortPath = get_concatenated_folder(folder_session);

        if exist(strcat(ephysKilosortPath,'\cell_type_classification\cell_list_classification_checked.xlsx'))

            [~, ~, cell_list] = xlsread(strcat(ephysKilosortPath,'\cell_type_classification\cell_list_classification_checked.xlsx'));
            load(strcat(ephysKilosortPath,'\cell_type_classification\classification_scores.mat'));

            clusters = cell2mat(cell_list(2:end,1));
            cell_types = string(cell_list(2:end,3));

            % get the scores for that session
            scores_type = scores{:,[score_type]};
            cl = scores{:,["clusters"]};
            for cell_type = ctypes
                clusters_celltype = clusters(cell_types==cell_type);
                scores_ = scores_type(ismember(cl,clusters_celltype));
                tmp = all_scores{find(ctypes==cell_type),find(cscoretypes==score_type)};
                tmp_to_add = [tmp,scores_'];
                all_scores{find(ctypes==cell_type),find(cscoretypes==score_type)}=tmp_to_add;
            end

        end

    end
end


figure;
iplot=1;
for i = 1:length(cscoretypes)
    subplot(2,4,iplot);
    for j = 1:length(ctypes)
        bar(j,nanmean([all_scores{j,i}]));
        hold on;
        errorbar(j,nanmean([all_scores{j,i}]),nanstd([all_scores{j,i}])/sqrt(length([all_scores{j,i}])),'k');
        hold on;
    end  
    ylabel(cscoretypes(i));
    xticks(1:length(ctypes));
    xticklabels(ctypes);
    xtickangle(45);
    iplot=iplot+1;
end


