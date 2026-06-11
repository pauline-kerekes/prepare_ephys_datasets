
function run_bombcell(ephysKilosortPath, use_waveforms, neuropixelsVersion, kilosortVersion, min_spikes)

    if use_waveforms == 'y'
       ephysRawFile = strcat(ephysKilosortPath,'\spikes_combi.bin') ; % cell selection will be based on waveforms
    else
       ephysRawFile = 'NaN'; % cell selection will be based on templates
    end
    
    % W:\mEC_tau_ephys\mHYK20\200326\concatenated_file\manual_firstpart
    if ~exist(strcat(ephysKilosortPath,'\manual_firstpart\cell_list_kilo2.xlsx'),'file')
        
        %% run bombcell 
        tic;
        ephysMetaDir = []; % for the concatenated file we don't have 
        % if you put [] for the ephysMetaDir then you have to make sure that the
        % neuropixels version in qualityParamValue  (Neuropixels 2.0. or 1.0.)
        savePath = [ephysKilosortPath  filesep 'bombcell']; % where you want to save the quality metrics 
        gain_to_uV = NaN; % use this if you are not using spikeGLX or openEphys to record your data. this value, 
        % when mulitplied by your raw data should convert it to  microvolts. 

        [spikeTimes_samples, spikeClusters, templateWaveforms, templateAmplitudes, pcFeatures, ...
         pcFeatureIdx, channelPositions] = bc.load.loadEphysData(ephysKilosortPath, savePath);

        param = bc.qm.qualityParamValues(ephysMetaDir, ephysRawFile, ephysKilosortPath, gain_to_uV, kilosortVersion, neuropixelsVersion, min_spikes);
        
        % adding some parameters specific to neuropixels recordings
        param.nChannels = 385;
        param.nSyncChannels = 1;
        param.ephys_sample_rate = 30000; % default, 30000 samples / s. 
        nb_channels = 384; % acquisition channels only
        %

        [qMetric, unitType] = bc.qm.runAllQualityMetrics(param, spikeTimes_samples, spikeClusters, ...
                templateWaveforms, templateAmplitudes, pcFeatures, pcFeatureIdx, channelPositions, savePath);

        % save the units classification and metrics
        cd(strcat(ephysKilosortPath,'\bombcell'));
        parquetwrite([fullfile(savePath, 'qmetrics_pk.parquet')], qMetric);
        save([fullfile(savePath, 'units_classification_pk.mat')], 'unitType');
        toc;

        %% plot the waveforms classified as 'good' (in green),  'axonal' (black) or 'noise' (red)
        tic;
        plot_waveforms_after_bombcell(ephysKilosortPath, nb_channels, min_spikes);
        toc;

 
    else
        disp('the cells have been selected for that session');

    end



end