

function [cluster_list_after_manual_cutting,cluster_list_after_kilo] = get_cluster_list_from_auto_to_manual(path_to_cluster_list_match)

    % this programs gives two lists of clusters, one of pre manual cutting
    % clusters and the other one of post manual cutting matching clusters 
    
    % works only if the pre manual cutting clusters are in column 1 and the
    % post manual cutting in column 5.


    [~, ~, file_match] = xlsread(path_to_cluster_list_match);
    

    cluster_list_after_manual_cutting = [];
    
    cluster_list_after_kilo = [];
    
   
    
    for j = 2:size(file_match,1)

        
        
        if isnan(cell2mat(file_match(j,5))) == 0
            
            
            
            c = char(cell2mat(file_match(j,5)));
            

            j_m = find(c=='m');
            i_m = [1,find(c==',')];
            i_m = sort(i_m);
           
            if length(j_m) >= 1
                %disp(string(c(1:j_m(1)-1)));
                
                for p = 1:length(j_m)
                
                   
                        cluster_list_after_manual_cutting = [cluster_list_after_manual_cutting str2double(string(c(i_m(p)+1:j_m(p)-1)))];
                        cluster_list_after_kilo = [cluster_list_after_kilo cell2mat(file_match(j,1))];
                    
                    
                end
                
            end
            
%             if length(j_m) > 1
%                 for p = 2:length(j_m)
%                     
%                     cluster_list_after_manual_cutting = [cluster_list_after_manual_cutting str2double(string(c(j_m(p-1)+2:j_m(p)-1)))];
%                     cluster_list_after_kilo = [cluster_list_after_kilo cell2mat(file_match(j,1))];
% 
%                 end
%             end

%             if length(j_m) == 2
%                 
% 
%                 cluster_list_after_manual_cutting = [cluster_list_after_manual_cutting str2double(string(c(j_m(1)+2:j_m(2)-1)))];
%                 cluster_list_after_kilo = [cluster_list_after_kilo cell2mat(file_match(j,1))];
%                 
%                 
%             elseif length(j_m) == 3
%                 
%                 cluster_list_after_manual_cutting = [cluster_list_after_manual_cutting str2double(string(c(j_m(1)+2:j_m(2)-1)))];
%                 cluster_list_after_kilo = [cluster_list_after_kilo cell2mat(file_match(j,1))];
%                 
%                 cluster_list_after_manual_cutting = [cluster_list_after_manual_cutting str2double(string(c(j_m(2)+2:j_m(3)-1)))];
%                 cluster_list_after_kilo = [cluster_list_after_kilo cell2mat(file_match(j,1))];
%                 
%                 
%             elseif length(j_m) == 4
%                 
%                 cluster_list_after_manual_cutting = [cluster_list_after_manual_cutting str2double(string(c(j_m(1)+2:j_m(2)-1)))];
%                 cluster_list_after_kilo = [cluster_list_after_kilo cell2mat(file_match(j,1))];
%                 
%                 cluster_list_after_manual_cutting = [cluster_list_after_manual_cutting str2double(string(c(j_m(2)+2:j_m(3)-1)))];
%                 cluster_list_after_kilo = [cluster_list_after_kilo cell2mat(file_match(j,1))];
%                 
%                 cluster_list_after_manual_cutting = [cluster_list_after_manual_cutting str2double(string(c(j_m(3)+2:j_m(4)-1)))];
%                 cluster_list_after_kilo = [cluster_list_after_kilo cell2mat(file_match(j,1))];
%             
% 
%             end

            if isnan(cell2mat(file_match(j,1))) == 1
                
                break;
            end
            
        end
        
    end
    
    
%     disp(cluster_list_after_manual_cutting);
%     disp(cluster_list_after_kilo);


end