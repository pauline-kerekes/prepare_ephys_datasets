function array_LFP_aligned = align_LFP_with_pos_file_2_aug2023(folder_name,array_LFP_non_aligned,pos_file,pos,rec_type,sampling_rate_ephys,sampling_rate_position,sampling_rate_LFP,delay)

    % change on 160924: I put the delay value in the input.
    % the delay in the input of this function should be expressed is
    % seconds.

%     just_delay = 'y';
%     [delay_VE,delay_RE, spikes_aligned_50_RE, spikes_aligned_50_VE, spikes_aligned_30K_VE,spikes_aligned_30K_RE, clusters_VE, clusters_RE] = get_alignment_VE_and_RE_for_spikes_2(animalID, session, RE_recording_number, rec_state, just_delay);
%     

    %%
    % before 160924: we were calculating the delay with the block below
%     if size(array_LFP_non_aligned,1) <  65 %==64 || size(array_LFP_non_aligned,1)==32 
%         disp('TETRODE DATA');
%         [delay] = get_delay_openephys(folder_name,pos_file,rec_type,sampling_rate_ephys); % for tetrode data
%     else
%         delay = 0; % for neuropixels data, the ephys starts when the pos rec starts, so no delay. 
%     end
    %%
    
%     cd(folder_result);
%     
%     file_LFP_merged = string('mergedLFP.bin');
%     
%     result_file_2 = fopen(string(file_LFP_merged));
%     
%     array_tmp = fread(result_file_2,'*int16','ieee-le');
%     size_chunk_per_channel = length(array_tmp)/nb_channels;
%     
%     fclose('all');
%     
%     result_file_2 = fopen(file_LFP_merged);
%     disp('size LFP total');
%     disp(result_file_2);
%     array_LFP_non_aligned= fread(result_file_2,[nb_channels size_chunk_per_channel],'*int16','ieee-le');


%     if rec_type == string('VE');
%         delay = delay_VE;
%     else
%         delay = delay_RE;
%     end
      
    %%
    % was like that before 160924 and I changed it to work with delay
    % expressed in seconds
    % start_signal_aligned = ceil((delay/sampling_rate_ephys)*sampling_rate_LFP); % delay is in samples at 30KHz, and i am converting it to 3KHz
    % new line:
    start_signal_aligned = ceil(delay*sampling_rate_LFP); % delay is in seconds, and i am converting it to 3KHz
    %%
    
    l_pos = max(size(pos));
   
    stop_signal_aligned = start_signal_aligned + ceil((l_pos/sampling_rate_position)*sampling_rate_LFP); % pos is in samples at 50Hz, and i am converting it to 3KHz
    
%     disp(size_chunk_per_channel);
%     disp(start_signal_aligned);
%     disp(stop_signal_aligned);
%     
    array_LFP_aligned = [];
%     disp('posfile name');
%     disp(pos_file);
%     disp('where');
%     disp(folder_result);
%     disp('start and stop of posfile alignment');
%     disp(start_signal_aligned);
%     disp(stop_signal_aligned);
%     disp('size LFP non aligned');
%     disp(size(array_LFP_non_aligned));
    

    if start_signal_aligned == 0
        start_signal_aligned = 1;
    end
    
    
    if size(array_LFP_non_aligned,1) > 65
        %% added because of problem of ephys crashing before pos
        if size(array_LFP_non_aligned,2) < stop_signal_aligned - start_signal_aligned
            array_LFP_aligned = zeros(size(array_LFP_non_aligned,1),stop_signal_aligned-start_signal_aligned);
        else  
        %% 
            array_LFP_aligned=array_LFP_non_aligned(:,start_signal_aligned:stop_signal_aligned);
        end
    else
 
        for line = 1:size(array_LFP_non_aligned,1)
            disp('size');
            disp(size(array_LFP_non_aligned));
            disp(start_signal_aligned);
            disp(stop_signal_aligned);
            if start_signal_aligned==0
                start_signal_aligned=1;
            end
            array_LFP_aligned = [array_LFP_aligned ; array_LFP_non_aligned(line,start_signal_aligned:stop_signal_aligned)];

        end
        
    end
    
    
    
end




