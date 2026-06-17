% separate_combined_trial_data
function t = separate_combined_trial_data_pk_vr_select_folder_bef(M, part)
    %% See whether to use cut or not
%     if nargin > 1
%         fname_npy_clust = cut_file;
%         [fpath, ~, ~] = fileparts(cut_file);
%         fname_npy_times = fullfile(fpath, 'spike_times.npy');
%     else
        fname_npy_times = fullfile(M.combi.folder, 'spike_times.npy');
        % fname_npy_clust = fullfile(M.combi.folder, 'spike_templates.npy');
        if part==1
            pathtocut=strcat(M.combi.folder,'\manual_firstpart\');
        elseif part==2
            pathtocut=strcat(M.combi.folder,'\manual_secondpart\');
        else
            disp('please input a correct part file number:1 or 2')
            pause;
        end
        cd(pathtocut);
        
        % search for the file containing the cut clusters list
        %%
        % below: instead of reading the cluster list from the manual cut
        % file, here I get the cluster list before manual cutting 
        name_file_clusters = fullfile(M.combi.folder, 'spike_clusters.npy');%ls('*spike_clusters_amp_*');
        %%
        
        
%         if contains(name_file_clusters(2,:),'  ')
%             fname_npy_clust = fullfile(pathtocut, string(name_file_clusters(2,:)));
%         else
%             fname_npy_clust = fullfile(pathtocut, string(name_file_clusters(1,:)));
%         end
        fname_npy_clust = name_file_clusters;%fullfile(pathtocut, string(name_file_clusters(1,:)));

       
%     end
    %% Change to folder containing combined trial data
    cd(M.combi.folder);
    
    %% Get templates (same set will be added for all trials)
    npy_templates     =   readNPY(fullfile(M.combi.folder, 'templates.npy'));
    
    %% Generate separate spike_times and spike_clusters variables
    npy_spike_times         =   readNPY(fname_npy_times);
    npy_spike_clusters      =   readNPY(fname_npy_clust);
    
    
    n_samples_trial = cellfun(@(A)A.bytes/2/M.n_channels_rec, {M.trial.datafile_dir}, 'Uni', 1);
    csum_n_spikes = cumsum(n_samples_trial);

    t = cell(1, length(M.trial));
    prev_trial_end = 0;
    for ii = 1:length(M.trial)
        trial_end = find(npy_spike_times <= csum_n_spikes(ii), 1, 'last');
        inds = (prev_trial_end+1):trial_end;

        if ii == 1
            t{ii}.spike_times = npy_spike_times(inds);
        else
            t{ii}.spike_times = npy_spike_times(inds) - csum_n_spikes(ii-1);
        end
        t{ii}.spike_clusters = npy_spike_clusters(inds);
        
        
        
        t{ii}.templates = npy_templates; % NO NEED TO INDEX - IN THIS LOOP FOR CONVENIENCE. 
        
        
        prev_trial_end = trial_end;
    end

    last_spike = cellfun(@(A)double(A.spike_times(end)), t);
    if any(last_spike > n_samples_trial)
        error('Spikes don''t add up.');
    end
    
    cd(M.animal_folder) %added by mk 13/10/19

    %% Retrieve position data and delay (ms) from original folders
    for ii = 1:length(M.trial)
        
        
        %trial_folder = fileparts(M.trial(ii).datafile); 
        
        trial_folder = strcat(M.animal_folder,'\',M.trial(ii).name); 

        % MK changes to .name on 13/102019 - CHANGE REVERTED BY PCV, 27 Jan
        % ^ Do not do this - run the programme 'update_spikes_combi_meta.m'
        % instead and use above code
        
        
%          %pk adds 260923
%         trial_folder(1)='L';
%         %
        
        cd(trial_folder);
        
        
        if M.trial(ii).flag_oe && ~M.trial(ii).flag_npx
            trial_code = regexpi(trial_folder, '\\[a-z]_\d{4}-\d{2}-\d{2}', 'match'); 
            if length(trial_code) ~= 1
                error('Too many possible trial codes found in path specified');
            end
            trial_code = trial_code{1};
            trial_code = trial_code(trial_code ~= '\');
            trial_code = trial_code(trial_code ~= '-');

            % % Use trial code to find pos file
            dir_out = dir;
            fnames = {dir_out.name};
            f_inds = find(cellfun(@(A) ~isempty(regexpi(A, [trial_code '_\d+.bin'], 'ONCE')), fnames));
            switch numel(f_inds)
                case 0 % No pos file found
                    error('Couldn''t find position data binary file.')
                case 1
                    pos_filename = fnames{f_inds};
                otherwise
                    error('Too many possible position data binary files.');
            end
            posfile = fullfile(trial_folder, pos_filename);
            
            %% PK change 130923
            % here I add an option if the pos is from VR
            if contains(string(pos_filename),string('__'))==1
                session=string('mmmnn'); % not used in the function just put whatever string
                [vector_pos_x, vector_time, vector_sync, vector_vertical_pos, vector_feeder, vector_rewards] = getting_pos_VR1D_v3(pos_filename,trial_folder,session);
                %added on 260923
                [vector_lat] = getting_pos_VR1D_v4(posfile,folder_name,session);

                x=vector_pos_x';
                y=ones(length(x),1);
                angles=NaN;
              
            else % then it's RE
                
                [xys_tmp, postim, trig] = clean_positions(posfile);
                % Get position and angles
                a1=xys_tmp(:,1);
                a2=xys_tmp(:,2);
                b1=xys_tmp(:,4);
                b2=xys_tmp(:,5);
                x = mean([a1, b1], 2);
                y = mean([a2, b2], 2);

                angles   = atan2d(a1-b1,a2-b2);
                [t{ii}.count, t{ii}.coo] = hist(angles, 72);
                angles(angles == 0) = NaN;
                    
            end
            
            
            %%


            sync_mess = fullfile(trial_folder,'experiment1\recording1\sync_messages.txt');
        %     ch_states = fullfile(trial_folder,'experiment1\recording1\events\Rhythm_FPGA-100.0\TTL_1\channel_states.npy');
            ch_tmpstmp = fullfile(trial_folder,'experiment1\recording1\events\Rhythm_FPGA-100.0\TTL_1\timestamps.npy');
        %     databin = fullfile(trial_folder,'experiment1\recording1\continuous\Rhythm_FPGA-100.0\continuous.dat');
            datatims = fullfile(trial_folder,'experiment1\recording1\continuous\Rhythm_FPGA-100.0\timestamps.npy');
        %     datafile = fullfile(trial_folder,'spikes.bin');

            syncTimer=double(readNPY(ch_tmpstmp)); 
            syncStart=syncTimer(1); 
        %     syncTimer=(syncTimer-syncTimer(1))/M.oe_sample_rate;

            oeTimer=double(readNPY(datatims)); 
            oeTimer=(oeTimer-oeTimer(1))/M.oe_sample_rate;

            oeStart = clean_startime(sync_mess);
            delay_ms = 1e3*((syncStart-oeStart)/M.oe_sample_rate - postim(find(trig,1))); % in ms

            %% PK change
            xy1=[x, y];
            t{ii}.xy1  = xy1;
            t{ii}.angles = angles;
%             t{ii}.xys       = xys;
            %% 

            t{ii}.delay_ms  = delay_ms;
            t{ii}.oeTimer   = oeTimer;
            
        elseif M.trial(ii).flag_npx && ~M.trial(ii).flag_oe
            pos_filename = ls('*pos*'); % was pos_filename = ls('pos*');
            if size(pos_filename, 1) == 0
                error('Couldn''t find position data binary file.')
            elseif size(pos_filename, 1) > 1
                error('Too many possible position data binary files.');
            end
            
            
            
            posfile = fullfile(trial_folder, pos_filename);  
            
            %% PK change 110923
            
            %[xys, postim, trig] = clean_positions(posfile); % was [xys, ~, ~] = clean_positions_msec(posfile);
            
            
            %% PK change 130923
            % here I add an option if the pos is from VR
            if contains(string(pos_filename),string('__'))==1
%                 disp(strcat('trial',num2str(ii)));
%                 disp('thats VE');
                session=string('mmmnn'); % not used in the function just put whatever string
                [vector_pos_x, vector_time, vector_sync, vector_vertical_pos, vector_feeder, vector_rewards] = getting_pos_VR1D_v3(pos_filename,trial_folder,session);
                
                % added on 260923 PK
                [vector_lat] = getting_pos_VR1D_v4(pos_filename,trial_folder,session);
                %
                
                x=vector_pos_x';
                y=ones(length(x),1);
                angles=[];
                
                t{ii}.xys = [];
                
                t{ii}.zpos = vector_vertical_pos;
                
                t{ii}.ypos = vector_lat;
                t{ii}.licks = vector_feeder;
                t{ii}.rewards = vector_rewards;
              
            else % then it's RE
                
%                 disp(strcat('trial',num2str(ii)));
%                 disp('thats RE');
                
                [xys_tmp, postim, trig] = clean_positions(posfile);
                % Get position and angles
                a1=xys_tmp(:,1);
                a2=xys_tmp(:,2);
                b1=xys_tmp(:,4);
                b2=xys_tmp(:,5);
                x = mean([a1, b1], 2);
                y = mean([a2, b2], 2);

                angles   = atan2d(a1-b1,a2-b2);
                [t{ii}.count, t{ii}.coo] = hist(angles, 72);
                angles(angles == 0) = NaN;
                
                t{ii}.xys = xys_tmp;
                
                %% added PK 130923
                
                 t{ii}.zpos = [];
                 %%
                 t{ii}.ypos = [];
                 t{ii}.licks = [];
                 t{ii}.rewards = [];
                    
            end
            
            
            
            

            %%
            
            
            sync_filename = ls('*ap_AP_sync.bin*'); % was: sync_filename = ls('*ap_sync_AP.bin');
            if size(sync_filename, 1) == 0
                error('Couldn''t find sync file.')
            elseif size(sync_filename, 1) > 1
                error('Too many possible sync files.');
            end
            syncfile = fullfile(trial_folder, sync_filename);
            sfid = fopen(syncfile, 'r');
            sync = fread(sfid, 1e8, '*uint16');
            delay_ms = find(diff(sync)>30, 1)/M.oe_sample_rate*1e3; % in ms
            
            xy1=[x, y];
            t{ii}.xy1  = xy1;
             %t{ii}.xys       = xys;
             t{ii}.angles = angles;
             
            t{ii}.delay_ms  = delay_ms;
            t{ii}.oeTimer   = ((1:n_samples_trial(ii))-1)/M.oe_sample_rate;
            
           
            
            
        else
            error('Is this OpenEphys or Neuropixels data? Flags ambiguous.');
        end
        cd(M.animal_folder)
    end

    cd(M.combi.folder);
end