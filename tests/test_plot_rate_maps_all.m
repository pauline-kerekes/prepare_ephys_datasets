
for mouse = [string('MH502'),string('MH508')]
    disp(mouse);
path_to_cutting_log = strcat('G:\My Drive\tau_log\cutting_log_AD_mec_batch21_HH_update');
[list_animals_cut_log,list_sessions_cut_log,list_proj_cut_log,list_kilo_cut_log,list_probe_cut_log,list_shankmix_log,list_protocols_log,list_VE_indices_log,list_npixels_log] = get_sessions_from_cutting_log_apr24(path_to_cutting_log,mouse);
path_to_plot = strcat('G:\My Drive\RE_maps_tau\after_check\',mouse,'\');
mkdir(path_to_plot);

figure;
iplot=1;
ipdf=1;
% [string('BC'),string('GC'),string('SC'),string('UN_low_SI'),string('UN_high_SI'),string('HD_low_SI'),string('HD_high_SI')]
for celltype_target = [string('BC'),string('GC'),string('SC'),string('UN_low_SI'),string('HD_low_SI')] % ,string('HD_low_SI'),string('HD_high_SI'),string('UN_high_SI')
    
    count=0;
    
        for pathdata = list_sessions_cut_log %string('020924')
            if list_protocols_log(list_sessions_cut_log==pathdata)== string('PI_short day 5')
                break;
            end
        
            folder_session = strcat('W:\mEC_tau_ephys\',mouse,'\',pathdata,'\');
            ephysKilosortPath = get_concatenated_folder(folder_session);

            if exist(strcat(ephysKilosortPath,'\cell_type_classification\cell_list_classification_checked.xlsx'))
            
                 load(strcat(ephysKilosortPath,'\cell_type_classification\classification_scores.mat'));

                [~, ~, file_exp] = xlsread(strcat(ephysKilosortPath,'\cell_type_classification\cell_list_classification_checked.xlsx'));
            clusters = cell2mat(file_exp(2:end,1));
            new_cell_types = string(file_exp(2:end,3));


            for cell_i = clusters(new_cell_types==celltype_target)'
                count=count+1;
                    subplot(5,5,iplot);
                    Draw_RMap(rate_maps{1,find(clusters==cell_i)});
                    axis off;
                    %title(strcat(num2str(cell_i),{' '},new_cell_types(clusters==cell_i)));
                    title(strcat(pathdata,'||',num2str(cell_i)));

                    iplot=iplot+1;

                    if iplot > 25
                        sgtitle(strcat(mouse,{' '},celltype_target));
                        h=gcf;
                        set(h,'PaperOrientation','landscape');
                        set(h,'PaperUnits','normalized');
                        set(h,'PaperPosition', [0 0 0.9 0.9]);
                        print(strcat(path_to_plot,celltype_target,'_',num2str(ipdf)),'-dpdf');
                        ipdf=ipdf+1;
                        iplot=1;
                        close all;
                        figure;

                    end

            end

            end
        end
        sgtitle(strcat(mouse,{' '},celltype_target));
        h=gcf;
        set(h,'PaperOrientation','landscape');
        set(h,'PaperUnits','normalized');
        set(h,'PaperPosition', [0 0 0.9 0.9]);
        print(strcat(path_to_plot,celltype_target,'_',num2str(ipdf)),'-dpdf');
        close all;
        ipdf=ipdf+1;
        iplot=1;
        disp(strcat('n',celltype_target,'=',num2str(count)));
end
end
