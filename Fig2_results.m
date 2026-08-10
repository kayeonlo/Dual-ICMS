% Plot results in Figure 2 C-D.
% the preprint in https://doi.org/10.1101/2025.06.25.661479 has bar plot,
% but here, all the dots are plotted with violin plot, as the latest
% version of the figure

% all_cells.mat contain significantly modulated cells in each category.
% *100 should be applied to make the response %F change as the final plot.
% cell response categories
% E1_RespCellE1,  cells responsive to E1
% E2_RespCellE2,  cells responsive to E2
% E1E2_BiResp Cell,  cells responsive to both E1 and E2 when stimulated
% individually

load all_cells.mat

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 2C, Combine all subpopulations within each stimulation intensity for overall effect
%% Combine all subpopulations within each stimulation intensity

low_all= [];   med_all = [];   high_all = [];
low_all = [RespCellE1_modul_low(:);RespCellE2_modul_low(:);avg_low_bi_change(:);low_nonsig_modul(:)] * 100;
med_all = [RespCellE1_modul(:);RespCellE2_modul(:);avg_med_bi_change(:);med_nonsig_modul(:)] * 100;
high_all = [RespCellE1_modul_high(:);RespCellE2_modul_high(:);avg_high_bi_change(:);high_nonsig_modul(:)] * 100;

% Remove NaNs
low_all  = low_all(~isnan(low_all));
med_all  = med_all(~isnan(med_all));
high_all = high_all(~isnan(high_all));
data = {low_all, med_all, high_all};


%% Plot
figure('Color','w');
hold on;
xpos = [1 2 3];
violinWidth = 0.32;

% Gray shades similar to your original panel C
colors = [
    0.85 0.85 0.85;   % Low
    0.65 0.65 0.65;   % Medium
    0.40 0.40 0.40    % High
    ];

for i = 1:3
    d = data{i};

    %% Kernel density for violin
    [f, yi] = ksdensity(d);

    % Normalize width
    f = f ./ max(f) * violinWidth;

    %% Violin
    patch([xpos(i)-f, fliplr(xpos(i)+f)],[yi, fliplr(yi)],colors(i,:),'FaceAlpha',0.45,'EdgeColor',colors(i,:),'LineWidth',1.3);

    %% Individual neurons
    jitterWidth = 0.16;
    xjitter = xpos(i) +(rand(size(d))-0.5)*2*jitterWidth;
    scatter(xjitter,d,10,'MarkerFaceColor',[0.15 0.15 0.15],'MarkerEdgeColor','none','MarkerFaceAlpha',0.35);


    %% Median
    med = median(d);
    plot([xpos(i)-0.12 xpos(i)+0.12],[med med],'k-','LineWidth',2);

    %% Mean
    mn = mean(d);
    plot(xpos(i),mn,'ko','MarkerFaceColor','w','MarkerSize',5,'LineWidth',1.2);

end
yline(0,'k-','LineWidth',1);

%% Formatting
xlim([0.5 3.5]);

xticks([1 2 3]);
xticklabels({'Low','Medium','High'});
ylabel('Dual-Neuromodulation effect (%)');
xlabel('Stimulation intensity');
title('Dual-Neuromodulation by stim intensity');
set(gca,'FontSize',11,'LineWidth',1.2,'TickDir','out','Box','off');
set(gcf,'Position',[200 200 420 380]);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure 2D, subpopulations 

figure('Color','w');
hold on;

x_labels = {'E1\_Resp Cell', 'E2\_Resp Cell', ...
            'E1E2\_BiResp Cell','Non Resp Cell'};

% Raw data
% rows = cell groups
% columns = Low, Medium, High

data = {
    RespCellE1_modul_low*100,   RespCellE1_modul*100,      RespCellE1_modul_high*100;
    RespCellE2_modul_low*100,   RespCellE2_modul*100,      RespCellE2_modul_high*100;
    avg_low_bi_change*100,      avg_med_bi_change*100,     avg_high_bi_change*100;
    low_nonsig_modul*100,       med_nonsig_modul*100,      high_nonsig_modul*100
    };

