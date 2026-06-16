function BC_score=get_BC_score2(rmap)
%trying  a different way of measuring BC score


rmap(isnan(rmap)==1)=0;

BC_field_threhold=0.2;  %JK: was 0.2 threshold in the original version
n_width=5; %6;%width of the field next to the wall, e.g. 6*2.5cm=15 cm from the wall is included

[l, w]=size(rmap);


norm_rmap=rmap/sum(sum(rmap)); %creating a normalised rate map


%creating boarder masks---------------------------------------------------


S_Wall=zeros(size(rmap));  %creating a mask for the south wall
S_Wall(ones(w, n_width).*repmat((l:-1:(l-n_width+1)), w,1), repmat(1:w,n_width, 1)')=1;

N_Wall=zeros(size(rmap));  %creating a mask for the north wall
N_Wall(ones(w, n_width).*repmat(1:n_width, w,1), repmat(1:w,n_width, 1)')=1;

W_Wall=zeros(size(rmap));  %creating a mask for the west wall
W_Wall(repmat(1:l,n_width, 1)',ones(l, n_width).*repmat(1:n_width, l,1))=1;

E_Wall=zeros(size(rmap));  %creating a mask for the east wall
E_Wall(repmat(1:l,n_width, 1)',ones(l, n_width).*repmat(w:-1:(w-n_width+1), l,1))=1;





%-----------------------------------------------

%every wall that has >75% of its length covered counts into a boarder
%signal; Everything else counts as of border signal:


mask_norm_map=rmap/max(max(rmap))>=BC_field_threhold;
SNWE=zeros(4,1);
tmp1=zeros(size(norm_rmap));
if sum(sum(mask_norm_map.*S_Wall))/sum(sum(S_Wall))>0.5
    tmp1=tmp1+S_Wall;
    SNWE(1)=1;
end
if sum(sum(mask_norm_map.*N_Wall))/sum(sum(N_Wall))>0.5
    SNWE(2)=1;
    tmp1=tmp1+N_Wall;
end
if sum(sum(mask_norm_map.*W_Wall))/sum(sum(W_Wall))>0.5
    SNWE(3)=1;
    tmp1=tmp1+W_Wall;
end
if sum(sum(mask_norm_map.*E_Wall))/sum(sum(E_Wall))>0.5
    SNWE(4)=1;
    tmp1=tmp1+E_Wall;
end

%creating of boarder mask----------------------------------------------------

if sum(SNWE)~=0
    off_border=10*tmp1; clear tmp1;
    off_border(off_border==0)=1;    
    off_border(off_border>=10)=0;
    in_border=off_border;
    in_border(in_border==0)=2;
    in_border(in_border==1)=0;
    in_border(in_border==2)=1;
    %sum normalised number of spikes in border area devide by percentage of area
    %classified as in border area devided by the sum normalised number of
    %spikes of border area devide by the relatibe proportion of the border
    %area
    %BC_score= n_width/w*(sum(sum(in_border.*norm_rmap))/(sum(sum(in_border))/numel(in_border))-sum(sum(off_border.*norm_rmap))/(sum(sum(off_border))/numel(off_border)));
    BC_score= sum(sum(in_border.*norm_rmap))/(sum(sum(in_border))/numel(in_border));
    
else
    BC_score=0;
end



end