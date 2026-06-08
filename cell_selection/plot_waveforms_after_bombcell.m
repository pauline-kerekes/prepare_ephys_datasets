
function plot_waveforms_after_bombcell(ephysKilosortPath, nb_channels, min_spikes)

    % load the data
    cd(strcat(ephysKilosortPath,'\bombcell'));
    qMetric = parquetread('qmetrics_pk.parquet');
    cluster_indices = qMetric{:,["phy_clusterID"]};
    best_channels_bombcell = qMetric{:,["maxChannels"]};
    load('units_classification_pk.mat', 'unitType');
    %

    colors = ['r','g','g','k'];
    types_kept = [];

    plotpath = strcat(ephysKilosortPath,'\waveforms_check\');% 'D:\a_shank0_10032026_g0\waveforms_check\';
    if ~exist(plotpath)
        mkdir(plotpath);
    end

    npy_spike_clusters = readNPY(strcat(ephysKilosortPath,'\spike_clusters.npy'));
    npy_spike_times = readNPY(strcat(ephysKilosortPath,'\spike_times.npy'));

    figure;
    iplott = 1;
    ipdf = 1;
    array_waveforms_for_display = cell(1,length(find(unitType==1 | unitType==2)));
    array_noise_for_display = cell(1,length(find(unitType==0)));
    units_good_for_array = [];
    units_noise_for_array = [];


    for cell_i = 1:max(npy_spike_clusters)%1:1593 %cluster_list_after_manual_cutting

        plot_go = 'y';

        spk_stamps_notaligned_inconcat = npy_spike_times(npy_spike_clusters==cell_i); 

        if length(spk_stamps_notaligned_inconcat) >= min_spikes
            spikes_for_wf = randperm(length(spk_stamps_notaligned_inconcat),200);

        else % less than min_spikes spikes, do not take for the analysis
            plot_go = 'n';
        end

        if plot_go == 'y' %&& unitType(find(cluster_indices==cell_i))~=0 && unitType(find(cluster_indices==cell_i))~=3

            %spikes_for_wf = 200:400;

            a_poor_raw_waveform = zeros(length(spikes_for_wf),nb_channels,80); 

            % opening the file to extract the waveforms from
            raw_file_with_all_the_data = fopen(strcat(ephysKilosortPath,'\spikes_combi.bin'));
            %raw_file_with_all_the_data = fopen(strcat(path_to_data,'merged.bin'));


            ispiketoadd=1;

            for ispike = spikes_for_wf %2:n_spikes-1 % was 2:n_spikes-1 before 081124
                fseek(raw_file_with_all_the_data , (spk_stamps_notaligned_inconcat(ispike)-30)*nb_channels*2, 'bof');
                a_poor_raw_waveform(ispiketoadd,:,:) = fread(raw_file_with_all_the_data, [nb_channels, 80], '*int16');
                ispiketoadd=ispiketoadd+1;
            %                             fseek(raw_file_with_all_the_data , (spk_stamps_notaligned_inconcat_forwf(ispike)-30)*nb_channels*2, 'bof');
            %                             a_poor_raw_waveform(ispike,:,:) = fread(raw_file_with_all_the_data, [nb_channels, 80], '*int16');
            end

            best_channel = best_channels_bombcell(find(cluster_indices==cell_i));

            subplot(5,6,iplott);        

            % to plot a few channels around the best channel
            % get the recording group
            recording_group = ceil(best_channel/48);
            pos_best_channel = best_channel-((recording_group-1)*48)+1;
            range = pos_best_channel-4:pos_best_channel+4;
            range(range<=0)=[];
            range(range>48)=[];
            range=range+((recording_group-1)*48);

            % in that range, find the smallest waveform
            amps = [];
            for iwaveform = sort(range)
                r = reshape(a_poor_raw_waveform(:,iwaveform,:),[size(a_poor_raw_waveform,1),80]);
                amps = [amps,abs(max(r)-min(r))];

            end
%             lowest = find(amps==min(amps));
%             lowest=lowest(1);
%             highest = find(amps==max(amps));
%             highest=highest(1);

            step = 20; %max(amps)/8;
            ii=1;
            array_temp = [];
            for iwaveform = sort(range)
                r = reshape(a_poor_raw_waveform(:,iwaveform,:),[size(a_poor_raw_waveform,1),80]);
                mm = nanmean(r,1)+step*ii;
                if iwaveform == best_channel
                    plot(mm(15:60),'Color','k','LineWidth',0.9);
    %             elseif ii == highest
    %                 plot(nanmean(r,1)+step*ii,'Color','k','LineWidth',1.1);
                else
                    plot(mm(15:60),'Color',colors(unitType(find(cluster_indices==cell_i))+1),'LineWidth',0.9);
                end
                if isempty(array_temp) == 1
                    array_temp = mm(15:60);
                else
                    array_temp = [mm(15:60);array_temp];
                end
                hold on;
                title(num2str(cell_i));
                ii=ii+1;
            end

            % store the waveforms to plot quicker for the manual check
            if unitType(find(cluster_indices==cell_i)) == 1 || unitType(find(cluster_indices==cell_i)) == 2
                units_good_for_array = [units_good_for_array,cell_i];
                array_waveforms_for_display{1,length(units_good_for_array)} = array_temp;
            elseif unitType(find(cluster_indices==cell_i)) == 0
                units_noise_for_array = [units_noise_for_array,cell_i];
                array_noise_for_display{1,length(units_noise_for_array)} = array_temp;
            end

            iplott=iplott+1;

            types_kept = [types_kept,unitType(find(cluster_indices==cell_i))];

            if iplott > 30

                h=gcf;
                set(h,'PaperOrientation','landscape');
                set(h,'PaperUnits','normalized');
                set(h,'PaperPosition', [0 0 0.9 0.9]);

                print(strcat(plotpath,num2str(ipdf)),'-dpdf');
                ipdf=ipdf+1;
                iplott=1;
                close all;
                figure;
            end

        end
    end
    
    h=gcf;
    set(h,'PaperOrientation','landscape');
    set(h,'PaperUnits','normalized');
    set(h,'PaperPosition', [0 0 0.9 0.9]);

    print(strcat(plotpath,num2str(ipdf)),'-dpdf');
    ipdf=ipdf+1;
    iplott=1;
    close all;

    cd(plotpath);
    save('waveforms_for_manual_check.mat','array_waveforms_for_display','array_noise_for_display','units_good_for_array','units_noise_for_array');

    toc;
    
end
