

ephysKilosortPath = 'W:\mEC_tau_ephys\mHYK20\110526\concatenated_file';
cd(strcat(ephysKilosortPath,'\bombcell'));
qMetric = parquetread('qmetrics_pk.parquet');

cluster_indices = qMetric{:,["phy_clusterID"]};
qMetric(find(cluster_indices==159),:);

load('units_classification_pk.mat', 'unitType');

num = xlsread(strcat(ephysKilosortPath,'\manual_firstpart\cell_list_kilo2.xlsx'));

npy_spike_clusters = readNPY(strcat(ephysKilosortPath,'\spike_clusters.npy'));
npy_spike_times = readNPY(strcat(ephysKilosortPath,'\spike_times.npy'));

refractory_ratio = [];
unit_types = [];
for cell_i = num'

    spikes_stamps = double(npy_spike_times(npy_spike_clusters==cell_i)); 
    s1=spikes_stamps/30000;
    
    windw=10;
    if length(s1) > 50000
        s1 = s1(1:50000);
    end
%     [bins counts] = interspike_histogram(s1',s1', windw); 
%     bh=bar(bins,sum(counts,1));
%     hold on;
%     bh.FaceColor='k';
%     bh.FaceAlpha=0.6;
%     bh.EdgeColor='k';
%     bh.EdgeAlpha=0.4;
%     ylabel('count');
%     box off;
%     ax = gca;
%     ax.FontSize = 14; % Set font size to 14 points


    % The refractory period ratio was calculated from the spike-time autocorrelation from 0ms to 10ms 
    % with a bin width of 0.5ms. The refractory period ratio was defined as the mean number of spikes in bins from 0?ms to 1.5?ms, 
    % divided by the maximum number of spikes in any bin between 5?ms and 15?ms. 
    m1 = sum(counts(bins>=0 & bins<=2));
    m2 = length(s1);%max(counts(bins>10 & bins<=20));
    refractory_ratio = [refractory_ratio,m1/m2];
    unit_types = [unit_types,unitType(find(cluster_indices==cell_i))];

end


figure;
subplot(2,2,1);
hist(refractory_ratio(unit_types==2).*100,0:0.01:0.8);
hold on;
xlim([0,0.6]);
xlabel('% spikes in [0,2ms]');
ylabel ('N MUA units');


subplot(2,2,2);
hist(refractory_ratio(unit_types==1).*100,0:0.01:0.8);
hold on;
xlim([0,0.6]);
xlabel('% spikes in [0,2ms]');
ylabel ('N single cells');


