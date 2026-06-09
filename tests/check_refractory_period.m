
i_track = 4;
protocol = string('pC1');
reward = string('fixed');

[mats,smooths,spacells,cell_types,rec_groups,thetaqua,thetafreq,scales,tracks,experiment_refs,mats_RE] = get_data_one_track(i_track, protocol, reward);


refractory_ratio = [];


for celltype_ = [string('BC'),string('GC'),string('HD'),string('CC'),string('SC'),string('PC'),string('IN')] % string('BC'),string('GC'),string('HD'),string('CC'),string('SC'),string('PC')
    
    mats_gridcells =  mats(1,cell_types == celltype_);
    mats_gridcells_RE =  mats_RE(1,cell_types == celltype_);

    disp(celltype_);
    tic;
    for iii = 1:length(mats_gridcells)

        % calculate the refracty ratio on an example cell
        load(strcat('D:\Cells\Error_correction\new_mat_files_pC1_npix_samedelay\',mats_gridcells(1,iii)));

        s1=spikes_stamps/spike_sampling_rate;
        trial_duration1 = length(pos)/pos_sampling_rate;

        clear pos spikes_stamps;

        load(strcat('D:\Cells\Error_correction\new_mat_files_pC1_npix_samedelay\',mats_gridcells_RE(1,iii)));

        s2=(spikes_stamps/spike_sampling_rate)+trial_duration1;
%         trial_duration2 = length(pos)/pos_sampling_rate;

        clear pos spikes_stamps;
        
        s3 = [s1',s2'];
        windw=10;
        if length(s3) > 50000
            s3 = s3(1:50000);
        end
        [bins counts] = interspike_histogram(s3',s3', windw); 
    %     bh=bar(bins,sum(counts,1));
    %     hold on;
    %     bh.FaceColor='k';
    %     bh.FaceAlpha=0.6;
    %     bh.EdgeColor='k';
    %     bh.EdgeAlpha=0.4;
    %     ylabel('count');
    %     box off;


        % The refractory period ratio was calculated from the spike-time autocorrelation from 0ms to 10ms 
        % with a bin width of 0.5ms. The refractory period ratio was defined as the mean number of spikes in bins from 0?ms to 1.5?ms, 
        % divided by the maximum number of spikes in any bin between 5?ms and 15?ms. 
        m1 = sum(counts(bins>=0 & bins<=1.5));
        m2 = length(s3);%max(counts(bins>10 & bins<=20));
        refractory_ratio = [refractory_ratio,m1/m2];
        %disp((m1/m2(1))*100);
        clear m1 m2;
        close all;


    end
    disp(max(refractory_ratio));
    toc;
end
save('D:\Projects\Manipulating Visual Cues\Field Formation\Figures article\thirty_fourth_draft\refractory_period\refractory_ratio_all_cell_types.mat','refractory_ratio');

%% 
% a = load('D:\Projects\Manipulating Visual Cues\Field Formation\Figures article\thirty_fourth_draft\refractory_period\refractory_ratio.mat');
% b = load('D:\Projects\Manipulating Visual Cues\Field Formation\Figures article\thirty_fourth_draft\refractory_period\refractory_ratio_IN.mat');
% 


