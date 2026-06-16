function rmap=Spike_Map(xy, cellNr_spikes_coordinates, bin_size, varargin)
%Generates the spike rate map. The Units of this graph are given in spike
%number - i.e. the number of spikes that was fired in a given bin during
%the whole trial



Nr_pixels=bin_size; 



%visited positions expressed in bins
xy_bin(:,1)=ceil(xy(max(1,min(cellNr_spikes_coordinates, length(xy(:, 1)))), 1)/Nr_pixels);
xy_bin(:,2)=ceil(xy(max(1,min(cellNr_spikes_coordinates, length(xy(:, 1)))), 2)/Nr_pixels);



if length(varargin)>=2
  rmap=Location_Map(xy, bin_size, varargin{1}, varargin{2});
else
  rmap=Location_Map(xy, bin_size);
end

tmp_rmap=reshape(rmap,1,size(rmap,1)*size(rmap,2));
tmp_rmap(isnan(tmp_rmap)~=1)=0;
rmap=reshape(tmp_rmap, size(rmap,1), size(rmap,2));

%Nr_bins_x=ceil(max(xy(:, 1))/Nr_pixels);
%Nr_bins_y=ceil(max(xy(:, 2))/Nr_pixels);

Nr_bins_x=size(rmap,2);
Nr_bins_y=size(rmap,1);


for i=1:Nr_bins_x
  for j=1:Nr_bins_y
    tmpx=xy_bin(:, 1)==i;
    tmpy=xy_bin(:, 2)==j;
    sum_tmp=sum(tmpx.*tmpy);
    if sum_tmp~=0
      rmap(j, i)=sum_tmp;
    end
  end
end




clear xy_bin;


end