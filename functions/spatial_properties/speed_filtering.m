function [v_smooth, f_v]=speed_filtering(xy, v_min, v_max, pixels_per_m, pos_sampling_rate)
%JK: 24/01/2021
%filters for speed so that only instances when the animal was running at a
%paticular speed range is counted. If lower or larger, the positions 
%v_smooth - smooth speed distribution
%f_v - sped filter. Equal to 0 below or above certain values set by v_min
%and v_max. Otherwise equal to 1;


%Smoothening

gausSigma=10;
x=-10:10;
gausKern=1*(exp(-(x.^2)/(2*gausSigma^2)));
gausKern=gausKern./sum(gausKern(:)); %Normalise

v= sqrt(diff(xy(:,1)).^2+diff(xy(:,2)).^2)*pos_sampling_rate/pixels_per_m*100; %cm/s

v_smooth=filtfilt(gausKern, 1,double(v));
f_v=ones(size(v_smooth));
f_v(v_smooth<v_min)=0;
f_v(v_smooth>v_max)=0;
f_v=[1; f_v]; % the first position will be always included

end


