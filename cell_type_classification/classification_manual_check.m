
function classification_manual_check(folder_session,figwidth,figheight,offset_top)


    if exist(strcat(folder_session,'\cell_type_classification\classification_scores.mat')) && ~exist(strcat(folder_session,'\cell_type_classification\cell_list_classification.xlsx'))
        % get the clusters indices and the corresponding cell types
        tic;
        load(strcat(folder_session,'\cell_type_classification\classification_scores.mat'));
        clusters = scores{:,["clusters"]};
        celltypes = scores{:,["cell_types"]};
    %     figwidth = 400;
    %     figheight=600;
    %     offset_top=0;
    %     rate_maps = ;
        %
        new_cell_types = celltypes;

        for cell_type_to_check = [string('GC'),string('BC'),string('SC')]
            % show the grid cells and ask the ones to remove
            false_positives = [];
            get_size_fig(figwidth,figheight,offset_top);

            iplott=1;
            for cell_i = clusters(new_cell_types==cell_type_to_check)'
                subplot(5,5,iplott);
                Draw_RMap(rate_maps{1,find(clusters==cell_i)});
                axis off;
                title(num2str(cell_i));

                iplott=iplott+1;

                if iplott > 25
                    sgtitle(strcat("which one is NOT a ",cell_type_to_check,"?"));
                    prompt = strcat("which is NOT a ",cell_type_to_check," (in the form [1,2,4])?");
                    value_field2 = input(prompt);
                    false_positives = [false_positives,value_field2];

                    iplott=1;
                    close all;
                    get_size_fig(figwidth,figheight,offset_top);

                end

            end
            sgtitle(strcat("which one is NOT a ",cell_type_to_check,"?"));
            prompt = strcat("which is NOT a ",cell_type_to_check," (in the form [1,2,4])?");
            value_field2 = input(prompt);
            false_positives = [false_positives,value_field2];
            close all;

            % get the scores to de-categorize the false positives
            SI_scores = scores{:,["SI_scores"]};
            HD_scores = scores{:,["HD_scores"]};
            ratios_max_min_FR = scores{:,["ratios_max_min_FR"]};
            surfaces_low_FR = scores{:,["surfaces_low_FR"]};

            for false_positive = false_positives

                if cell_type_to_check == string('SC')
                    if SI_scores(clusters==cell_i) >= 1.3
                        new_assignment = string('unclassified');
                    else
                        if HD_scores(clusters==cell_i) >= 0.19
                            new_assignment = string('HD');
                        else
                            new_assignment = string('unclassified');
                        end
                    end

                else % for GC or BC
                    if (ratios_max_min_FR(clusters==cell_i)>=30 && surfaces_low_FR(clusters==cell_i)>=0.4) %(ratios_max_min_FR(clusters==cell_i)>=20 && surfaces_low_FR(clusters==cell_i)>=0.4)
                        new_assignment = string('SC');
                    else
                        if HD_scores(clusters==cell_i) >= 0.19 && SI_scores(clusters==cell_i) < 1.3
                            new_assignment = string('HD');
                        else
                            new_assignment = string('unclassified');
                        end
                    end
                end
                new_cell_types(find(clusters==false_positive)) = new_assignment;
            end


            %% show the non grid cells and ask the ones to add
            false_negatives = [];
            get_size_fig(figwidth,figheight,offset_top);

            if cell_type_to_check == string('SC')
                list_of_cell_types_tonot_check = [string('SC'),string('BC'),string('GC')];
            elseif cell_type_to_check == string('BC')
                list_of_cell_types_tonot_check = [string('BC'),string('GC')];
            elseif cell_type_to_check == string('GC')
                list_of_cell_types_tonot_check = [string('GC')];
            end

            iplott=1;
            for cell_i = clusters(~ismember(new_cell_types,list_of_cell_types_tonot_check))'
                subplot(5,5,iplott);
                Draw_RMap(rate_maps{1,find(clusters==cell_i)});
                axis off;
                title(num2str(cell_i));

                iplott=iplott+1;

                if iplott > 25

                    sgtitle(strcat("which one is a ",cell_type_to_check,"?"));
                    prompt = strcat("which is a ",cell_type_to_check," (in the form [1,2,4])?");
                    value_field2 = input(prompt);
                    false_negatives = [false_negatives,value_field2];

                    iplott=1;
                    close all;
                    get_size_fig(figwidth,figheight,offset_top);

                end

            end
            sgtitle(strcat("which one is a ",cell_type_to_check,"?"));
            prompt = strcat("which is a ",cell_type_to_check," (in the form [1,2,4])?");
            value_field2 = input(prompt);
            false_negatives = [false_negatives,value_field2];
            close all;

            
            for false_negative = false_negatives
                new_cell_types(find(clusters==false_negative)) = cell_type_to_check;
            end

        end

        toc;
        % save the new cell classification
        cd(strcat(folder_session,'\cell_type_classification\'));
        cell_list1 = 'cell_list_classification.xlsx';

        writematrix(string('cluster ID'),cell_list1,'Sheet',1,'Range',char(strcat('A1')));
        writematrix(string('cell type (after check)'),cell_list1,'Sheet',1,'Range',char(strcat('C1')));

        range_descr=strcat('A',num2str(2),':','A',num2str(1+length(new_cell_types)));
        writematrix(clusters,cell_list1,'Sheet',1,'Range',char(range_descr));

        range_descr=strcat('C',num2str(2),':','C',num2str(2+length(new_cell_types)));
        writematrix(new_cell_types,cell_list1,'Sheet',1,'Range',char(range_descr));

        %% Check that:
        % the HD all have a SI score <= 1.3
        SI_scores = scores{:,["SI_scores"]};
        HD_scores = scores{:,["HD_scores"]};
    %     clusters_HD = clusters(new_cell_types==string('HD'));
        SI_scores_HDcells = SI_scores(new_cell_types==string('HD'));
        HD_scores_HDcells = HD_scores(new_cell_types==string('HD'));

        if isempty(find(SI_scores_HDcells>=1.3)) == 0
            disp("some HD cells have a high SI score! (they shouldnt)");
            keyboard;
        end

        if isempty(find(SI_scores_HDcells<0.19)) == 0
            disp("some HD cells have a low HD score! (they shouldnt)");
            keyboard;
        end

        %% plot the maps with the new classification for sanity check
        mkdir(strcat(folder_session,'\cell_type_classification\rate_maps_after_check\'));
        for celltype_target = [string('BC'),string('GC'),string('SC'),string('unclassified')]
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
                        print(strcat(folder_session,'\cell_type_classification\rate_maps_after_check\',celltype_target,'_',num2str(ipdf)),'-dpdf');
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
            print(strcat(folder_session,'\cell_type_classification\rate_maps_after_check\',celltype_target,'_',num2str(ipdf)),'-dpdf');
            close all;
        end
        
    end

    
end


