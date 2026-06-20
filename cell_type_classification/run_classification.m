
function run_classification(animal_folder_,TTL_type,pixels_per_meter,m_per_bin,target_brain_region,spike_sampling_rate,pos_sampling_rate)

    concatenated_folder = get_concatenated_folder(animal_folder_);
    if ~exist(strcat(concatenated_folder,'\cell_type_classification\classification_scores.mat'),'file')
        mkdir(strcat(concatenated_folder,'\cell_type_classification\rate_maps_before_check\'));
        
        % get the spikes and position for all the cells selected by
        % Bombcell
        
%         animal_folder_ = 'W:\mEC_tau_ephys\MH503\030824\';
        recording_type = string('RE');
%         target_brain_region = string('mEC');
%         spike_sampling_rate=30000;
%         pos_sampling_rate=50;
        [pos, dir_head, list_clusters, list_clusters_spikes] = get_spikes_pos_from_raw_data_file(animal_folder_,recording_type,TTL_type,spike_sampling_rate,pos_sampling_rate);
        
        % generate the rate maps, calculate the scores and estimate the
        % cell types
        rate_maps = cell(1,length(list_clusters));
        BC_scores = [];
        GC_scores = [];
        HD_scores = [];
        SI_scores = [];
        cell_types = [];
        %scores = NaN(7,length(list_clusters));
        clusters = [];
        surfaces_low_FR = [];
        ratios_max_min_FR = [];
%         GC_scales = [];
        
        for cell_i = 1:length(list_clusters)
            spikes_stamps = [list_clusters_spikes{1,cell_i}];
            [BC_score,GC_score,SI_score,HD_score,cell_type,smooth_r_map,surface_low_FR,ratio_max_min_FR,GC_scale] = get_cell_RE_classification(pos,dir_head,spikes_stamps,spike_sampling_rate,pos_sampling_rate,target_brain_region,pixels_per_meter,m_per_bin);
            BC_scores = [BC_scores;BC_score];
            GC_scores = [GC_scores;GC_score];
            HD_scores = [HD_scores;HD_score];
            SI_scores = [SI_scores;SI_score];
            cell_types = [cell_types;cell_type];
            clusters = [clusters;list_clusters(1,cell_i)];
            rate_maps{1,cell_i} = smooth_r_map;
            
            surfaces_low_FR = [surfaces_low_FR;surface_low_FR];
            ratios_max_min_FR = [ratios_max_min_FR;ratio_max_min_FR];
%             GC_scales = [GC_scales;GC_scale];
        end
        
        scores = table(clusters,BC_scores,GC_scores,HD_scores,SI_scores,cell_types,surfaces_low_FR,ratios_max_min_FR);
        
        % store the spikes, pos, rate maps, scores and cell types
        cd(strcat(concatenated_folder,'\cell_type_classification\'));
        save('classification_scores.mat','rate_maps','list_clusters','list_clusters_spikes','scores');
        
        disp('classification finished');
        %% plot the results of the automatical cell type classification
        for celltype_target = [string('GC'),string('BC'),string('SC'),string('unclassified')]
            figure;
            iplot=1;
            ipdf=1;
            for cell_i= list_clusters(cell_types==celltype_target)
                subplot(5,5,iplot);
                Draw_RMap([rate_maps{1,list_clusters==cell_i}]);
                axis off;
                title(strcat(num2str(cell_i)));
%                 title(strcat(num2str(round(surfaces_low_FR(list_clusters==cell_i),2)),{' '},num2str(round(ratios_max_min_FR(list_clusters==cell_i),2))));
                %title(strcat(num2str(GC_scores(list_clusters==cell_i))));
                iplot=iplot+1;

                if iplot > 25
                    sgtitle(celltype_target);
                    h=gcf;
                    set(h,'PaperOrientation','landscape');
                    set(h,'PaperUnits','normalized');
                    set(h,'PaperPosition', [0 0 0.9 0.9]);
                    print(strcat(concatenated_folder,'\cell_type_classification\rate_maps_before_check\',celltype_target,'_',num2str(ipdf)),'-dpdf');
                    ipdf=ipdf+1;
                    iplot=1;
                    close all;
                    figure;

                end

                clear BC_score GC_score SI_score HD_score cell_type smooth_r_map;
            end

            h=gcf;
            set(h,'PaperOrientation','landscape');
            set(h,'PaperUnits','normalized');
            set(h,'PaperPosition', [0 0 0.9 0.9]);
            sgtitle(celltype_target);
            print(strcat(concatenated_folder,'\cell_type_classification\rate_maps_before_check\',celltype_target,'_',num2str(ipdf)),'-dpdf');
            close all;
        end

        % T = table(Age,Height,Weight,RowNames=LastName) 
        
    end    
end