% Make sure everything is a column vector
for i = 1:size(data,1)
    for j = 1:size(data,2)
        data{i,j} = data{i,j}(:);
        data{i,j} = data{i,j}(~isnan(data{i,j}));
    end
end


%% Colors for cell groups
groupColor = [
    0.00 0.45 0.05;    % E1 Resp - dark green
    0.00 0.75 0.05;    % E2 Resp - green
    0.75 0.70 0.00;    % BiResp - yellow/olive
    0.45 0.45 0.45     % Non Resp - gray
    ];

%% Positions
groupX = 1:4;

% positions of Low, Medium, High within each group
offset = [-0.25 0 0.25];

violinWidth = 0.08;


%% Background shading like your Panel D

yl = [-200 200];      
ylim(yl);

%% Light gray blocks corresponding to Medium / High positions
for g = 1:4

    % Medium
    rectangle('Position', [groupX(g)-0.10, yl(1), 0.20, diff(yl)],'FaceColor',[0.92 0.92 0.92],'EdgeColor','none');

    % High
    rectangle('Position',[groupX(g)+0.15, yl(1), 0.20, diff(yl)],'FaceColor',[0.75 0.75 0.75],'EdgeColor','none');
end


%% Violin plots+ individual dots

for g = 1:4

    for cond = 1:3

        d = data{g,cond};

        if isempty(d)
            continue
        end

        xpos = groupX(g) + offset(cond);

        % Kernel density
        [f,yi] = ksdensity(d);

        % Normalize violin width
        f = f ./ max(f) * violinWidth;

        % Transparency according to stimulation intensity
        switch cond
            case 1      % Low
                alphaValue = 0.25;
            case 2      % Medium
                alphaValue = 0.40;
            case 3      % High
                alphaValue = 0.55;
        end

        % Violin plot, with individual dots
        patch([xpos-f fliplr(xpos+f)], ...
              [yi fliplr(yi)], ...
              groupColor(g,:), ...
              'FaceAlpha',alphaValue, ...
              'EdgeColor',groupColor(g,:), ...
              'LineWidth',1);

        % Individual cells
        jitterWidth = 0.09;
        xjitter = xpos + (rand(size(d))-0.5)*2*jitterWidth;
        scatter(xjitter,d,12,'MarkerFaceColor',groupColor(g,:),'MarkerEdgeColor','k','MarkerFaceAlpha',0.55,'MarkerEdgeAlpha',0.25);

        % Median
        med = median(d);
        plot([xpos-0.09 xpos+0.09], ...
             [med med], ...
             'k-', ...
             'LineWidth',2);
        % Mean
        mn = mean(d);
        plot(xpos,mn,'ko', ...
            'MarkerFaceColor','w', ...
            'MarkerSize',5, ...
            'LineWidth',1.2);
    end
end


%% Zero line
yline(0,'k-','LineWidth',1.2);
xlim([0.5 4.5]);
ylim(yl);
xticks(1:4);
xticklabels(x_labels);
ax = gca;
ax.FontSize = 12;
ax.LineWidth = 1.2;
ax.TickDir = 'out';
ax.Box = 'off';

ylabel('Dual-Neuromodulation effect (%)','FontSize',13);
title('Dual-Neuromodulation by subpopulations','FontSize',13,'FontWeight','bold');


%% Color x-axis labels manually
% Standard MATLAB does not allow individual xtick colors easily,
% so add colored text and remove normal labels.

xticklabels({});
labelY = -150;
for g = 1:4
    text(groupX(g),labelY,x_labels{g},'Color',groupColor(g,:),'HorizontalAlignment','right','Rotation',20,'FontSize',13,'FontWeight','bold');
end
set(gca,'ylim',[-200 240])

h1 = patch(NaN,NaN,[1 1 1],'EdgeColor',[0.6 0.6 0.6],'LineStyle','--');
h2 = patch(NaN,NaN,[0.92 0.92 0.92],'EdgeColor','none');
h3 = patch(NaN,NaN,[0.75 0.75 0.75],'EdgeColor','none');
legend([h1 h2 h3],{'Low','Medium','High'},'Location','northeast','Box','off');


%% Final size
set(gcf,'Position',[200 200 650 380]);
