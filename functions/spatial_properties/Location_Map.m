function pmap=Location_Map(xy, bin_size, varargin)
%This function generates the position rate map in arbitrary units
%(number of visits to the bin), which you then have to devide by 
%position sampling rate to get the occupation time in sec for each bin.
%The size of the position rate map is Nr_bins x Nr_bins

%bin_size must be given in cm
%additional input represents a feature of the map that the User must specify, which defines
%whether the map will be drawn to fit tightly the trajectories (in this
%case varargin='tight', or it will be drawn having a preset size. 
%e.g. rmap=Location_Map(xy, bin_size, 230, 140) would mean that I would
%like to project my path on 230 cm (x) x 140 cm (y) plane.

if length(varargin)<=1 % if no extra arguments added to the function
  Nr_bins_x=ceil(max(xy(:, 1))/bin_size); % number of bins along the x axis
  Nr_bins_y=ceil(max(xy(:, 2))/bin_size); 
  
else
  
    Nr_bins_x=ceil(varargin{1}/bin_size);
    Nr_bins_y=ceil(varargin{2}/bin_size);
    
end

%visited positions expressed in bins
xy_bin=ceil(xy/bin_size); % x positions expressed in number of bins
inds = xy_bin(:) == 0;
if sum(inds) >= 100
    warning(sprintf('%d actual zeros found in xy.', sum(inds)));
end
xy_bin(inds) = 1;
%% Old
% x_log = xy_bin(:, 1) == 1:Nr_bins_x;  
% x_log = permute(x_log, [1, 3, 2]);
% y_log = xy_bin(:, 2) == 1:Nr_bins_y;
% xy_combo = x_log & y_log;
% pmap = squeeze(sum(xy_combo, 1));
% pmap(pmap == 0) = NaN;
%%
inds_bin = sub2ind([Nr_bins_y, Nr_bins_x], xy_bin(:,2), xy_bin(:,1));
pvec = histcounts(inds_bin, 0.5+(0:(Nr_bins_y*Nr_bins_x)));
pmap = reshape(pvec, [Nr_bins_y, Nr_bins_x]);
pmap(pmap == 0) = NaN;

end




