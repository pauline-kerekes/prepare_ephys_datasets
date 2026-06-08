
tic;
% parameters for the concatenated file:
% (the commented parts were for a single recording (a screening)
toy_dataset_location = 'D:\mHYK20\180426\a_shankmix1_18042026_g0__b_shankmix1_18042026_g0'; %'D:\a_shank0_10032026_g0'; %
ephysKilosortPath = toy_dataset_location;
ephysRawFile = strcat(toy_dataset_location,'\spikes_combi.bin') ; %'NaN';  % path to your raw .bin or .dat data
ephysMetaDir = [];% dir(strcat(toy_dataset_location,'\a_shank0_10032026_g0_t0.imec0.ap.meta')); %dir([toy_dataset_location '*ap*.*meta']); % path to your .meta or .oebin meta file
% if you put [] for the ephysMetaDir then you have to make sure that the
% neurpixels version in qualityParamValue  (Neuropixels 2.0. or 1.0.)
savePath = [ephysKilosortPath  filesep 'bombcell']; % where you want to save the quality metrics 
% 'C:\Work\bombcell\';
neuropixelsVersion = 2;
kilosortVersion = 2; % if using kilosort4, you need to have this value kilosertVersion=4. Otherwise it does not matter. 
gain_to_uV = NaN; % use this if you are not using spikeGLX or openEphys to record your data. this value, 
% when mulitplied by your raw data should convert it to  microvolts. 

[spikeTimes_samples, spikeClusters, templateWaveforms, templateAmplitudes, pcFeatures, ...
 pcFeatureIdx, channelPositions] = bc.load.loadEphysData(ephysKilosortPath, savePath);

param = bc.qm.qualityParamValues(ephysMetaDir, ephysRawFile, ephysKilosortPath, gain_to_uV, kilosortVersion,neuropixelsVersion);

param.nChannels = 385;
param.nSyncChannels = 1;

% if using SpikeGLX, you can use this function: 
% PK: the parameters stated above are the correct ones
% if ~isempty(ephysMetaDir)
%     if endsWith(ephysMetaDir.name, '.ap.meta') %spikeGLX file-naming convention
%         meta = bc.dependencies.SGLX_readMeta.ReadMeta(ephysMetaDir.name, ephysMetaDir.folder);
%         [AP, ~, SY] = bc.dependencies.SGLX_readMeta.ChannelCountsIM(meta);
%         param.nChannels = AP + SY;
%         param.nSyncChannels = SY;
%     end
% end

% additionally, if you are using non-neuropixels probe, check the ephys
% sampling rate if correct:
param.ephys_sample_rate = 30000; % default, 30000 samples / s. 

[qMetric, unitType] = bc.qm.runAllQualityMetrics(param, spikeTimes_samples, spikeClusters, ...
        templateWaveforms, templateAmplitudes, pcFeatures, pcFeatureIdx, channelPositions, savePath);
toc;

cd(strcat(toy_dataset_location,'\bombcell'));

parquetwrite([fullfile(savePath, 'qmetrics_pk.parquet')], qMetric);
save([fullfile(savePath, 'units_classification_pk.mat')], 'unitType');

cluster_indices = qMetric{:,["phy_clusterID"]};
best_channels_bombcell = qMetric{:,["maxChannels"]};

%% now plot the mean waveforms independently and check that the unit assignment is 
%% correct.
tic;
% load the data
toy_dataset_location = 'D:\mHYK20\180426\a_shankmix1_18042026_g0__b_shankmix1_18042026_g0'; %'D:\a_shank0_10032026_g0'; %
cd(strcat(toy_dataset_location,'\bombcell'));
qMetric = parquetread('qmetrics_pk.parquet');
cluster_indices = qMetric{:,["phy_clusterID"]};
best_channels_bombcell = qMetric{:,["maxChannels"]};
load('units_classification_pk.mat', 'unitType');


colors = ['r','g','g','k'];
types_kept = [];
path_to_data = strcat('D:\mHYK20\180426\a_shankmix1_18042026_g0__b_shankmix1_18042026_g0\');%strcat('D:\a_shank0_10032026_g0\');
nb_channels = 384;

plotpath = 'D:\mHYK20\180426\a_shankmix1_18042026_g0__b_shankmix1_18042026_g0\waveforms_check\';% 'D:\a_shank0_10032026_g0\waveforms_check\';
if ~exist(plotpath)
    mkdir(plotpath);
end
% cd(strcat(path_to_data,'\manual_firstpart'));

%npy_spike_clusters = readNPY(strcat(path_to_data,'manual_firstpart\spike_clusters_amp_2023-10-14_12-39-59.npy'));% readNPY(strcat(path_to_data,'\manual_firstpart\spike_clusters_amp_2024-03-18_15-11-10.npy'));
npy_spike_clusters = readNPY(strcat(path_to_data,'spike_clusters.npy'));
npy_spike_times = readNPY(strcat(path_to_data,'spike_times.npy'));

% path_to_cluster_list_match = strcat(path_to_data,'\manual_firstpart\cell_list_kilo2.xlsx');
% [cluster_list_after_manual_cutting,cluster_list_after_kilo] = get_cluster_list_from_auto_to_manual(path_to_cluster_list_match);

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

    
    if length(spk_stamps_notaligned_inconcat) >= 300
        spikes_for_wf = randperm(length(spk_stamps_notaligned_inconcat),200);
    
    else % less than 300 spikes, do not take for the analysis
        plot_go = 'n';
    end

    if plot_go == 'y' %&& unitType(find(cluster_indices==cell_i))~=0 && unitType(find(cluster_indices==cell_i))~=3

        %spikes_for_wf = 200:400;

        a_poor_raw_waveform = zeros(length(spikes_for_wf),nb_channels,80); 

        % opening the file to extract the waveforms from
        raw_file_with_all_the_data = fopen(strcat(path_to_data,'spikes_combi.bin'));
        %raw_file_with_all_the_data = fopen(strcat(path_to_data,'merged.bin'));


        ispiketoadd=1;

        for ispike = spikes_for_wf %2:n_spikes-1 % was 2:n_spikes-1 before 081124
            fseek(raw_file_with_all_the_data , (spk_stamps_notaligned_inconcat(ispike)-30)*nb_channels*2, 'bof');
            a_poor_raw_waveform(ispiketoadd,:,:) = fread(raw_file_with_all_the_data, [nb_channels, 80], '*int16');
            ispiketoadd=ispiketoadd+1;
        %                             fseek(raw_file_with_all_the_data , (spk_stamps_notaligned_inconcat_forwf(ispike)-30)*nb_channels*2, 'bof');
        %                             a_poor_raw_waveform(ispike,:,:) = fread(raw_file_with_all_the_data, [nb_channels, 80], '*int16');
        end

    % end

%         amp_all = [];
%         best_channels = [];
% 
%         for recording_group_i = 1:8
% 
%             w = a_poor_raw_waveform(:,(recording_group_i*48)-47:(recording_group_i*48),:);
% 
%             list_channels = (recording_group_i*48)-47:(recording_group_i*48);
%             amplitudes_per_recording_group = [];
% 
%             for ichannel = 1:size(w,2)
% 
%                 r = reshape(w(:,ichannel,:),[size(w,1),80]);
%                 amplitude = abs(max(max(nanmean(r,1)))-min(min(nanmean(r,1))));
% 
%                 amplitudes_per_recording_group = [amplitudes_per_recording_group, amplitude];
% 
% 
%         %         if recording_group_i == 3
%         %             disp(recording_group_i);
%         %             mean_r = nanmean(r,1);
%         %             [width_waveform,repolarisation_time] = get_waveform_width(mean_r);
%         %             widths = [widths,width_waveform];
%         % 
%         %             disp(width_waveform);
%         %             disp(amplitude);
%         %             disp('###');
%         %             
%         %             amplitudes = [amplitudes,amplitude(1)];
%         %             
%         %             subplot(6,8,iplot);
%         %             plot(nanmean(r,1));
%         %             hold on;
%         %             title(num2str(list_channels(ichannel)));
%         %             iplot = iplot+1;
%         %             
%         %         end
% 
%             end
% 
%             amplitudes_per_recording_group(amplitudes_per_recording_group>600) = NaN;
% 
%             amp_all = [amp_all,max(max(amplitudes_per_recording_group))];
% 
%             best_channels = [best_channels,list_channels(find(amplitudes_per_recording_group==max(max(amplitudes_per_recording_group))))];

%         end

        %best_channel = best_channels(1,find(amp_all==max(max(amp_all))));
        best_channel = best_channels_bombcell(find(cluster_indices==cell_i));
        
        subplot(5,6,iplott);
        
        % toplot just the average waveform on the best channel
%         r = reshape(a_poor_raw_waveform(:,best_channel,:),[size(a_poor_raw_waveform,1),80]);
%         plot(nanmean(r,1),'Color',colors(unitType(find(cluster_indices==cell_i))+1),'LineWidth',1.6);
%         hold on;
%         title(strcat(num2str(cell_i),'-',num2str(unitType(find(cluster_indices==cell_i))),'-',num2str(length(spk_stamps_notaligned_inconcat))));
%         iplott = iplott+1;
        
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
        lowest = find(amps==min(amps));
        lowest=lowest(1);
        highest = find(amps==max(amps));
        highest=highest(1);
        
        step = max(amps)/8;
        ii=1;
        array_temp = [];
        for iwaveform = sort(range)
            r = reshape(a_poor_raw_waveform(:,iwaveform,:),[size(a_poor_raw_waveform,1),80]);
            mm = nanmean(r,1)+step*ii;
            if iwaveform == best_channel
                plot(mm(15:60),'Color',colors(unitType(find(cluster_indices==cell_i))+1),'LineWidth',1.4);
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
        
        % store the waveforms
        if unitType(find(cluster_indices==cell_i)) == 1 || unitType(find(cluster_indices==cell_i)) == 2
            units_good_for_array = [units_good_for_array,cell_i];
            array_waveforms_for_display{1,length(units_good_for_array)} = array_temp;
        elseif unitType(find(cluster_indices==cell_i)) == 0
            units_noise_for_array = [units_noise_for_array,cell_i];
            array_noise_for_display{1,length(units_noise_for_array)} = array_temp;
        end
        
        iplott=iplott+1;
        
%         subplot(5,6,iplott);
%         windw = 500; % ms
%         spike_times = double(spk_stamps_notaligned_inconcat)/30000;
%         if length(spike_times) >= 1000
%             [bins counts] = interspike_histogram(spike_times(end-1000:end),spike_times(end-1000:end), windw); % was 100
%         else
%             [bins counts] = interspike_histogram(spike_times,spike_times, windw); % was 100
%         end
%         
%         bh=bar(bins,sum(counts,1));
%         hold on;
%         bh.FaceColor='k';
%         bh.FaceAlpha=0.6;
%         bh.EdgeColor='k';
%         bh.EdgeAlpha=0.4;
% 
%         iplott=iplott+1;

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
% disp(length(find(types_kept==1))+length(find(types_kept==2)));
% disp(length(find(types_kept==0)));


%% compare properties
% 725 (not good) and 726 (good)

% cluster_indices = qMetric{:,["phy_clusterID"]};
%qMetric(find(cluster_indices==725),:)
% qMetric(find(cluster_indices==1573),:)

% decay_slope_values = qMetric{:,["spatialDecaySlope"]};
% df = find(unitType==0);
% decay_slope_values_noise = decay_slope_values(df);
% figure;
% hist(decay_slope_values_noise,0:0.01:0.2);
% hold on;
% 


%% experimentalist manual check
% load the data
tic;
toy_dataset_location = 'D:\mHYK20\180426\a_shankmix1_18042026_g0__b_shankmix1_18042026_g0'; %'D:\a_shank0_10032026_g0'; %
cd(strcat(toy_dataset_location,'\bombcell'));
qMetric = parquetread('qmetrics_pk.parquet');
cluster_indices = qMetric{:,["phy_clusterID"]};
best_channels_bombcell = qMetric{:,["maxChannels"]};
load('units_classification_pk.mat', 'unitType');

load(strcat(toy_dataset_location,'\waveforms_check\waveforms_for_manual_check.mat'),'array_waveforms_for_display','units_good_for_array');

cells_to_remove = [];
all_cells = [];

colors = ['r','g','g','k'];
types_kept = [];
path_to_data = strcat('D:\mHYK20\180426\a_shankmix1_18042026_g0__b_shankmix1_18042026_g0\');%strcat('D:\a_shank0_10032026_g0\');
nb_channels = 384;


figure;
iplott = 1;
ipdf = 1;
for cell_i = 1:length(array_waveforms_for_display)%1:max(npy_spike_clusters)%1:1593 %cluster_list_after_manual_cutting

    if isempty([array_waveforms_for_display{1,cell_i}]) == 0
    
        h3=subplot(4,4,iplott);
%         set(h3, 'Units', 'normalized');
%         set(h3, 'Position', [0, .55, .8, .2]);               
        % in that range, find the smallest waveform
        array_wf = [array_waveforms_for_display{1,cell_i}];
        for iwaveform = 1:size(array_wf,1)
            plot(array_wf(iwaveform,:),'Color','g','LineWidth',0.8);
            hold on;
            yticks([]);
            xticks([]);
            title(num2str(units_good_for_array(1,cell_i)));
        end
        iplott=iplott+1;
        
        all_cells = [all_cells,cell_i];
        
        if iplott > 16
%             prompt = " cells to remove? 1=yes; 0=no";
%             value_field = input(prompt);
%             
%             if value_field == 1
                prompt = " which cells please? (put a list of numbers in the form [1,2,4]";
                value_field2 = input(prompt);
                cells_to_remove = [cells_to_remove,value_field2];
%             end
                            
            iplott=1;
            close all;
            figure;
            
        end

    else
        break;
    end
end
toc;

%% do the same for the noise

tic;
toy_dataset_location = 'D:\mHYK20\180426\a_shankmix1_18042026_g0__b_shankmix1_18042026_g0'; %'D:\a_shank0_10032026_g0'; %
cd(strcat(toy_dataset_location,'\bombcell'));
qMetric = parquetread('qmetrics_pk.parquet');
cluster_indices = qMetric{:,["phy_clusterID"]};
best_channels_bombcell = qMetric{:,["maxChannels"]};
load('units_classification_pk.mat', 'unitType');

load(strcat(toy_dataset_location,'\waveforms_check\waveforms_for_manual_check.mat'),'array_noise_for_display','units_noise_for_array');

cells_to_remove = [];
all_cells = [];

colors = ['r','g','g','k'];
types_kept = [];
path_to_data = strcat('D:\mHYK20\180426\a_shankmix1_18042026_g0__b_shankmix1_18042026_g0\');%strcat('D:\a_shank0_10032026_g0\');
nb_channels = 384;


figure;
iplott = 1;
ipdf = 1;
for cell_i = 1:length(array_waveforms_for_display)%1:max(npy_spike_clusters)%1:1593 %cluster_list_after_manual_cutting

    if isempty([array_waveforms_for_display{1,cell_i}]) == 0
    
        h3=subplot(4,4,iplott);
%         set(h3, 'Units', 'normalized');
%         set(h3, 'Position', [0, .55, .8, .2]);               
        % in that range, find the smallest waveform
        array_wf = [array_waveforms_for_display{1,cell_i}];
        for iwaveform = 1:size(array_wf,1)
            plot(array_wf(iwaveform,:),'Color','g','LineWidth',0.8);
            hold on;
            yticks([]);
            xticks([]);
            title(num2str(units_good_for_array(1,cell_i)));
        end
        iplott=iplott+1;
        
        all_cells = [all_cells,cell_i];
        
        if iplott > 16
%             prompt = " cells to remove? 1=yes; 0=no";
%             value_field = input(prompt);
%             
%             if value_field == 1
                prompt = " which cells please? (put a list of numbers in the form [1,2,4]";
                value_field2 = input(prompt);
                cells_to_remove = [cells_to_remove,value_field2];
%             end
                            
            iplott=1;
            close all;
            figure;
            
        end

    else
        break;
    end
end
toc;


