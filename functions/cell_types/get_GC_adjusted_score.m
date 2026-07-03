
function [GC_score,GC_scale] = get_GC_adjusted_score(xy,spikes_stamps,spike_sampling_rate,pos_sampling_rate,pixels_per_m,m_per_bin)


        bin_size=ceil(pixels_per_m*m_per_bin); % - it is around  2 cm x 2 cm per bin expressed (was m_per_bin=0.02 )
        v_min=5; %5 cm/s
        v_max=100; %100 cm/s - it is unlikely that mice are running faster than that
        %hard set GC threshold
        GC_thresh=0.27;

        %Generating the Gaussian 
        gausSigma=2;
        [x,y]=meshgrid(-2:2);
        gausKern=1*(exp(-(x.^2 + y.^2)/(2*gausSigma^2)));
        gausKern=gausKern./sum(gausKern(:)); %Normalise
        clear x y;
        %%


        %% Getting pos, head direction and smooth rate maps to calculate the scores
       
%          Rat_dir=mod(dir_head+360, 360);

        [v_smooth, f_v]=speed_filtering(xy, v_min, v_max, pixels_per_m, pos_sampling_rate);
        
        xy(f_v==0,1)=nan;
        xy(f_v==0,2)=nan;
%         Rat_dir(f_v==0)=nan;
        pos_x = xy(:,1);
        pos_y = xy(:,2);
        min_x=min(pos_x);
        min_y=min(pos_y);

        if min_x ==0
            pos_x(pos_x==0)= nan;
            xy = [pos_x,pos_y];
        end

        if min_y ==0
            pos_y(pos_y==0)= nan;
            xy = [pos_x,pos_y];
        end
            
        cellNr_spikes_coordinates=max(1, floor(spikes_stamps/spike_sampling_rate*pos_sampling_rate));
                
        %Generating UNSMOOTHENED location rate map
        pos_map=Location_Map(xy, bin_size);
        sp_map=Spike_Map(xy, cellNr_spikes_coordinates, bin_size);
        %pos_map(pos_map/pos_sample_rate<0.05)=NaN;
        
        SpRmap=sp_map./pos_map*pos_sampling_rate;
        minx=min(xy(:, 1));
        maxx=max(xy(:, 1));
        miny=min(xy(:, 2));
        maxy=max(xy(:, 2));
        SpRmap=SpRmap(ceil(miny/bin_size):floor(maxy/bin_size), ceil(minx/bin_size):floor(maxx/bin_size));
        SpRmap(isnan(SpRmap))=0;
        
        sacSmooth=get_smooth_SAC(SpRmap); %Obtains already smoothened SAC  
        [GC_score, GC_orientations, d, field_diameter]=get_Moser_GC_basic_props3(sacSmooth, GC_thresh);
        
        
        best_radius=[];
        best_scores=[];
        best_scales=[];
        for corrected_rad=9:60
            [GC_score, GC_orientations, d, field_diameter,correct_rad,calculated_rad]=get_Moser_GC_basic_props3_pauline(sacSmooth, GC_thresh,corrected_rad);
%             disp(d);
%             disp('*****');
%             disp(corrected_rad);
%             disp(GC_score);
%             disp(strcat('scale=',num2str(nanmean(d)*2),'cm'));
%             disp('*****');
            best_radius=[best_radius,corrected_rad];
            best_scores=[best_scores,GC_score];
            best_scales=[best_scales,(nanmean(d)*m_per_bin*100)];

        end
%         disp('best radius')
%         disp(best_radius(find(best_scores==max(max(best_scores)))));
%         disp('best scale')
%         disp(best_scales(find(best_scores==max(max(best_scores)))));

        index_best_score = find(best_scores==max(max(best_scores)));
        
        GC_score = best_scores(1,index_best_score(1));
        GC_scale = best_scales(1,index_best_score(1));


    
end