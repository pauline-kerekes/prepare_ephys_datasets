function [field_d, localSAC]=find_localSAC(sacSmooth, correct_rad, corrected_SAC_thresh)

%uses smoothened SAC to find the matrix with only the fields located
%closest to the centrala peak (ideally 6 fields around the central field)

%Setting up an arbitrary threshold in order to isolate individual fields in
%SAC from each other

%corrected radius is an inner SAC radius - if you want to estimate it
%automatically correct_rad=NaN. Otherwise enter a value in bins.

%JK: thresh=0.1 yra naudojamas normaliems sacSmooth skaiciuoti, t.y. kada visas trial
%imamamas SACui gauti - 0.1 naudojamas visai mano analize
%bet kai analizuoju time window SAC tada turiu paaukstinti tresholda, kad
%nesujungciau visu SAC regionu!!! 03/06/2011

%JK: 25/07/13 pakeiciau thresholda is 0.1 i 0.3
%thresh=0.1;
%16/02/14 JK: field_d - calculates the field diameter from the central
%field thresholded to >0.1 above the maximal value.

%Normally in case SAC threshold needes to be adjusted because the power is
%unevenly distribute across componnts (orienttaions) - this is especially
%important for trapezoids to avoid any confusing second order symmetries.
if isnan(corrected_SAC_thresh)~=1
    thresh=corrected_SAC_thresh;
else
    thresh=0.4;
end

field_thresh=0.2;

if isnan(correct_rad)
  tmp=sacSmooth;
  tmp(tmp<=max(max(sacSmooth))*thresh)=0;
  tmp=bwlabel(tmp);

  N=max(max(tmp));

if N>=7

for i=1:N
  tmp2=zeros(size(tmp));
  tmp2(tmp==i)=1;
  [y,x]=find(tmp2==1);
  xy_c(i,1)=mean(x); %finding the centre of mass for every field
  xy_c(i,2)=mean(y);
end

 [l w]=size(sacSmooth);
 x_c=ceil(w/2);
 y_c=ceil(l/2);

%distances of the field centres to the centre of SAC map
d=sqrt((xy_c(:,1)-round(w/2)).^2+(xy_c(:,2)-round(l/2)).^2);

[d1 IX]=sort(d,'ascend');



%for displaying the centres of the closest fields
%imagesc(sacSmooth);
%hold on;
%plot(ceil(xy_c(IX(1:7), 1)), ceil(xy_c(IX(1:7), 2)), '+k', 'markersize', 10, 'linewidth', 2);

%l_localSAC=2.5*ceil(mean(d1(IX(2:7))));
 l_localSAC=1.1*ceil(mean(d1(2:7))); %additional 0.1 to include an entire field
 l_centreSAC=ceil(l_localSAC*0.4);
 
 [l, w]=size(sacSmooth);
 x_c=ceil(w/2);
 y_c=ceil(l/2);
 
 %Calculating the field diameter field_d:
 dd1=sacSmooth(y_c-l_centreSAC:y_c+l_centreSAC, x_c-l_centreSAC:x_c+l_centreSAC);
 dd1=dd1>=max(max(dd1))*field_thresh;
 field_d=2*sqrt(sum(sum(dd1))/pi);

 %r_centre=ceil(r/2.5);
 [x, y]=meshgrid(-(x_c-1):w-x_c, -(y_c-1):l-y_c);
 c_mask=(x.^2+y.^2)<= (l_localSAC)^2;
 %Cutting out the central field:
 c_mask_c=(x.^2+y.^2)<= (l_centreSAC)^2;
 sacSmooth2=sacSmooth;
 sacSmooth2(c_mask==0)=NaN;
 sacSmooth2(c_mask_c==1)=NaN;
 
 
 x1=max(1, ceil(w/2-l_localSAC));
 x2=min(w, ceil(w/2+l_localSAC));
 y1=max(1, ceil(l/2-l_localSAC));
 y2=min(l, ceil(l/2+l_localSAC));
 
 localSAC=sacSmooth2(y1:y2, x1:x2);
% 
% figure(2);
% imagesc(localSAC);
% axis equal;


%find send fields closest to the centre, exclude the closest one because it
%is the centre and then take a mean distance of your fields multiplied by a
%coefficient to define your matrix
 
else
   localSAC=[];
   field_d=[];
end
else
   l_localSAC=correct_rad;
   l_centreSAC=ceil(l_localSAC*0.4);
   [l, w]=size(sacSmooth);
   x_c=ceil(w/2);
   y_c=ceil(l/2);
   
   %Calculating the field diameter field_d:
   dd1=sacSmooth(y_c-l_centreSAC:y_c+l_centreSAC, x_c-l_centreSAC:x_c+l_centreSAC);
   dd1=dd1>=max(max(dd1))*field_thresh;
   field_d=2*sqrt(sum(sum(dd1))/pi);

   %r_centre=ceil(r/2.5);
   [x, y]=meshgrid(-(x_c-1):w-x_c, -(y_c-1):l-y_c);
   c_mask=(x.^2+y.^2)<= (l_localSAC)^2;
   %Cutting out the central field:
   c_mask_c=(x.^2+y.^2)<= (l_centreSAC)^2;
   sacSmooth2=sacSmooth;
   sacSmooth2(c_mask==0)=NaN;
   sacSmooth2(c_mask_c==1)=NaN;
 
 
   x1=max(1, ceil(w/2-l_localSAC));
   x2=min(w, ceil(w/2+l_localSAC));
   y1=max(1, ceil(l/2-l_localSAC));
   y2=min(l, ceil(l/2+l_localSAC));
 
   localSAC=sacSmooth2(y1:y2, x1:x2);
   if isempty(field_d)
       field_d=nan;
   end
   
  %for display purposes
%   figure(2);
%   %imagesc(localSAC);
%   Draw_RMap(localSAC);
%   axis equal;
%   set(gca, 'Ydir', 'normal');
%   set(gca, 'visible', 'off');


  %find send fields closest to the centre, exclude the closest one because it
  %is the centre and then take a mean distance of your fields multiplied by a
  %coefficient to define your matrix
    
end


  

    
end
