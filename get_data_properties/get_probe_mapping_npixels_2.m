
% all the mapping of the probes mix were reported manually from my notes,
% and the report was double checked by Marino and Pauline (071123)


function [general_mapping_NPX20, mapping_session] = get_probe_mapping_npixels_2(mouse, mapping, mapping_list)

    general_mapping_NPX20 = [[4;2;8;6;7;5;3;1],[3;1;7;5;8;6;4;2],[8;6;4;2;3;1;7;5],[7;5;3;1;4;2;8;6]];

    if contains(string(mapping),string('shank')) == 0 % if it's not a full individual shank but a mix of several shanks
        
        [~, ~, maplist] = xlsread(mapping_list);

        first_line=string(maplist(1,:));
        col_mouse = find(first_line==string('mouse'));
        col_mix = find(first_line==string('shank mix'));
        colshank0 = find(first_line==string('shank 0'));
        colshank3 = find(first_line==string('shank 3'));


        col1 = string(maplist(:,col_mouse));
        col2 = string(maplist(:,col_mix));

        df = find(string(col1)==mouse & string(col2)==mapping);

        if isempty(df) == 0
            ishank_ = 1;
            for coli = colshank0:colshank3
                mapp = [];
                if ismissing(cell2mat(maplist(df,coli))) == 0
                    ch_tmp = string(cell2mat(maplist(df,coli)));
                    ch = char(ch_tmp);
                    for ich = 1:length(ch)
                        if ch(ich) ~= ','
                             mapp = [mapp,str2double(ch(ich))];
                        end
                    end
                end
                % mapping_session{coli-3} = mapp;
                mapping_session{1,ishank_} = mapp;
                ishank_ = ishank_ + 1;
            end
            
        else
            disp('problem: can not find the mix used for recordings');
            keyboard;

        end

        
    else
        
        if mapping == string('shank0')
            mapping_session = {[1:8],[],[],[]};
        elseif mapping == string('shank1')
            mapping_session = {[],[1:8],[],[]};
        elseif mapping == string('shank2')
            mapping_session = {[],[],[1:8],[]};
        elseif mapping == string('shank3')
            mapping_session = {[],[],[],[1:8]};
        else
            disp('problem: can not find the mix used for recordings');
            mapping_session = {[],[],[],[]};
            disp(mouse);
            disp(mapping);
%             keyboard;
        end
   
    end
    
end



