function [mouse_index,mouse_batch,mouse_implant,reward_type] = get_animal_specs(animalID)

    cd('D:\Projects');
    [~, ~, file_animals] = xlsread('Animals_specs.xlsx');
    
    
    for line = 2:size(file_animals,1)
        
        
        if string(file_animals(line,1)) == string(animalID)

            mouse_index = cell2mat(file_animals(line,2));            
            mouse_batch = cell2mat(file_animals(line,3));
            mouse_implant = string(cell2mat(file_animals(line,4)));
            reward_type = string(cell2mat(file_animals(line,5)));
            
        end
        
        
    end
    
    
end