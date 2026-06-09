
function [vector_pos_x, vector_time, vector_sync, vector_vertical_pos, vector_feeder, vector_rewards] = getting_pos_VR1D_v3(posfile,folder_name,session)
%JK and PK: the programme for acquiring x coordinates in 1D VR which are
%not aligned in time with the spike recordings using openephys;
%the sampling rate is around 50Hz as reflected in vector_time 

%PK 160119: version v2 reading of the licks and vertical position in Unity is added.
%Vertical position is used for setting the screens as dark - when this
%position is set to either a value very high above zero or very low below
%zero, the screens are dark. When very close to zero (=2 in PK labview
%version 17 to at least version 20, the animal sees the track).

%PK 210119: version v3 reading the reward delivery timestamps 
%(a vector containing the duration of the reward delivery, sampled at 50Hz: 
%this vector contains as many values as the position vector, and 0 values 
%indicate no reward delivery).

fileID = fopen(fullfile(folder_name,posfile));%'G:\test101218\d_2018-12-10_14-38-35\20181210_124039__b_pos.bin');
A = fread(fileID,Inf,'double','ieee-be');

vector_pos_x_tmp = [];
vector_time_tmp = [];
vector_sync_tmp = [];

%% added by PK on 160119
vector_vertical_pos_tmp = [];
vector_feeder_tmp = [];
%%
%% added by PK on 210119
vector_rewards_tmp = [];
%%

for i = 11 : size(A) 
 
          
    if A(i)== 998 
         
          vector_pos_x_tmp = [vector_pos_x_tmp A(i-9)];
          vector_time_tmp = [vector_time_tmp A(i-10)];
          vector_sync_tmp = [vector_sync_tmp A(i-2)]; % ie TTL value (0 or 1)
          
          %% added by PK on 160119
          vector_feeder_tmp = [vector_feeder_tmp A(i-6)];
          vector_vertical_pos_tmp = [vector_vertical_pos_tmp A(i-5)];
          %%
          
          %% added by PK on 210119
          vector_rewards_tmp = [vector_rewards_tmp A(i-3)]; % added on 210119. This vector contains the duration of the reward. The 0 value means there was no reward. 
          %This vector contains values sampled at 50Hz and thus contains as
          %many values as the other ones.
          %%
    end
    
end

vector_time_tmp=vector_time_tmp-vector_time_tmp(1)*ones(size(vector_time_tmp));

% ALIGNING POS WITH FIRST TTL
%get pos files aligned to spikes. The alignement is defined by the first TTL
%pulse from ARDUINO: 

ind=find(vector_sync_tmp == 1, 1, 'first');
vector_pos_x = vector_pos_x_tmp(ind:end); 
vector_time = vector_time_tmp(ind:end);
vector_time = vector_time-vector_time(1)*ones(size(vector_time));
vector_sync = vector_sync_tmp(ind:end); % ie TTL value (0 or 1)
%s=char(session);
%if s(end) ~= '8'
    
    % added by PK on 160119:
    vector_vertical_pos = vector_vertical_pos_tmp(ind:end);
    
    %
    % added by PK on 210119:
    vector_rewards = vector_rewards_tmp(ind:end);
    vector_feeder = vector_feeder_tmp(ind:end);
    %
%else 
    %vector_vertical_pos = [];
    %vector_rewards = [];
    %vector_feeder = [];
%end
%%%

% INTERPOLATION 
% added on 070619: extremely important!!! without this
% interpolation step we had a mismatch between position and spikes (drift
% problem...)
vector_pos_x = interp1(vector_time,vector_pos_x,1:20:max(vector_time));

% pk added this interpolation part for other variables on 140619
%if char(session(end)) ~= '8'
    vector_rewards = interp1(vector_time,vector_rewards,1:20:max(vector_time));
    vector_feeder = interp1(vector_time,vector_feeder,1:20:max(vector_time));
    vector_vertical_pos = interp1(vector_time,vector_vertical_pos,1:20:max(vector_time));
%end
vector_sync = interp1(vector_time,vector_sync,1:20:max(vector_time));
%

% added on 070619: extremely important!!! without this
% interpolation step we had a mismatch between position and spikes (drift
% problem...)

vector_time = 1:20:max(vector_time);
%




end
    
    
    

    

