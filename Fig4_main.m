% source data and codes for Fig4 main results
clear

load Fig4_distanceToA.mat % relative distance between neuronal soma and electrode 1(E1)
% distance in um
% all_modul: this variable contains change F/F (%) pre-calculated
% 
% x, RespCellE1, medium
% x5, RespCellE2 , medium
% x9, bimodal cells , medium

% x3, RespCellE1, high
% x7, RespCellE2 , high
% x10, bimodal cells , high

% combine all cells and see the distance, relative distance to A (E1)
% medium stimulation intensity
all_cells_dist = [];   % relative distance between neuronal soma and electrode 1(E1)
all_modul = [];
all_cells_dist = [x x5 x9];   % medium, RespcellE1, E2, bimodal
all_modul = [y y5 y9]; % modulation % in F%

% high stimulation intensity
high_all_cells_dist = [];  high_all_modul = [];
high_all_cells_dist = [x3 x7 x10];   % high
high_all_modul = [y3 y7 y10];

% medium condition
figure; 
subplot(2,2,1);
scatter(x,y,10,'ko', 'filled', 'MarkerEdgeColor', [0.30 0.55 0.25],'MarkerFaceColor',[0.30 0.55 0.25]); % RespCell E1
hold on; 
scatter(x5,y5,10,'ko', 'filled', 'MarkerEdgeColor', [0.35 0.90 0.25],'MarkerFaceColor',[0.35 0.90 0.25]); % RespCell E2
scatter(x9,y9,10,'ko', 'filled', 'MarkerEdgeColor', [0.70 0.78 0.32],'MarkerFaceColor',[0.70 0.78 0.32]); % E1E2_BiResp Cell
set(gca,'xlim',[0 500],'xtick',0:100:500,'xticklabel',0:100:500,'ylim',[-200 200],'FontSize',9)

[x_sorted_all, sort_idx_all] = sort(all_cells_dist);
y_sorted_all = all_modul(sort_idx_all);
fitted_y_all = smooth(x_sorted_all, y_sorted_all, 0.6, 'lowess'); % 'Span' = 0.2 controls smoothing
hold on;
plot(x_sorted_all, fitted_y_all,'k-', 'color',[0.7 0.7 0.7],'LineWidth', 2); % Red line for LOESS curve
set(gca,'xlim',[0 500],'xtick',0:100:500,'xticklabel',0:100:500,'FontSize',9)
xlabel('Soma distance from E1 (\mum)', 'Interpreter', 'latex');
ylabel('Dual-neuromodulation effect', 'Interpreter', 'latex');
title('Medium intensity')


% high condition
subplot(2,2,2);
scatter(x3,y3,10,'ko', 'filled', 'MarkerEdgeColor', [0.30 0.55 0.25],'MarkerFaceColor',[0.30 0.55 0.25]); % RespCell E1
hold on; 
scatter(x7,y7,15,'ko', 'filled', 'MarkerEdgeColor', [0.35 0.90 0.25],'MarkerFaceColor',[0.35 0.90 0.25]); % RespCell E2
scatter(x10,y10,10,'ko', 'filled', 'MarkerEdgeColor', [0.70 0.78 0.32],'MarkerFaceColor',[0.70 0.78 0.32]); % E1E2_BiResp Cell

set(gca,'xlim',[0 500],'xtick',0:100:500,'xticklabel',0:100:500,'ylim',[-200 200],'FontSize',9)
[high_x_sorted_all, high_sort_idx_all] = sort(high_all_cells_dist);
high_y_sorted_all = high_all_modul(high_sort_idx_all);
high_fitted_y_all = smooth(high_x_sorted_all, high_y_sorted_all, 0.6, 'lowess'); % 'Span' = 0.2 controls smoothing
hold on;
plot(high_x_sorted_all, high_fitted_y_all, 'k-','LineWidth', 2); % Red line for LOESS curve
xlabel('Soma distance from E1 (\mum)', 'Interpreter', 'latex');
ylabel('Dual-neuromodulation effect', 'Interpreter', 'latex');
title('high intensity')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load Fig4_distanceToB.mat % relative distance between neuronal soma and electrode 2(E2)
% distance in um
% all_modul: this variable contains change F/F (%) pre-calculated

% combine all cells and see the distance, relative distance to B (E2)
all_cells_dist = [];   all_modul = [];
all_cells_dist = [x2 x6 x11];   % medium, RespcellE1, E2, bimodal
all_modul = [y2 y6 y11];

high_all_cells_dist = [];  high_all_modul = [];
high_all_cells_dist = [x4 x8 x12];   % high
high_all_modul = [y4 y8 y12];

% x2, RespCellE1, medium
% x6, RespCellE2 , medium
% x11, bimodal cells , medium

% x4, RespCellE1, high
% x8, RespCellE2 , high
% x12, bimodal cells , high

subplot(2,2,3);
scatter(x2,y2,10,'ko', 'filled', 'MarkerEdgeColor', [0.30 0.55 0.25],'MarkerFaceColor',[0.30 0.55 0.25]);
hold on; 
scatter(x6,y6,15,'ko', 'filled', 'MarkerEdgeColor', [0.35 0.90 0.25],'MarkerFaceColor',[0.35 0.90 0.25]);
scatter(x11,y11,10,'ko', 'filled', 'MarkerEdgeColor', [0.70 0.78 0.32],'MarkerFaceColor',[0.70 0.78 0.32]);

[x_sorted_all, sort_idx_all] = sort(all_cells_dist);
y_sorted_all = all_modul(sort_idx_all);
fitted_y_all = smooth(x_sorted_all, y_sorted_all, 0.6, 'lowess'); % 'Span' = 0.2 controls smoothing
hold on;
plot(x_sorted_all, fitted_y_all, 'k-','color',[0.7 0.7 0.7], 'LineWidth', 2); % Red line for LOESS curve
xlabel('Soma distance from E2 (\mum)', 'Interpreter', 'latex');
ylabel('Dual-neuromodulation effect', 'Interpreter', 'latex');
title('Medium intensity')


subplot(2,2,4);
scatter(x4,y4,10,'ko', 'filled', 'MarkerEdgeColor', [0.30 0.55 0.25],'MarkerFaceColor',[0.30 0.55 0.25]);
hold on; 
scatter(x8,y8,15,'ko', 'filled', 'MarkerEdgeColor', [0.35 0.90 0.25],'MarkerFaceColor',[0.35 0.90 0.25]);
scatter(x12,y12,10,'ko', 'filled', 'MarkerEdgeColor', [0.70 0.78 0.32],'MarkerFaceColor',[0.70 0.78 0.32]);
set(gca,'xlim',[0 1000],'xtick',0:250:1000,'xticklabel',0:250:1000,'ylim',[-200 200],'FontSize',9)
[high_x_sorted_all, high_sort_idx_all] = sort(high_all_cells_dist);
high_y_sorted_all = high_all_modul(high_sort_idx_all);
high_fitted_y_all = smooth(high_x_sorted_all, high_y_sorted_all, 0.6, 'lowess'); % 'Span' = 0.2 controls smoothing
plot(high_x_sorted_all, high_fitted_y_all, 'k-','LineWidth', 2); % Red line for LOESS curve
xlabel('Soma distance from E2 (\mum)', 'Interpreter', 'latex');
ylabel('Dual-neuromodulation effect', 'Interpreter', 'latex');
title('High intensity')
























