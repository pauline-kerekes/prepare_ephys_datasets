

function [list_animals_cut_log,list_sessions_cut_log,list_proj_cut_log,list_kilo_cut_log,list_TTL_log,list_shankmix_log,list_protocols_log,list_VE_indices_log,list_npixels_log,list_exps_location_log] = get_sessions_from_cutting_log_apr24(path_to_cutting_log, mouse)
  
    if mouse ~= string('none')
        [~, ~, file_exp] = xlsread(strcat(path_to_cutting_log),mouse);
    else
        [~, ~, file_exp] = xlsread(strcat(path_to_cutting_log));
    end
    
    
    list_animals_cut_log = [];
    list_sessions_cut_log = [];
    list_proj_cut_log = [];
    list_kilo_cut_log = [];
    list_TTL_log = [];
    list_shankmix_log = [];
    list_protocols_log = [];
    list_VE_indices_log = [];
    list_npixels_log = [];
    list_exps_location_log = [];
    
    first_line=string(file_exp(1,:));
    column_ok = find(first_line==string('generate mats'));
    colanimal = find(first_line==string('animalID'));
    colsession = find(first_line==string('session'));
    colproj = find(first_line==string('project'));
    colkilo = find(first_line==string('kilosort version'));
    colTTL = find(first_line==string('TTL type'));
    colmapping = find(first_line==string('mapping'));
    colprotocol = find(first_line==string('protocol'));
    colVEindex = find(first_line==string('VE rec index'));
    colnpixels = find(first_line==string('N pixels per meter'));
    colexploc = find(first_line==string('Experiments location'));
    
    for i_line = 2:size(file_exp,1) % i do a loop instead of just indexing to check the session names - some miss a '0' 
        %at the beginning when they are read from excel and I want to correct for that.
       
            if string(file_exp(i_line,column_ok)) == string('y')
                
                    s = string(file_exp(i_line,colsession));
                    s = char(s);
                    
                    if length(s) == 5
                        session_to_add = '0'+string(s(1:end));
                    else
                        session_to_add = string(s(1:end));
                    end      
                    
                    session_to_add = string(session_to_add);
                    
                    list_animals_cut_log = [list_animals_cut_log string(file_exp(i_line,colanimal))];
                    list_sessions_cut_log = [list_sessions_cut_log session_to_add];
                    list_proj_cut_log = [list_proj_cut_log string(file_exp(i_line,colproj))];
                    list_kilo_cut_log = [list_kilo_cut_log file_exp(i_line,colkilo)];
                    list_TTL_log = [list_TTL_log cell2mat(file_exp(i_line,colTTL))];
                    list_shankmix_log = [list_shankmix_log, string(cell2mat(file_exp(i_line,colmapping)))];
                    list_protocols_log = [list_protocols_log, string(cell2mat(file_exp(i_line,colprotocol)))];
                    
                    list_VE_indices_log = [list_VE_indices_log, cell2mat(file_exp(i_line,colVEindex))];
                    
                    list_npixels_log = [list_npixels_log, cell2mat(file_exp(i_line,colnpixels))];
                    
                    list_exps_location_log = [list_exps_location_log,string(cell2mat(file_exp(i_line,colexploc)))];
              
            end           
            
    end



end



