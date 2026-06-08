

ephysKilosortPath = 'W:\mEC_tau_ephys\mHYK20\110526\concatenated_file'; % like: 'W:\mEC_tau_ephys\mHYK20\110526\concatenated_file'
use_waveforms = 'y';
neuropixelsVersion = 2;
kilosortVersion = 2;
min_spikes = 300;

run_bombcell(ephysKilosortPath, use_waveforms, neuropixelsVersion, kilosortVersion, min_spikes);