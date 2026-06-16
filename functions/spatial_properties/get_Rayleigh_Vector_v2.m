function [Rl_vect, rot_angle, r_smooth]=get_Rayleigh_Vector_v2(Rat_dir, cellNr_spikes_coordinates, pos_sample_rate)
%Rat_dir - (in deg) all the sampled directions that rat has taken during the trial
%spike_coordinates - (integer numbers >0) indices that indicate when the spike occured in Rat_dir array
%by eye observation - usually the HD RVect is >0.5


polar_bin_size=3;% the binsize of the polar plot - 3 degrees
[r_pos, rot_angle_pos]=polar_pos_map(Rat_dir,pos_sample_rate, polar_bin_size);
[r_spk, rot_angle_spk]=polar_spike_map(Rat_dir, cellNr_spikes_coordinates, polar_bin_size);
  
%Smoothening
windowSize = 5;
   
tmp_r_pos=repmat(r_pos ,1, 3);
r_pos_smooth=filtfilt(ones(1,windowSize)/windowSize, 1, tmp_r_pos);
r_pos_smooth=r_pos_smooth(length(r_pos)+1:2*length(r_pos));
  
tmp_r_spk=repmat(r_spk ,1, 3);
r_spk_smooth=filtfilt(ones(1,windowSize)/windowSize, 1, tmp_r_spk);
r_spk_smooth=r_spk_smooth(length(r_spk)+1:2*length(r_spk));
  
r_smooth=r_spk_smooth./r_pos_smooth;

r_smooth=r_smooth./max(r_smooth);
rot_angle=rot_angle_spk(isnan(r_smooth)~=1);
r_smooth=r_smooth(isnan(r_smooth)~=1);

%tmp=Rat_dir(spike_coordinates);
%tmp=tmp(isnan(tmp)~=1);
C=sum(r_smooth.*cos(rot_angle));
S=sum(r_smooth.*sin(rot_angle));

Rl_vect=sqrt(S^2+C^2)/sum(r_smooth);

%for plotting polar plot
%figure();
%polar_with_thicker_line(rot_angle, r_smooth, '-k');

end