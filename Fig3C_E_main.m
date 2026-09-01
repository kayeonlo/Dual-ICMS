%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot_Fig3C_E1.m

% Reproduce Fig3. C: correlation between single- and dual-electrode responses
% in E1-responsive cells.
% The original manuscript figure marks the histogram bin that has at least
% one significant correlation, but this plot shows marks ths green bin
% indicating the actual nubmer of significantly correlated cells in each
% bin. 
% the final statistics was performed as a population level, combining all
% cells recorded. Check Figure 3H with the number of cells showing
% significant correlation vs. significant dual-neuromodulation


% in the source data (Fig3C_E1_source_data.mat), med_coef_r_respE1{site},
% the variables are saved in per mouse manner.
% using these numbers, further analysis can be done per mouse level.

clear; clc;
load('Fig3C_E1_source_data.mat');

green = [0 0.5 0];

figure('Color','w','Position',[100 100 700 300]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MEDIUM INTENSITY
% Combine cells across recording sites/mice
r = [med_coef_r_respE1{:}];
p_pos = [med_monte_p_respE1_pos{:}];
p_neg = [med_monte_p_respE1_neg{:}];
% Fisher z-transform
z = atanh(r);
% Significant correlation from permutation test
sig = (p_pos < 0.025) | (p_neg < 0.025);
% Population statistics
[~,p_med] = ttest(z);
fprintf('Medium: N = %d cells\n', length(z));
fprintf('Mean z = %.3f\n', mean(z));
fprintf('t-test p = %.4g\n', p_med);
fprintf('Significant cells = %d\n\n', sum(sig));
% ----- Plot -----
subplot(1,2,1)
h = histogram(z,20,'FaceColor',green,'EdgeColor','w');
hold on
edges = h.BinEdges;
% Count significant cells in each bin
sig_counts = histcounts(z(sig),edges);
% Overlay significant cells in green
bar(edges(1:end-1) + diff(edges)/2,sig_counts,1,'FaceColor',green,'EdgeColor','k','lineWidth',1);
% Mean
xline(mean(z),'k-','LineWidth',1.5);
xlabel('z (r)');
ylabel('Number of cells');
title('Medium intensity');
xlim([-1.5 2.7]);
ylim([0 60]);
box off;
set(gca,'FontSize',11);

%%%%%%%%%%%%%%%%%%%%%%%%
% HIGH INTENSITY
r = [high_coef_r_respE1{:}];
p_pos = [high_monte_p_respE1_pos{:}];
p_neg = [high_monte_p_respE1_neg{:}];
% Fisher z-transform
z = atanh(r);
% Significant correlation from permutation test
sig = (p_pos < 0.025) | (p_neg < 0.025);
% Population statistics
[~,p_high] = ttest(z);
fprintf('High: N = %d cells\n', length(z));
fprintf('Mean z = %.3f\n', mean(z));
fprintf('t-test p = %.4g\n', p_high);
fprintf('Significant cells = %d\n', sum(sig));

% ----- Plot -----
subplot(1,2,2)
h = histogram(z,20,'FaceColor',green,'EdgeColor','w');
hold on
edges = h.BinEdges;
sig_counts = histcounts(z(sig),edges);
bar(edges(1:end-1) + diff(edges)/2,sig_counts,1,'FaceColor',green,'EdgeColor','k','lineWidth',1);
xline(mean(z),'k-','LineWidth',1.5);
xlabel('z (r)');
ylabel('Number of cells');
title('High intensity');
xlim([-1.5 2.7]);
ylim([0 60]);
box off;
set(gca,'FontSize',11);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Individual mouse mean +/- SEM
% E1-responsive cells
clear; clc;
load('Fig3C_E1_source_data.mat');
green = [0 0.5 0];
figure('Color','w','Position',[100 100 650 300]);

% Medium intensity
subplot(1,2,1);
hold on;
m = 0;
mouse_mean = [];
mouse_sem  = [];

for isite = 1:length(med_coef_r_respE1)
    if ~isempty(med_coef_r_respE1{isite})
        m = m + 1;
        r = med_coef_r_respE1{isite};
        % Mean
        mouse_mean(m) = mean(r);
        % Correct SEM
        mouse_sem(m) = std(r) / sqrt(length(r));
    end
end
% Plot mean +/- SEM for each mouse
for i = 1:m
    errorbar(i, mouse_mean(i), mouse_sem(i), ...
        'o-', ...
        'LineWidth',2, ...
        'CapSize',10, ...
        'Color',green, ...
        'MarkerFaceColor',green);
end
yline(0,'k:');
xlim([0 m+1]);
ylim([-0.5 1]);
xticks(1:m);
xlabel('Mouse');
ylabel('Correlation coefficient (r)');
title('Medium intensity');
box off;
set(gca,'FontSize',11);

% High intensity
subplot(1,2,2);
hold on;
m = 0;
mouse_mean = [];
mouse_sem  = [];
for isite = 1:length(high_coef_r_respE1)
    if ~isempty(high_coef_r_respE1{isite})
        m = m + 1;
        r = high_coef_r_respE1{isite};
        % Mean
        mouse_mean(m) = mean(r);
        % Correct SEM
        mouse_sem(m) = std(r) / sqrt(length(r));
    end
end
% Plot mean +/- SEM for each mouse
for i = 1:m
    errorbar(i, mouse_mean(i), mouse_sem(i), ...
        'o-', ...
        'LineWidth',2, ...
        'CapSize',10, ...
        'Color',green, ...
        'MarkerFaceColor',green);
end
yline(0,'k:');
xlim([0 m+1]);
ylim([-0.5 1]);
xticks(1:m);
xlabel('Mouse');
ylabel('Correlation coefficient (r)');
title('High intensity');
box off;
set(gca,'FontSize',11);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reproduce Fig3. E: scatter plots, dual-neuromodulation effect as a
% function of Response amplitude of single electrode stimulation 
% The source data below contains 

load Fig3E_source_data.mat

figure;  % RespcellE1, medium intensity
subplot(2,2,1);
scatter(all_cells_RespCellE1_single*100,E1all_sigmodul_amp*100, 50,'k.', 'filled', 'MarkerEdgeColor', [0.6 0.6 0.6]);
hold on;
xlabel('E1')
ylabel('coE1E2 -(E1+E2)','FontSize',10)
x = all_cells_RespCellE1_single*100;
y = E1all_sigmodul_amp*100;
[x_sorted, sort_idx] = sort(x);
y_sorted = y(sort_idx);
fitted_y = smooth(x_sorted, y_sorted, 0.6, 'lowess'); % 'Span' = 0.2 controls smoothing
y_fit_RespcellE1(:,1) = fitted_y;
y_fit_RespcellE1(:,2) = x_sorted;
plot(x_sorted, fitted_y, 'k-', 'LineWidth', 2); % Red line for LOESS curve


subplot(2,2,2);   % RespcellE1, high intensity
scatter(high_all_cells_RespCellE1_single*100,high_E1all_sigmodul_amp*100, 50,'k.', 'filled', 'MarkerEdgeColor', [0.6 0.6 0.6]);
hold on;
x = high_all_cells_RespCellE1_single*100;
y = high_E1all_sigmodul_amp*100;
[x_sorted, sort_idx] = sort(x);
y_sorted = y(sort_idx);
fitted_y = smooth(x_sorted, y_sorted, 0.6, 'lowess'); % 'Span' = 0.2 controls smoothing
high_y_fit_RespcellE1(:,1) = fitted_y;
high_y_fit_RespcellE1(:,2) = x_sorted;
plot(x_sorted, fitted_y, 'k-', 'LineWidth', 2); % Red line for LOESS curve


subplot(2,2,3);  % Non responsive cells, medium intensity
scatter(single*100,nonresp_sigmodul_amp*100, 90,'k.', 'filled', 'MarkerEdgeColor', [0.6 0.6 0.6]);
hold on;
xlabel('single (E1+E2)')
ylabel('coE1E2 -(E1+E2)','FontSize',11)

x = single*100;
y = nonresp_sigmodul_amp*100;
x_sorted = [];  sort_idx = [];
[x_sorted, sort_idx] = sort(x);
y_sorted = y(sort_idx);
fitted_y = smooth(x_sorted, y_sorted, 0.6, 'lowess'); % 'Span' = 0.2 controls smoothing
y_fit_nonsig = [];
y_fit_nonsig(:,1) = fitted_y;
y_fit_nonsig(:,2) = x_sorted;
plot(x_sorted, fitted_y, 'k-', 'LineWidth', 2); % Red line for LOESS curve


subplot(2,2,4);  % Non responsive cells, high intensity
scatter(high_single*100,high_nonresp_sigmodul_amp*100, 90,'k.', 'filled', 'MarkerEdgeColor', [0.6 0.6 0.6]);
hold on;
x = high_single*100;
y = high_nonresp_sigmodul_amp*100;
x_sorted = [];  sort_idx = [];
[x_sorted, sort_idx] = sort(x);
y_sorted = y(sort_idx);
fitted_y = smooth(x_sorted, y_sorted, 0.6, 'lowess'); % 'Span' = 0.2 controls smoothing
high_y_fit_nonsig = [];
high_y_fit_nonsig(:,1) = fitted_y;
high_y_fit_nonsig(:,2) = x_sorted;
plot(x_sorted, fitted_y, 'k-', 'LineWidth', 2); % Red line for LOESS curve






%%%%% source code for obtaining 95% confidence interval to the fitting
%%%%% boostrapping method to add CI in the plot
% inputs:  x_sorted, y_sorted


n_boot = 2000;
n_points = length(x_sorted);
bootstrap_fits = zeros(n_boot, n_points);
lowess_wt = 0.6;

[bootstrap_fits] = run_smoothfit_bootstrap(n_boot,n_points,x_sorted,y_sorted,lowess_wt);
% Compute confidence intervals
lower_CI = prctile(bootstrap_fits, 2.5, 1);  % 2.5th percentile
upper_CI = prctile(bootstrap_fits, 97.5, 1); % 97.5th percentile

x_shade = x_sorted(4:end);
upper_CI_shade = upper_CI(4:end);
lower_CI_shade = lower_CI(4:end);

x_shade = x_shade(:);  
lower_CI_shade = lower_CI_shade(:);
upper_CI_shade = upper_CI_shade(:);

fill([x_shade; flipud(x_shade)], [lower_CI_shade; flipud(upper_CI_shade)], ...
     'k', 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off'); 
plot(x_sorted, fitted_y, 'k-', 'LineWidth', 2); % Red line for LOESS curve


function [bootstrap_fits] = run_smoothfit_bootstrap(n_boot,n_points,x_sorted,y_sorted,lowess_wt)

% Perform bootstrapping
for i = 1:n_boot
    % Generate resampled indices
    resample_idx = randi(n_points, n_points, 1);
    
    % Resample x and y
    x_resample = x_sorted(resample_idx);
    y_resample = y_sorted(resample_idx);
    
    % Sort resampled data
    [x_resample_sorted, resample_sort_idx] = sort(x_resample);
    y_resample_sorted = y_resample(resample_sort_idx);
    
    % Apply LOWESS smoothing on resampled data
    bootstrap_fits(i, :) = smooth(x_resample_sorted, y_resample_sorted, lowess_wt, 'lowess');
end










