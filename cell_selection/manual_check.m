


function manual_check(ephysKilosortPath)

    %% experimentalist manual check of the false positive 
    % load the data
    tic;
%     toy_dataset_location = 'D:\mHYK20\180426\a_shankmix1_18042026_g0__b_shankmix1_18042026_g0'; 
    cd(strcat(ephysKilosortPath,'\bombcell'));
    qMetric = parquetread('qmetrics_pk.parquet');
    cluster_indices = qMetric{:,["phy_clusterID"]};
    best_channels_bombcell = qMetric{:,["maxChannels"]};
    load('units_classification_pk.mat', 'unitType');

    load(strcat(ephysKilosortPath,'\waveforms_check\waveforms_for_manual_check.mat'),'array_waveforms_for_display','units_good_for_array','array_noise_for_display','units_noise_for_array');

    cells_to_remove = [];
    all_cells = [];


    % Create the UI figure
    % Get the screen size
    screenSize = get(0, 'ScreenSize');
    screenWidth = screenSize(3);
    screenHeight = screenSize(4);
    % Define the default figure width and height
    figWidth = 600;%560;  % Default MATLAB figure width
    figHeight = 800; %420; % Default MATLAB figure height
    % Define an offset from the top of the screen
    topOffset = 100;  % Adjust this value as needed
    % Calculate the position for the new figures
    position = [screenWidth-figWidth, screenHeight-figHeight-topOffset, figWidth, figHeight];
    % Set the default figure position
    set(0, 'DefaultFigurePosition', position);
    figure;
    %
    iplott = 1;
    for cell_i = 1:length(array_waveforms_for_display)%1:max(npy_spike_clusters)%1:1593 %cluster_list_after_manual_cutting

        if isempty([array_waveforms_for_display{1,cell_i}]) == 0

            subplot(7,4,iplott);
            array_wf = [array_waveforms_for_display{1,cell_i}];
            for iwaveform = 1:size(array_wf,1)
                plot(array_wf(iwaveform,:),'Color',[rand,rand,rand],'LineWidth',0.8);
                hold on;
                yticks([]);
                xticks([]);
                title(num2str(units_good_for_array(1,cell_i)));
            end
            iplott=iplott+1;
            all_cells = [all_cells,units_good_for_array(1,cell_i)];


            if iplott > 28
                
                prompt = "to remove (in the form [1,2,4])";
                value_field2 = input(prompt);
                cells_to_remove = [cells_to_remove,value_field2];

                iplott=1;
                close all;
                figure;

            end

        else
            break;
        end
    end
    toc;
    
    disp(strcat('N false positive = ',num2str(length(cells_to_remove)),'/',num2str(length(units_noise_for_array)+length(units_good_for_array))));
    
    new_cells = all_cells;
    for iii = cells_to_remove
        new_cells(new_cells==iii) = [];
    end
    
    
    %% go through the noise for the false negative
    %%
    % Get the screen size
    screenSize = get(0, 'ScreenSize');
    screenWidth = screenSize(3);
    screenHeight = screenSize(4);
    % Define the default figure width and height
    figWidth = 600;%560;  % Default MATLAB figure width
    figHeight = 800; %420; % Default MATLAB figure height
    % Define an offset from the top of the screen
    topOffset = 100;  % Adjust this value as needed
    % Calculate the position for the new figures
    position = [screenWidth-figWidth, screenHeight-figHeight-topOffset, figWidth, figHeight];
    % Set the default figure position
    set(0, 'DefaultFigurePosition', position);
    figure;
    %
    
    %%
    iplott = 1;
    false_negatives = [];
    for cell_i = 1:length(array_noise_for_display)%1:max(npy_spike_clusters)%1:1593 %cluster_list_after_manual_cutting

        if isempty([array_noise_for_display{1,cell_i}]) == 0

            subplot(4,4,iplott);
            array_wf = [array_noise_for_display{1,cell_i}];
            for iwaveform = 1:size(array_wf,1)
                plot(array_wf(iwaveform,:),'Color',[rand,rand,rand],'LineWidth',0.8);
                hold on;
                yticks([]);
                xticks([]);
                title(num2str(units_noise_for_array(1,cell_i)));
            end
            iplott=iplott+1;
            all_cells = [all_cells,units_noise_for_array(1,cell_i)];


            if iplott > 16
                
                prompt = "which cells should be added? (put a list of numbers in the form [1,2,4] or [] if none should be removed)";
                value_field2 = input(prompt);
                false_negatives = [false_negatives,value_field2];


                iplott=1;
                close all;
                figure;

            end

        else
            break;
        end
    end
    toc;

    new_cells = [new_cells,false_negatives];

    disp(strcat('N false negative = ',num2str(length(false_negatives)),'/',num2str(length(units_noise_for_array)+length(units_good_for_array))));

    
end




