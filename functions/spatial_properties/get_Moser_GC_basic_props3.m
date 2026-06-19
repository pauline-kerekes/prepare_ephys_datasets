function [M_GC_measure, GC_orientations, d, field_diameter]=get_Moser_GC_basic_props3(sacSmooth, GC_thresh)
%calculates a standard Moser gridness measure
deg_bin=30; %calculates the correlation coefficient of SAC map every 6 degrees
thresh=0.3;


%all the possible radiuses are checked from 20 cm to 80% of the max width
%of the square enclsoure
correct_rad=10:4:round(0.5*max(size(sacSmooth))/2); %from 10 bins in case we have 2cm/bin

corrected_SAC_thresh=thresh;
 %setting initial values:
    M_GC_measure=nan;
for n_d=1:length(correct_rad) %takes a range of radiuses that we want to calculate SACs for
    
    [field_d, localSAC]=find_localSAC(sacSmooth, correct_rad(n_d), corrected_SAC_thresh);
    
    
   
    
    if isempty(localSAC)~=1
        field_diameter=field_d;
        
        tmp1=reshape(localSAC, 1, size(localSAC, 2)*size(localSAC, 1));
        %min:30 90 150
        %max 60 120
        j=1;
        for i=1:5
            %sacSmooth2=imrotate(sacSmooth, i*deg_bin, 'crop');
            localSAC2=imrotate(localSAC, i*deg_bin, 'crop');
            localSAC2(localSAC2==0)=NaN;
            tmp2=reshape(localSAC2, 1, size(localSAC2, 2)*size(localSAC2, 1));
            tmp3=tmp1((isnan(tmp1)~=1)&(isnan(tmp2)~=1));
            tmp2=tmp2((isnan(tmp1)~=1)&(isnan(tmp2)~=1));
            R=corrcoef(tmp3, tmp2); %labai panasus resultatai gaunasi xcorr arba corrcoeff
            corr_coeff(j)=R(1, 2);
            
            j=j+1;
            
            clear localSAC2 tmp2 tmp3 R field_d;
        end
        M_GC_measure(n_d)=min([corr_coeff(2) corr_coeff(4)])-max([corr_coeff(1) corr_coeff(3) corr_coeff(5)]);
        clear corr_coeff localSAC;
    end
end

[max_GC_measure, GC_ind]=max(M_GC_measure);
clear M_GC_measure

%setting initial values:
M_GC_measure=max_GC_measure;
correct_rad_optimal=correct_rad(GC_ind);
GC_orientations=nan;
d=nan;

if M_GC_measure>=GC_thresh %only calculates other GC main properties if the GC_measure is larger than a hard set threshold
    [field_diameter, localSAC]=find_localSAC(sacSmooth, correct_rad_optimal, corrected_SAC_thresh);
    
    
    %calculating all the relevant values taking the local SAC radius with
    %optomised GC measure
    
    tmp=localSAC;
    tmp(tmp<=max(max(localSAC))*thresh)=0;
    tmp(isnan(tmp))=0;
    %Have to flip the image for correct angle calculations
    tmp=tmp(end:-1:1, :);
    tmp=bwlabel(tmp);
    N=max(max(tmp));
    [l, w]=size(localSAC);
    
    
    xy_c=zeros(N, 2);
    for i=1:N
        tmp2=zeros(size(tmp));
        tmp2(tmp==i)=1;
        [y,x]=find(tmp2==1);
        xy_c(i,1)=mean(x); %finding the centre of mass for every field
        xy_c(i,2)=mean(y);
        S=mean(y)-w/2;
        C=mean(x)-l/2;
        if (S>0)&&(C>0)
            preferred_angle(i)=atan(S/C);
        elseif (S>=0)&&(C<0)
            preferred_angle(i)=pi-atan(abs(S/C));
        elseif (S<0)&&(C<0)
            preferred_angle(i)=atan(abs(S/C))+pi;
        elseif (S<=0)&&(C>0)
            preferred_angle(i)=2*pi-atan(abs(S/C));
        elseif (S>0)&&(C==0)
            preferred_angle(i)=pi/2;
        elseif (S<0)&&(C==0)
            preferred_angle(i)=3*pi/2;
        end
        
    end
    
    
    
    
    %distances of the field centres to the centre of SAC map
    d=sqrt((xy_c(:,1)-round(w/2)).^2+(xy_c(:,2)-round(l/2)).^2);
    [d1, IX]=sort(d,'ascend'); clear d;
    d=d1(1:min([6 length(d1)]));
    preferred_angle2=preferred_angle(IX(1:length(d))); clear preferred_angle;
    preferred_angle=preferred_angle2; clear preferred_angle2;
    
    
    GC_orientations=preferred_angle*180/pi;
    %disp(GC_orientations);%TV
    %disp(d); %TV
    %disp(field_diameter); %TV
    
    %% commented by PK 110223
    %for visualization -------------------------------------------
%             figure(3);
%             imagesc(tmp)
%             axis equal
%             set(gca, 'YDir', 'normal')
%             figure(4);
%             imagesc(localSAC);
%             axis equal;
%             figure(5);
%             imagesc(sacSmooth);
%             axis equal;
%             close all;
  %%  
else
    %M_GC_measure=NaN;
    GC_orientations=NaN;
    d=NaN;
    field_diameter=NaN;
end
end