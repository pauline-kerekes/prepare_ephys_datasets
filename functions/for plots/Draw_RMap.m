function Draw_RMap(rmap)
%draws the specified rate map 'rmap'

NrColors=10;
tintColMap=generate_colorMap(1);



%normalized xy coordinates, i.e. counted from 1 to the length in pixels of
%the environment

tmp_value=min(min(rmap))-(max(max(rmap))-min(min(rmap))+1)/NrColors;
tmp_rmap=reshape(rmap,1,size(rmap,1)*size(rmap,2));
tmp_rmap(isnan(tmp_rmap))=tmp_value;
rmap2=reshape(tmp_rmap, size(rmap,1),size(rmap,2));

%clims = [-1 1];
set(gcf, 'color', [1 1 1]);
imagesc(rmap2);
colormap(tintColMap);

set(gca,'YDir','reverse');


axis equal;
%axis off;
%axis tight;


end