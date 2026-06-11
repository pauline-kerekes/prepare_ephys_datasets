
%%
for pathdata = [string('260326'),string('270326'),string('280326'),string('290326'),string('300326'),string('310326'),string('010426'),string('020426'),string('030426')]
    
    ephysKilosortPath = char(strcat('W:\mEC_tau_ephys\mHYK20\',pathdata,'\concatenated_file')); % like: 'W:\mEC_tau_ephys\mHYK20\110526\concatenated_file'
    use_waveforms = 'n';
    neuropixelsVersion = 2;
    kilosortVersion = 2;
    min_spikes = 300;

    run_bombcell(ephysKilosortPath, use_waveforms, neuropixelsVersion, kilosortVersion, min_spikes);
    
end
%%
%     ephysKilosortPath = 'W:\mEC_tau_ephys\mHYK20\150326\concatenated_file'; % like: 'W:\mEC_tau_ephys\mHYK20\110526\concatenated_file'
%     use_waveforms = 'n';
%     neuropixelsVersion = 2;
%     kilosortVersion = 2;
%     min_spikes = 300;
% 
%     run_bombcell(ephysKilosortPath, use_waveforms, neuropixelsVersion, kilosortVersion, min_spikes);


% string('150326'),string('160326'),string('170326'),string('180326'),