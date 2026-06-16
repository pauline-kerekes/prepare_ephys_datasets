function [BC_score,GC_score,SI_score,HD_score,cell_type,smooth_r_map] = get_cell_RE_classification(xy,dir_head,spikes_stamps,spike_sampling_rate,pos_sampling_rate,target_brain_region,pixels_per_m,m_per_bin)

        % this program to get the BC, GC, SI and HD scores is a copy of the program
        % 'batch_cell_function_v3_TV_updated' which was used during the
        % error correction study conducted by TV (Tereza) and JK (in 2019-2020).
        % PK just added the get_cell_type_from_scores to get the cell type
        % from the scores based on thresholds transmitted by TV.



        %% General default parameters - Hard coded values used for all cells.
        
        %pixels_per_m=593; % was 613, corrected by PK on 110323 to 593 to correspond to the real image size taken by the camera in B17.
        bin_size=ceil(pixels_per_m*m_per_bin); % - it is around  2 cm x 2 cm per bin expressed (was m_per_bin=0.02 )
        v_min=5; %5 cm/s
        v_max=100; %100 cm/s - it is unlikely that mice are running faster than that
%         p=95; %95tth percentile taken as significance level
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
       
         Rat_dir=mod(dir_head+360, 360);

        [v_smooth, f_v]=speed_filtering(xy, v_min, v_max, pixels_per_m, pos_sampling_rate);
        
        xy(f_v==0,1)=nan;
        xy(f_v==0,2)=nan;
        Rat_dir(f_v==0)=nan;
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
        
        %% Getting the scores
        
        % Generating smoothened rate map using the adaptive smoothing:
        [smooth_pos_map, smooth_r_map]=apply_adaptive_smoothing(pos_map, sp_map, pos_sampling_rate);
        smooth_r_map=smooth_r_map(ceil(miny/bin_size):ceil(maxy/bin_size), ceil(minx/bin_size):ceil(maxx/bin_size));
    
        %*************Estimating GC_measure:************************************
        sacSmooth=get_smooth_SAC(SpRmap); %Obtains already smoothened SAC    
        best_radius=[];
        best_scores=[];
        best_scales=[];
        for corrected_rad=10:60
            [GC_score, GC_orientations, d, field_diameter,correct_rad,calculated_rad]=get_Moser_GC_basic_props3_pauline(sacSmooth, GC_thresh,corrected_rad);
%             disp(d);
%             disp('*****');
%             disp(corrected_rad);
%             disp(GC_score);
%             disp(strcat('scale=',num2str(nanmean(d)*2),'cm'));
%             disp('*****');
            best_radius=[best_radius,corrected_rad];
            best_scores=[best_scores,GC_score];
            best_scales=[best_scales,(nanmean(d)*2)];

        end
        disp('best radius')
        disp(best_radius(find(best_scores==max(max(best_scores)))));
        disp('best scale')
        disp(best_scales(find(best_scores==max(max(best_scores)))));

        GC_score = max(max(best_scores));

        %**************Estimating BC_measure:***********************************
        BC_score=get_BC_score2(smooth_r_map);  

        %*************Estimating HD_measure:************************************
        [HD_score, rot_angle, r_smooth]=get_Rayleigh_Vector_v2(Rat_dir, cellNr_spikes_coordinates, pos_sampling_rate);
        
        
        %*************Estimating Spatial Info score************************************
        % the following lines are copied from 'batch_cell_function_v3_TV_GC_updated'
        % to get the spatial information score
        
        aaa=pos_map/pos_sampling_rate;
        bbb=aaa(ceil(miny/bin_size):floor(maxy/bin_size), ceil(minx/bin_size):floor(maxx/bin_size));
        bbb(isnan(bbb))=0;

        SI_score=map_skaggsinfo(SpRmap, bbb); %SpRmap %JK:uncomment here 090221
        clear aaa bbb;
        
        
        %% Assigning a cell type category based on the scores
        %the following part is added by PK on 240522 to get the cell type
        %from the scores, based on the thresholds used by JK and TV for
        %the error correction study.
        
%         Cell score thresholds for cell type classification:
%         GC >= 0.27
%         BC >= 2.0
%         HD >= 0.19
%         SC /PC >= 1.3
        
        [cell_type] = get_cell_type_from_scores(GC_score,BC_score,SI_score,HD_score,target_brain_region);
            
    
    
    
end