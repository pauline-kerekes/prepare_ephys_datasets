
folder_session = 'E:\mHYK24\170626\a_shankmix4_17062026_g0__b_shankmix4_17062026_g0\';

[~, ~, cell_list] = xlsread(strcat(folder_session,'cell_type_classification\cell_list_classification_checked.xlsx'));
load(strcat(folder_session,'cell_type_classification\classification_scores.mat'));

clusters = cell2mat(cell_list(2:end,1));
cell_types = string(cell_list(2:end,3));
ctypes = [string('GC'),string('BC'),string('SC'),string('HD_low_SI'),string('UN_low_SI')];

% get the scores for that session
figure;iplot=1;
for score_type = [string('GC_scores'),string('BC_scores'),string('SI_scores'),string('HD_scores')] %
    subplot(3,4,iplot)
    scores_type = scores{:,[score_type]};
    cl = scores{:,["clusters"]};
    ii=1;
    nb=[];
    for cell_type = [string('GC'),string('BC'),string('SC'),string('HD_low_SI'),string('UN_low_SI')]
        clusters_celltype = clusters(cell_types==cell_type);
        scores_ = scores_type(ismember(clusters,clusters_celltype));
        bar(ii,nanmean(scores_));
        hold on;
        errorbar(ii,nanmean(scores_),std(scores_)./sqrt(length(scores_)),'Color','k');
        hold on;
        xticks(1:length([string('GC'),string('BC'),string('SC'),string('HD_low_SI'),string('UN_low_SI')]));
        xticklabels([string('GC'),string('BC'),string('SC'),string('HD_low_SI'),string('UN_low_SI')]);
        xtickangle(45);
        ylabel(score_type);
        ii=ii+1;
        if iplot==1
            nb=[nb,length(scores_)];
        end
    end
    
    ii=1;
    if iplot==1
        subplot(3,4,5);
        for ii=1:length(ctypes)
            text(0.1,0.1+0.1*ii,strcat(ctypes(ii),'=',num2str(nb(ii))));
        end
        title('N cells per cell type');
    end
    iplot=iplot+1;
    
    
end


h=gcf;
set(h,'PaperOrientation','landscape');
set(h,'PaperUnits','normalized');
set(h,'PaperPosition', [0 0 0.9 0.9]);
print(strcat(folder_session,'\cell_type_classification\scores_per_cell_type'),'-dpdf');
close all;