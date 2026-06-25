



mouse = string('MH503');
pathdata = string('020924');
folder_session = strcat('W:\mEC_tau_ephys\',mouse,'\',pathdata,'\');
ephysKilosortPath = get_concatenated_folder(folder_session);
load(strcat(ephysKilosortPath,'\cell_type_classification\classification_scores.mat'));

[~, ~, file_exp] = xlsread(strcat(ephysKilosortPath,'\cell_type_classification\cell_list_classification_checked.xlsx'));
clusters = cell2mat(file_exp(2:end,1));
new_cell_types = string(file_exp(2:end,3));

mkdir(strcat(ephysKilosortPath,'\cell_type_classification\rate_maps_after_check\'));
for celltype_target = [string('BC'),string('GC'),string('SC'),string('UN_low_SI'),string('UN_high_SI'),string('HD_low_SI'),string('HD_high_SI')]
    figure;
    iplot=1;
    ipdf=1;
    for cell_i = clusters(new_cell_types==celltype_target)'
            subplot(5,5,iplot);
            Draw_RMap(rate_maps{1,find(clusters==cell_i)});
            axis off;
            %title(strcat(num2str(cell_i),{' '},new_cell_types(clusters==cell_i)));
            title(strcat(num2str(cell_i)));

            iplot=iplot+1;

            if iplot > 25
                sgtitle(celltype_target);
                h=gcf;
                set(h,'PaperOrientation','landscape');
                set(h,'PaperUnits','normalized');
                set(h,'PaperPosition', [0 0 0.9 0.9]);
                print(strcat(ephysKilosortPath,'\cell_type_classification\rate_maps_after_check\',celltype_target,'_',num2str(ipdf)),'-dpdf');
                ipdf=ipdf+1;
                iplot=1;
                close all;
                figure;

            end

    end
    h=gcf;
    set(h,'PaperOrientation','landscape');
    set(h,'PaperUnits','normalized');
    set(h,'PaperPosition', [0 0 0.9 0.9]);
    print(strcat(ephysKilosortPath,'\cell_type_classification\rate_maps_after_check\',celltype_target,'_',num2str(ipdf)),'-dpdf');
    close all;
    
end
