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










