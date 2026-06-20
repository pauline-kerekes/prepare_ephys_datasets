
function store_variables_neuropixels_from_010326_fct(path_to_raw_data,session,animalID,part,VE_recording_number,cut,mapping_spreadsheet,version_npix,shankmix,folder_to_store_the_LFP,folder_to_store_the_mats,folder_to_store_the_mats2,n_pixels_per_meter,exp_location)

    % updates on that program (120924): 
    % - I add an option to choose if we read cluster
    % indices from the manual cut file or from the 'before manual cut' file
    % (the var 'cut' in the function inputs)
    
    % - I put the folder to store the mats in the function inputs.
    
    % - the version of the neuropixels probes (4shanks): if it's version 2
    % then the delay between ephys and pos tracking is non zero so then we
    % have to remove the negative spike time values after substracting the
    % delay.

    % added also the folder where to store the LFP in the function inputs
    
    % 010326: I simplify the number of inputs to the function (compared to
    % the version on the 081124

    %% CAREFUL track_length and  HARDCODED

    %% GENERAL PARAMETERS PLEASE DOUBLE CHECK
    
    track_length_VE = 400; %  CHECK
%     pixels_per_meter_RE = 530; %  CHECK
    
    cm_per_bin_VE = 5;
    lick_sampling_rate=50;
    spike_sampling_rate=30000;
    pos_sampling_rate=50;
    LFP_sampling_rate = 3000;
    nb_channels=384; %384 if neuropixels, 32 or 64 if tetrodes
    version_kilosort=2;
    implant_loc_1=string('mEC');
    implant_loc_2=[];

    %% this section below is to find the folder where the data is. You can either replace it by your own functions to find folders or you can fill in manually the two variables concatenated_folder and animal_folder_

%     %project='Manipulating Visual Cues';
%     [mouse_index,mouse_batch,mouse_implant,reward_type] = get_animal_specs(animalID);
%     [path_to_data] = get_data_location_2(animalID,session,mouse_batch,project);
%     concatenated_folder = fullfile(strcat(path_to_data,'concatenated_file\')); 
%     cff=char(concatenated_folder);
%     %concatenated_folder=strcat('J:\Data\Manipulating Visual Cues\Batch_19\',animalID,'\',session,'\concatenated_file');
%     %animal_folder_=strcat(cff(1),':\Data\Manipulating Visual Cues\Batch_19\',animalID,'\',session);
%     animal_folder_=strcat(path_to_data);
    
    
    [animal_index, mouse_batch, mouse_implant, reward_pos] = get_animal_specs(animalID); 
    
    animal_folder_ = strcat(path_to_raw_data,animalID,'\',session,'\');
    if exp_location == string('Cambridge')
        [folder_names,pos_files,list_letter_recording,RE_recording_number] =get_folder_names_feb26_older_batches(animal_folder_, VE_recording_number);
    elseif exp_location == string('London')
        [folder_names,pos_files,list_letter_recording,RE_recording_number] = get_folder_names_feb26(animal_folder_, VE_recording_number);
    else
        disp('experiments location: cambridge or london?');
        keyboard;
    end
    %[folder_names,pos_files,list_letter_recording,RE_recording_number] = get_folder_names_feb26(animal_folder_, VE_recording_number);
%     [folder_names,pos_files,list_letter_recording,RE_recording_number] =get_folder_names_feb26_older_batches(animal_folder_, VE_recording_number);

    concatenated_folder = get_concatenated_folder(animal_folder_);
    %concatenated_folder = strcat(animal_folder_,'concatenated_file\'); 

    %%
    
    M_tmp=load(strcat(concatenated_folder,'\spikes_combi_meta.mat')); 

    M=M_tmp.M;
    M.combi.folder=concatenated_folder;
    M.animal_folder=animal_folder_;
    cd(M.combi.folder);

    %% function to separate individual recordings from neuropixels

    if cut == 'y'
        t=separate_combined_trial_data_pk_vr_select_folder_aft_2(M,part);
    elseif cut == 'n'
        t=separate_combined_trial_data_pk_vr_select_folder_bef(M,part);
    else
        disp('please choose if you want to read the cluster list from before or after manual cutting');
    end
    %%

    %% getting the trial limits in the raw data file. Will be used to find the waveforms later in this program.
    n_samples_trial = cellfun(@(A)A.bytes/2/M.n_channels_rec, {M.trial.datafile_dir}, 'Uni', 1);
    csum_n_spikes = cumsum(n_samples_trial);
    %%


    if part == 1 
        %folder_to_store_the_mats = strcat('D:\Cells\Error_correction\Error_correction_mat_files_tmp_2parts\part1\'); % dont indicate if thats bfore or after manual here
        path_to_cluster_list_match = strcat(concatenated_folder,'\manual_firstpart\cell_list_kilo2.xlsx');

    elseif part == 2
        %folder_to_store_the_mats = strcat('D:\Cells\Error_correction\Error_correction_mat_files_tmp_2parts\part2\'); 
        path_to_cluster_list_match = strcat(concatenated_folder,'\manual_secondpart\cell_list_kilo2_part2.xlsx');

    else
        disp('choose which part of the session you want');
        pause;
    end

    [cluster_list_after_manual_cutting,cluster_list_after_kilo] = get_cluster_list_from_auto_to_manual2(path_to_cluster_list_match);
    % [cluster_list_after_manual_cutting,cluster_list_after_kilo] = get_cluster_list_from_auto_to_manual(path_to_cluster_list_match);

    mouse=strcat('M',num2str(animal_index));
    [general_mapping_NPX20, mapping_session] = get_probe_mapping_npixels_2(animalID, shankmix, mapping_spreadsheet);

    if cut == 'y'
        cells_to_store = cluster_list_after_manual_cutting; %cluster_list_after_kilo;
    elseif cut == 'n'
        cells_to_store = cluster_list_after_kilo; %cluster_list_after_kilo;
    else
        disp('please choose if you want to read the cluster list from before or after manual cutting');
    end


    
    
    for n_trial=1:length(list_letter_recording)

            rec_name=list_letter_recording(n_trial);


            % here get the spikes, pos, everything common between RE and VE

            klusters            =   t{n_trial}.spike_clusters;
            oeTimer             =   t{n_trial}.oeTimer;
            
            if version_npix == 1
                delay = 0;
            elseif version_npix == 2
                delay               =   t{n_trial}.delay_ms; 
            end
            
            sptime              =   t{n_trial}.spike_times; 
            pos                 =   t{n_trial}.xy1;
            dir_head              =   t{n_trial}.angles;
            pos_z  = t{n_trial}.zpos;
            pos_y  = t{n_trial}.ypos;

            licking_sig=t{n_trial}.licks;
            reward_stamps=t{n_trial}.rewards;

 
            % Get trial length
            t{n_trial}.n_samples = length(oeTimer);

            



            n_rec=n_trial;
            %pos=xy1;
    %           dir_head=angles;



              if isempty(dir_head) % then it's a VR trial
                  pixels_per_meter=[];
                  cm_per_bin = cm_per_bin_VE; %5;
                  track_length=track_length_VE;
%                   disp('PLEASE CHECK THIS IS THE TRACK LENGTH YOU WANT TO STORE');
%                   keyboard;
                  % to stop hardcoding the track length check the following
                  % lines:
%                   pos_no_interlap=find(pos>2000);
%                   if pos(pos_no_interlap(1)-150)>400
%                       track_length=900;
%                   else
%                       track_length=400;
%                   end
                  rec_type=string('VE');
                  
              else % then it's a RE trial
                  pixels_per_meter=n_pixels_per_meter; %530;
                  cm_per_bin=[];  
                  track_length=[];
                  rec_type=string('RE');
              end



              %% get the LFP       
            cd(folder_to_store_the_LFP);

            session__=char(session);
            session_and_recnumber = strcat(session__(1:4),'20',session__(5:6),rec_name);
            if exist(strcat('LFP_aligned_M',num2str(animal_index),'_',session_and_recnumber,'_group',num2str(1),'_',rec_type,'.mat'))==0
                file_LFP_merged = string('mergedLFP.bin'); % THAT FILE IS GENERATED WHEN WE RUN MARIUS'S PROGRAM TO CREATE THE SPIKES.BIN BEFORE CONCATENATING (AND BEFORE RUNNING KILOSORT)

                %% get folder name and pos file name

                folder_name_cont= strcat(M.animal_folder,'\',M.trial(n_trial).name); 
                cd(folder_name_cont); 
                pos_filename = ls('*pos*'); % was pos_filename = ls('pos*');
                if size(pos_filename, 1) == 0
                    error('Couldn''t find position data binary file.')
                elseif size(pos_filename, 1) > 1
                    error('Too many possible position data binary files.');
                end
                %posfile = fullfile(trial_folder, pos_filename);  
                %%

                % the n channels required to open the LFP file is n recording
                % channels + 1

                nb_channels_to_open_LFP = nb_channels+1;

                result_file_2 = fopen(string(file_LFP_merged));

                array_tmp = fread(result_file_2,'*int16','ieee-le');
                size_chunk_per_channel = length(array_tmp)/nb_channels_to_open_LFP;

                fclose('all');

                result_file_2 = fopen(file_LFP_merged);

                array_LFP_non_aligned= fread(result_file_2,[nb_channels_to_open_LFP size_chunk_per_channel],'*int16','ieee-le');

                array_LFP_aligned = align_LFP_with_pos_file_2_aug2023(folder_name_cont,array_LFP_non_aligned,strcat(pos_filename,'.bin'),pos,rec_type,spike_sampling_rate,pos_sampling_rate,LFP_sampling_rate,delay/1000); % delay expressed in seconds.

                cd(folder_to_store_the_LFP);
                disp('storing the LFP aligned with position for all the recording groups');
                tic;
                for igroup = 1:8
                    channels_in_group = ((igroup-1)*48)+1:((igroup-1)*48)+48;
                    LFP_alignedpos_one_group=array_LFP_aligned(channels_in_group,:);
                    save(strcat('LFP_aligned_M',num2str(animal_index),'_',session_and_recnumber,'_group',num2str(igroup),'_',rec_type,'.mat'),'LFP_alignedpos_one_group','channels_in_group','-v7.3');
                end
                toc;
            end

            if exist('LFP_all_group','var')==0
                tic;
                LFP_all_group=cell(1,8);
                % now load only the recording group of that cell
                for ig=1:8
                    load(strcat('LFP_aligned_M',num2str(animal_index),'_',session_and_recnumber,'_group',num2str(ig),'_',rec_type,'.mat'));
                    LFP_all_group{ig}=LFP_alignedpos_one_group;
                    clear LFP_alignedpos_one_group;
                end
                toc;
            end

           

            %% Loop through each template to store the spikes and the waveforms
            indeks=cells_to_store;
            for i = 1:length(indeks)
                tic;
               
                disp(i);
                cell_i = indeks(i);
                disp(cell_i);

                %% getting the mat name and checking it has been stored already

                session__=char(session);
                if part == 1
                    % part 1: keep the same cell index 
                    if cut=='y'
                        mat_namee=strcat('M',num2str(animal_index),'_',session__(1:4),'20',session__(5:6),rec_name,'_',num2str(cell_i),'m');
                    else
                        mat_namee=strcat('M',num2str(animal_index),'_',session__(1:4),'20',session__(5:6),rec_name,'_',num2str(cell_i));
                    end
                    
                elseif part == 2
                    % part 2: add 5000 to the cell index to not have an overlap
                    % between part 1 and part 2 indices.
                    if cut=='y'
                        mat_namee=strcat('M',num2str(animal_index),'_',session__(1:4),'20',session__(5:6),rec_name,'_',num2str(cell_i+5000),'m');
                    else
                        mat_namee=strcat('M',num2str(animal_index),'_',session__(1:4),'20',session__(5:6),rec_name,'_',num2str(cell_i+5000));
                    end
                else
                    disp('choose which part of the session you want');
                    pause;
                end

                fname = strcat(folder_to_store_the_mats,'\',mat_namee,'.mat');
                fname2 = strcat(folder_to_store_the_mats2,'\',mat_namee,'.mat');
%                 disp(mat_namee);
                session_and_recnumber = strcat(session__(1:4),'20',session__(5:6),rec_name);

                if exist(fname)~=0 || exist(fname2)~=0

                    goforit = 'n'; 
                else
                    goforit = 'y'; 
                end
                %%
                
                indz = sptime(klusters==cell_i); 
%                 disp(goforit);
                if goforit == 'y' && isempty(indz) == 0

                      %% getting the spike times for that cluster at 30kHz
                      indz = sptime(klusters==cell_i); 
                      tc = double(indz)/spike_sampling_rate; % in seconds

                      %% correction/add on from PK 170224 to get the spike times aligned
                      % with pos for neuropixels.

                      % note: version npix 1 case below could be treated as
                      % version 2. 
                      
%                       if version_npix == 1 % for neuropixels 4 shanks version 1, the delay between ephys and pos is 0 (or very very close to 0)
%                           indexes_spikes_alignedwithpos = find(tc < (size(pos,1)/pos_sampling_rate)-2 & tc > 2);  % 2 sec offset at the beginning and at the end
%                           spk30k_tmp = round(spike_sampling_rate*(double(indz)/spike_sampling_rate - delay/1000)); % delay is in ms. 
%                           spk30k=spk30k_tmp(indexes_spikes_alignedwithpos);
%                           spikes_stamps=spk30k;
%                       %%  
%                       
%                       %% added for npix probe version 2:
%                       else
                          % we substract the delay so spike times and
                          % position are aligned.
                          spk30k_tmp = round(spike_sampling_rate*(double(indz)/spike_sampling_rate - delay/1000)); % delay is in ms. 
                          % now, like for version of neuropixels above, we
                          % take an offset of 2 seconds at the beginning
                          % and at the end of the recording.
                          % so 2*spike_sampling_rate is equal to 2 seconds.
                          indexes_spikes_alignedwithpos = find(spk30k_tmp < ((size(pos,1)/pos_sampling_rate)*spike_sampling_rate)-(2*spike_sampling_rate) & spk30k_tmp > (2*spike_sampling_rate));
                          % spk30k_tmp is expressed in n samples at 30kHz
                          % sampling frequency.
                          spk30k=spk30k_tmp(indexes_spikes_alignedwithpos);
                          spikes_stamps=spk30k;
%                       end
                      
                      %%



                      %% getting the waveforms for that cluster (in the concatenated folder)
                      spk_stamps_notaligned = indz(indexes_spikes_alignedwithpos); % these are the spike stamps in the concatenated raw data file (.bin). They are used after to find the waveforms 
                      % in the raw data file.
                      
                      

                      % now I add the lower limit of the trial to have the correct
                      % time stamp of the spikes in the concatenated file.

%                       if n_trial > 1
%                          spk_stamps_notaligned_inconcat = spk_stamps_notaligned+csum_n_spikes(n_trial-1);
%                       else
%                          spk_stamps_notaligned_inconcat = spk_stamps_notaligned;
%                       end
                    %%
                      if n_trial > 1
                         spk_stamps_notaligned_inconcat = spk_stamps_notaligned+csum_n_spikes(n_trial-1);
                      else
                         spk_stamps_notaligned_inconcat = spk_stamps_notaligned;
                      end
                    %%

                    %% commented after 081124
                      %raw_file_with_all_the_data = fopen(strcat(concatenated_folder,'\spikes_combi.bin'));

%                       if length(spk_stamps_notaligned_inconcat) > 2000 % was 80000 then I take less spikes into account for the waveform variable. Otherwise would be too big in memory as a matlab array!!
%                         n_spikes = 2000; % was 80000 before 170624
%                         
%                         %% added on 170924
% %                         first_half = 2:ceil(length(spk_stamps_notaligned_inconcat)/2);
% %                         second_half = ceil(length(spk_stamps_notaligned_inconcat)/2)+1:(length(spk_stamps_notaligned_inconcat))-1;
% %                         
% %                         spike_indices_for_wf = sort([first_half(randperm(length(first_half),10000)),second_half(randperm(length(first_half),10000))]);
% %                         
% %                         n_spikes=length(spike_indices_for_wf)+2;
% %                         
% %                         spk_stamps_notaligned_inconcat_forwf=spk_stamps_notaligned_inconcat(spike_indices_for_wf);
%                         %%
%                         
%                       else
%                         n_spikes = length(spk_stamps_notaligned_inconcat);
% %                         spike_indices_for_wf = 2:n_spikes-1;
% %                         spk_stamps_notaligned_inconcat_forwf=spk_stamps_notaligned_inconcat;
% %                         spike_indices_for_wf = 2:n_spikes-1;
%                       end
                      %%
                      n_spikes = length(spk_stamps_notaligned_inconcat);
                      
                      if n_spikes > 200
                        spikes_for_wf = randperm(n_spikes,200);
                      else
                        spikes_for_wf = 1:n_spikes;
                      end
                          
                      

                      if n_spikes > 0

                        a_poor_raw_waveform = zeros(length(spikes_for_wf),nb_channels,80); 

                         %opening the file to extract the waveforms from
                         raw_file_with_all_the_data = fopen(strcat(concatenated_folder,'\spikes_combi.bin'));
                         
                        ispiketoadd=1;
                        for ispike = spikes_for_wf %2:n_spikes-1 % was 2:n_spikes-1 before 081124
                            fseek(raw_file_with_all_the_data , (spk_stamps_notaligned_inconcat(ispike)-30)*nb_channels*2, 'bof');
                            a_poor_raw_waveform(ispiketoadd,:,:) = fread(raw_file_with_all_the_data, [nb_channels, 80], '*int16');
                            ispiketoadd=ispiketoadd+1;
%                             fseek(raw_file_with_all_the_data , (spk_stamps_notaligned_inconcat_forwf(ispike)-30)*nb_channels*2, 'bof');
%                             a_poor_raw_waveform(ispike,:,:) = fread(raw_file_with_all_the_data, [nb_channels, 80], '*int16');
                        end

                       end


                      list_sd = [];
                      ameans = [];
                      for ishape = 1:384%ceil((nroo*48))-47:ceil(nroo*48)%start_chan : stop_chan %ceil((nroo*48))-47:ceil(nroo*48)
           
                          aaa=reshape(a_poor_raw_waveform(:,ishape,:),[length(spikes_for_wf),80]);
                          amean=nanmean(aaa,1);
                          list_sd = [list_sd,abs(max(max(amean))-min(min(amean)))];
                          if isempty(ameans) == 1
                              ameans=amean;
                          else
                              ameans=[ameans;amean];
                          end

                      end

                      df_gr=find(list_sd==max(max(list_sd)));

                      recording_group = ceil(df_gr/48);

                      tetrode_channels = ceil((recording_group*48))-47:ceil(recording_group*48);
                      %all_waveforms_all_channels=ameans(ceil((recording_group*48))-47:ceil(recording_group*48),:);
                      all_waveforms_all_channels=a_poor_raw_waveform(:,tetrode_channels,:);

                      %%

                      % selecting which channel to store for the LFP
                      LFP_alignedpos_one_group_=LFP_all_group{recording_group};
                      LFP_aligned=LFP_alignedpos_one_group_(24,:);

                      %% the variables to store (common to both VE and RE)
                      % 'pos','dir_head','pos_sampling_rate','pos_z','pos_y','licking_sig','reward_stamps','lick_sampling_rate','spikes_stamps',
                      %'spike_sampling_rate','parc_ind','cue_manipulation','dark_manipulation','LFP','LFP_sampling_rate',
                      %'tetrode_channels','implant_loc_1','implant_loc_2','nb_channels','track_length','pixels_per_meter','cm_per_bin','version_kilosort'


                    
                    % store the data
                    if ~exist(strcat(folder_to_store_the_mats2))
                        mkdir(strcat(folder_to_store_the_mats2));
                    end


                    % save the mat file here
                    cd(strcat(folder_to_store_the_mats2));
                    
                   

                    save(mat_namee,'pos','dir_head','pos_sampling_rate','pos_z','pos_y','licking_sig','reward_stamps','lick_sampling_rate','spikes_stamps','spike_sampling_rate','implant_loc_1','implant_loc_2','track_length','pixels_per_meter','cm_per_bin','version_kilosort','tetrode_channels','recording_group','LFP_aligned','nb_channels','n_rec','general_mapping_NPX20', 'mapping_session','LFP_sampling_rate','all_waveforms_all_channels');
                        
                  
                    % added cause we got instability due to too many files opened
                    fclose('all');
                    clear 'spikes_stamps' 'tetrode_channels' 'recording_group' 'all_waveforms_all_channels' ;

                    %pause(0.1);

                    toc;
                end

                clear cell_i

            end

            % here i have to delete the var that contains the LFP
            clear 'LFP_all_group' 
            % and the var that are related to invdividual recordings
            clear   'pos' 'dir_head' 'pos_z' 'pos_y' 'licking_sig' 'reward_stamps' 'track_length' 'pixels_per_meter' 'cm_per_bin' 'n_rec' 'LFP_aligned'

    end

end