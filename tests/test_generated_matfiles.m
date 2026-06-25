


load('D:\Projects\AD\Batch_mEC_ephys\mats\mEC_tau_new_batches\M91_03082024b_489.mat');    

spk_50 = ceil((spikes_stamps/spike_sampling_rate)*pos_sampling_rate);

figure;
tt = 1:length(pos);
% plot(pos,tt,'Color',[0.7,0.7,0.7]);
% hold on;
plot(pos(spk_50), tt(spk_50),'.','MarkerSize',6,'Color','k');
hold on;
xlim([0,track_length]);

%%
load('D:\Projects\AD\Batch_mEC_ephys\mats\mEC_tau_new_batches\M91_03082024c_489.mat');    

spk_50 = ceil((spikes_stamps/spike_sampling_rate)*pos_sampling_rate);

figure;
bin_size_RE = pixels_per_meter*0.02;

pos_map=Location_Map(pos, bin_size_RE);
sp_map=Spike_Map(pos, spk_50, bin_size_RE);

% Generating smoothened rate map using the adaptive smoothing:
% (using the function apply_adaptative_smoothing found in JK matlab folder C:\Programmes_Matlab\Programmes_Matlab_JK_Brain Illustrator\Spatial analysis
[smooth_pos_map, smooth_rate_map_RE]=apply_adaptive_smoothing(pos_map, sp_map, pos_sampling_rate);

Draw_RMap(smooth_rate_map_RE);
axis equal;
set(gca,'YDir','normal');
%%
set(gca, 'XTick', []);
set(gca, 'YTick', []);





