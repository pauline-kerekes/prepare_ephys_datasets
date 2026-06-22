[~, ~, cell_list] = xlsread('E:\mHYK24\170626\a_shankmix4_17062026_g0__b_shankmix4_17062026_g0\cell_type_classification\cell_list_classification.xlsx');
load('E:\mHYK24\170626\a_shankmix4_17062026_g0__b_shankmix4_17062026_g0\cell_type_classification\classification_scores.mat');

clusters = cell2mat(cell_list(2:end,1));
cell_types = string(cell_list(2:end,3));

% get the scores for that session
figure;iplot=1;
for score_type = [string('GC_scores'),string('BC_scores'),string('SI_scores'),string('HD_scores')]
    subplot(2,4,iplot)
    scores_type = scores{:,[score_type]};
    cl = scores{:,["clusters"]};
    ii=1;
    for cell_type = [string('GC'),string('BC'),string('SC'),string('HD'),string('unclassified')]
        clusters_celltype = clusters(cell_types==cell_type);
        scores_ = scores_type(ismember(clusters,clusters_celltype));
        bar(ii,nanmean(scores_));
        hold on;
        ii=ii+1;
    end
    iplot=iplot+1;
end