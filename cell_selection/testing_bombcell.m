

toy_dataset_location = 'D:\mHYK20\180426\a_shankmix1_18042026_g0__b_shankmix1_18042026_g0';
ephysKilosortPath = toy_dataset_location;
ephysRawFile = 'NaN'; % path to your raw .bin or .dat data
ephysMetaDir = dir([toy_dataset_location '*ap*.*meta']); % path to your .meta or .oebin meta file
savePath = [ephysKilosortPath  filesep 'bombcell']; % where you want to save the quality metrics 

kilosortVersion = 2; % if using kilosort4, you need to have this value kilosertVersion=4. Otherwise it does not matter. 
gain_to_uV = NaN; % use this if you are not using spikeGLX or openEphys to record your data. this value, 
% when mulitplied by your raw data should convert it to  microvolts. 

[spikeTimes_samples, spikeClusters, templateWaveforms, templateAmplitudes, pcFeatures, ...
 pcFeatureIdx, channelPositions] = bc.load.loadEphysData(ephysKilosortPath, savePath);