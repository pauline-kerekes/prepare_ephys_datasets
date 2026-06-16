function [r, rot_angle]=polar_spike_map(dir, spikes_rot, bin_size)

%bin_size - the bin_size of the polar plot, i.e. 360 degrees devided into N
%number of bin_size 'pies'.






spikes_rot_bin=round(dir(spikes_rot)/bin_size);
r=zeros(1,ceil(360/bin_size)+1);
j=1;
for i=0:ceil(360/bin_size)
  tmp=ceil(spikes_rot_bin)==i;
  r(j)=sum(tmp);
  j=j+1;
end

r(1)=(r(1)+r(length(r)))/2;%because 0 deg and 360 deg is the same direction
tmpr=r(1:end-1);
r=tmpr;

rot_angle=(0:ceil((360-bin_size)/bin_size))*bin_size*pi/180;
%rot_angle(length(rot_angle)+1)=0;
%r(length(rot_angle))=r(1);

end