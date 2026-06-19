function [cell_type] = get_cell_type_from_scores(GC_score,BC_score,SI_score,HD_score,target_brain_region)

    cell_type = string("unclassified");

    if GC_score >= 0.27
            cell_type = string('GC');
    else

        if target_brain_region == string('CA1')

            if SI_score >= 1.3 || BC_score >= 2 % then it's a spatial cell
                cell_type = string('PC');
            end
            
        else
   
            if BC_score >= 2
                cell_type = string('BC');
            else
                if SI_score >= 1.3 %HD_score >= 0.19 %SI_score >= 1.3
                    cell_type = string('SC');

                elseif SI_score < 1.3 && HD_score >= 0.19
                    cell_type = string('HD');
                end
            end

        end
    end
    
end
