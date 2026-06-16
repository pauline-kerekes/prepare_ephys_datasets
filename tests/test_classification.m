

%% from one cell (properties stored in a lighter mat file)
load('H:\mEC_tau_new_batches_test\M102_11052026b_28');
m_per_bin = 0.02;
[BC_score,GC_score,SI_score,HD_score,cell_type,smooth_r_map] = get_cell_RE_classification(pos,dir_head,spikes_stamps,spike_sampling_rate,pos_sampling_rate,implant_loc_1,pixels_per_meter,m_per_bin);

disp(SI_score);
figure;
Draw_RMap(smooth_r_map);
srm = ones(size(smooth_r_map));
disp(sum(smooth_r_map<0.1*(max(max(smooth_r_map))-min(min(smooth_r_map))),'all')/sum(srm,'all'));
[B,L] = bwlabel(smooth_r_map<0.1*(max(max(smooth_r_map))-min(min(smooth_r_map))));
disp(L);
srm=smooth_r_map;
srm(srm<0.1*(max(max(smooth_r_map))-min(min(smooth_r_map))))=0;
srm(srm>=0.1*(max(max(smooth_r_map))-min(min(smooth_r_map))))=1;
figure;
imagesc(srm);

%% from a folder
% 
figure;
plotpath = 'D:\Projects\Checks_and_Generalities\checking_analysis_programs\Tests\test_classification_spatial_cells\'; %'C:\Work\test_SI_score\';
iplot=1;
ipdf=1;
cd('D:\Projects\AD\Batch_mEC_ephys\mats\mEC_tau_new_batches_test');
d = dir('D:\Projects\AD\Batch_mEC_ephys\mats\mEC_tau_new_batches_test');
for ii = 1:length(d)
    disp(d(ii).name);
    if contains(d(ii).name,string('.mat')) && ~contains(d(ii).name,string('a_'))
        load(d(ii).name);
        if isempty(dir_head) == 0
            subplot(5,5,iplot);
            m_per_bin = 0.02;
            [BC_score,GC_score,SI_score,HD_score,cell_type,smooth_r_map] = get_cell_RE_classification(pos,dir_head,spikes_stamps,spike_sampling_rate,pos_sampling_rate,implant_loc_1,pixels_per_meter,m_per_bin);
            Draw_RMap(smooth_r_map);
%             title(strcat(num2str(SI_score),'|',num2str(length(spikes_stamps))));
%             title(d(ii).name);
            srm = ones(size(smooth_r_map));
            s = sum(smooth_r_map<0.15*(max(max(smooth_r_map))-min(min(smooth_r_map))),'all')/sum(srm,'all');
            if s>0.4 && (max(max(smooth_r_map))/min(min(smooth_r_map)))>20
                title('YES','Color','g');
            else
                title('no');
            end
%             title(strcat(num2str((max(max(smooth_r_map))/min(min(smooth_r_map)))),'||',num2str(round(s,2))));
            
            iplot=iplot+1;
            
            if iplot > 25
                h=gcf;
                set(h,'PaperOrientation','landscape');
                set(h,'PaperUnits','normalized');
                set(h,'PaperPosition', [0 0 0.9 0.9]);

                print(strcat(plotpath,num2str(ipdf)),'-dpdf');
                ipdf=ipdf+1;
                iplot=1;
                close all;
                figure;

            end
        end
    end
end

h=gcf;
set(h,'PaperOrientation','landscape');
set(h,'PaperUnits','normalized');
set(h,'PaperPosition', [0 0 0.9 0.9]);

print(strcat(plotpath,num2str(ipdf)),'-dpdf');