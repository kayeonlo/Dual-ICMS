folder = "C:\Users\User1\Documents\Victor\AAA okay data";
cd(folder);

X_new = [];
Y_new = [];

brl_all = {};

%% Electric field
EFfile = dir('C:\Users\User1\Documents\Victor\AAA okay data\EField Simulation\*.txt'); %get list of text files in specified folder
EFcell = cell(length(EFfile),1); %create empty cell array to store the processed data

% loop through each file, extract the relevant data (last column) and store in cell array
for i = 1:length(EFfile)
    % Construct the full path to the file
    fullFilePath = fullfile(EFfile(i).folder, EFfile(i).name);

    % Read the file into a table, skipping the first 8 lines, using multiple spaces as delimiter
    FileSkip = readtable(fullFilePath, 'Delimiter', ' ', 'MultipleDelimsAsOne', true, 'HeaderLines', 8);

    % Check if the file has at least 4 columns
    if size(FileSkip, 2) >= 4
        % Extract the 4th column, skipping the header row
        EFcolumn = FileSkip{:, 4};

        % Store the column data in the cell array
        EFcell{i} = EFcolumn;
    end
end

%% make sure that everything is in microns (not in pixels) and that if you use coordinates, you shift them to a common point of reference - the electrode in the field of view
%% if include datasets with different GECIs,  normalize by uptake rate/calcium affinity

%% N75-15uA
N75_ROI_16_both_15uA = ReadImageJROI("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M75\15uA\Both_RoiSet.zip"); % extract ROIs of both electrodes from each dataset
N75_ROI_16_both_15uA_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M75\15uA\both measure.csv");
N75_ROI_15_right_15uA_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M75\15uA\right measure.csv");
N75_ROI_17_left_15uA_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M75\15uA\left measure.csv");
N75_16_both_15uA_stim_intensity = 15;
N75_16_both_15uA_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M75\15uA\16_Both 15uA 500ms 10 trials_mcor.tif - C=0.tif"); % import tif file
N75_15_right_15uA_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M75\15uA\15_rightA 15uA 500ms 10 trials_mcor.tif - C=0.tif"); % import tif file
N75_17_left_15uA_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M75\15uA\17_leftB 15uA 500ms 10 trials_mcor.tif - C=0.tif"); % import tif file

N75_elect = readtable("75_MicroElect_05242024_thy1gcamp6_twoelect_2e/Electrode coordinates widefiled.csv"); % load electrode positions in widefield
N75_elect_2p = readtable("75_MicroElect_05242024_thy1gcamp6_twoelect_2e\Electrode coordinates 2p.csv"); % load fov electrode position in 2p
N75_electA = [N75_elect.X(1),N75_elect.Y(1)]; %electrode in field of view widefield
N75_electA_2p = [N75_elect_2p.X,N75_elect_2p.Y]; %electrode in field of view 2p
N75_electA_origin = [0 0];
N75_electB = [N75_elect.X(2),N75_elect.Y(2)]; %other electrode
N75_electB_shifted = shift_coordinates(N75_electA, N75_electB); %first electrode is the electrode in FOV
N75_distance_between_electrodes = elect_distance(N75_electA, N75_electB); %calculate distance between the electrodes 

%import binary mask
N75_16_mask_both = imread("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M75\15uA\Mask.tif");
N75_16_mask_both_binary = N75_16_mask_both < max(max(N75_16_mask_both))/2;
N75_16_mask_both_binary = N75_16_mask_both_binary(:,:,1);

N75_fs = 290/118.985; %frames per second
N75_16_both_15uA_stimons = [24 50 75 101 127 153 179 204 230 256];

N75_15_right = calculate_features_lr(N75_ROI_16_both_15uA, N75_16_mask_both_binary, N75_ROI_15_right_15uA_measure, N75_15_right_15uA_all_frames, N75_16_both_15uA_stimons, N75_fs); 
N75_17_left = calculate_features_lr(N75_ROI_16_both_15uA, N75_16_mask_both_binary, N75_ROI_17_left_15uA_measure, N75_17_left_15uA_all_frames, N75_16_both_15uA_stimons,N75_fs);
N75_ROI_16_both_15uA = calculate_features_both(N75_ROI_16_both_15uA, N75_ROI_16_both_15uA_measure, N75_16_both_15uA_stimons, N75_electA_2p, N75_electA_origin, N75_electB_shifted, N75_16_mask_both_binary, N75_16_both_15uA_all_frames, N75_fs);


nn = size(X_new,1)+1;

for i = nn:nn+size(N75_ROI_16_both_15uA,2)-1
    %assign X
    X_new(i,1) = N75_ROI_16_both_15uA{i}.distA;
    X_new(i,2) = N75_ROI_16_both_15uA{i}.distB;
    X_new(i,3) = N75_ROI_16_both_15uA{i}.angleN;
    X_new(i,4) = N75_ROI_16_both_15uA{i}.angleA;
    X_new(i,5) = N75_ROI_16_both_15uA{i}.angleB;
    X_new(i,6) = N75_15_right{i}.mean_AUC; 
    X_new(i,7) = N75_17_left{i}.mean_AUC; 
    X_new(i,8) = N75_ROI_16_both_15uA{i}.prestim_range; 
    X_new(i,9) = N75_distance_between_electrodes;
    X_new(i,10) = N75_16_both_15uA_stim_intensity;
    X_new(i,11) = N75_16_both_15uA_stim_intensity;
    X_new(i,12) = EFcell{8}(i);

    mouse_ids(i) = "Mouse1";

    Y_new(i,1) = N75_ROI_16_both_15uA{i}.peak_df_f;
    Y_new(i,2) = N75_ROI_16_both_15uA{i}.mean_AUC;

    brl_all{i}.both = N75_ROI_16_both_15uA{i}.mean_gray_df_f;
    brl_all{i}.right = N75_15_right{i}.mean_gray_df_f;
    brl_all{i}.left = N75_17_left{i}.mean_gray_df_f;
end
C = X_new(nn:nn+size(N75_ROI_16_both_15uA,2)-1,:);
Y_N75_15uA = Y_new(nn:nn+size(N75_ROI_16_both_15uA,2)-1,:);


%% N75-12uA
N75_ROI_13_both_12uA = ReadImageJROI("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M75\12uA\Both_RoiSet.zip");
N75_ROI_13_both_12uA_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M75\12uA\both measure.csv");
N75_ROI_14_right_12uA_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M75\12uA\right measure.csv");
N75_ROI_12_left_12uA_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M75\12uA\left measure.csv");
N75_13_both_12uA_stim_intensity = 12;
N75_13_both_12uA_stimons = [6 32 58 83 109 135 161 186 212 238]; %only 13, the others have N75_16_both_15uA_stimons
N75_13_mask_both = imread("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M75\12uA\Mask.tif");
N75_13_mask_both_binary = N75_13_mask_both < max(max(N75_13_mask_both))/2;
N75_13_mask_both_binary = N75_13_mask_both_binary(:,:,1);
N75_13_both_12uA_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M75\12uA\13_Both 12uA 500ms 10 trials_0001_mcor.tif - C=0.tif"); % import tif file
N75_14_right_12uA_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M75\12uA\14_rightA 12uA 500ms 10 trials_mcor.tif - C=0.tif");
N75_12_left_12uA_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M75\12uA\12_leftB 12uA 500ms 10 trials_mcor.tif - C=0.tif");

N75_ROI_13_both_12uA = calculate_features_both(N75_ROI_13_both_12uA, N75_ROI_13_both_12uA_measure, N75_13_both_12uA_stimons, N75_electA_2p, N75_electA_origin, N75_electB_shifted, N75_13_mask_both_binary, N75_13_both_12uA_all_frames, N75_fs);
N75_14_right = calculate_features_lr(N75_ROI_13_both_12uA, N75_13_mask_both_binary, N75_ROI_14_right_12uA_measure, N75_14_right_12uA_all_frames, N75_16_both_15uA_stimons, N75_fs);
N75_12_left = calculate_features_lr(N75_ROI_13_both_12uA, N75_13_mask_both_binary, N75_ROI_12_left_12uA_measure, N75_12_left_12uA_all_frames, N75_16_both_15uA_stimons, N75_fs);
nn = size(X_new,1)+1;

for i = nn:nn+size(N75_ROI_13_both_12uA,2)-1
    %assign X
    X_new(i,1) = N75_ROI_13_both_12uA{i-nn+1}.distA;
    X_new(i,2) = N75_ROI_13_both_12uA{i-nn+1}.distB;
    X_new(i,3) = N75_ROI_13_both_12uA{i-nn+1}.angleN;
    X_new(i,4) = N75_ROI_13_both_12uA{i-nn+1}.angleA;
    X_new(i,5) = N75_ROI_13_both_12uA{i-nn+1}.angleB;
    X_new(i,6) = N75_14_right{i-nn+1}.mean_AUC;
    X_new(i,7) = N75_12_left{i-nn+1}.mean_AUC; 
    X_new(i,8) = N75_ROI_13_both_12uA{i-nn+1}.prestim_range; 
    X_new(i,9) = N75_distance_between_electrodes;
    X_new(i,10) = N75_13_both_12uA_stim_intensity;
    X_new(i,11) = N75_13_both_12uA_stim_intensity;
    X_new(i,12) = EFcell{7}(i-nn+1);

    mouse_ids(i) = "Mouse1";

    Y_new(i,1) = N75_ROI_13_both_12uA{i-nn+1}.peak_df_f;
    Y_new(i,2) = N75_ROI_13_both_12uA{i-nn+1}.mean_AUC;

    brl_all{i}.both = N75_ROI_13_both_12uA{i-nn+1}.mean_gray_df_f;
    brl_all{i}.right = N75_14_right{i-nn+1}.mean_gray_df_f;
    brl_all{i}.left = N75_12_left{i-nn+1}.mean_gray_df_f;
end
X_N75_12uA = X_new(nn:nn+size(N75_ROI_13_both_12uA,2)-1,:);
Y_N75_12uA = Y_new(nn:nn+size(N75_ROI_13_both_12uA,2)-1,:);





%% m34-right
m34s1r_ROI = ReadImageJROI("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M34\01_right_elect_loca\15uA\Both_RoiSet.zip");
m34s1r_both_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M34\01_right_elect_loca\15uA\both measure.csv");
m34s1r_right_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M34\01_right_elect_loca\15uA\right measure.csv");
m34s1r_left_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M34\01_right_elect_loca\15uA\left measure.csv");
m34s1r_right_stim_intensity = 12;
m34s1r_left_stim_instensity = 15;
m34s1r_mask = imread("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M34\01_right_elect_loca\15uA\Mask.tif");
m34s1r_mask_binary = m34s1r_mask < max(max(m34s1r_mask))/2;
m34s1r_mask_binary = m34s1r_mask_binary(:,:,1);
m34s1r_both_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M34\01_right_elect_loca\15uA\left 15 right 12, 500ms right elect loca_mcor.tif - C=0.tif"); % import tif file
m34s1r_right_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M34\01_right_elect_loca\15uA\right 12, 500ms ,correct2_mcor.tif - C=0.tif");
m34s1r_left_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M34\01_right_elect_loca\15uA\left 15uA, 500ms right elect loca_mcor.tif");
m34s1r_fs = 180/88.179;
m34s1r_stimons = [20 42 63 85 106];

m34s1r_elect_wf = readtable("C:\Users\User1\Documents\Victor\AAA okay data\34_MicroElect_04252023_thy1gcamp6_twoelectrodes_2e\Electrodes_coords_wf.csv"); % load electrode positions in widefield
m34s1r_elect_2p = readtable("C:\Users\User1\Documents\Victor\AAA okay data\34_MicroElect_04252023_thy1gcamp6_twoelectrodes_2e\Electrode_coords_2p.csv"); % load fov electrode position in 2p
% split electrodes
m34s1r_electA = [m34s1r_elect_wf.X(1),m34s1r_elect_wf.Y(1)]; %electrode in field of view widefield
m34s1r_electA_2p = [m34s1r_elect_2p.X,m34s1r_elect_2p.Y]; %electrode in field of view 2p
m34r_electA_origin = [0 0];
m34r_electB = [m34s1r_elect_wf.X(2),m34s1r_elect_wf.Y(2)]; %other electrode
m34r_electB_shifted = shift_coordinates(m34s1r_electA, m34r_electB); %first electrode is the electrode in FOV
m34r_distance_between_electrodes = elect_distance(m34s1r_electA, m34r_electB); %calculate distance between the electrodes 

m34s1r_ROI = calculate_features_both(m34s1r_ROI, m34s1r_both_measure, m34s1r_stimons, m34s1r_electA_2p, m34r_electA_origin, m34r_electB_shifted, m34s1r_mask_binary, m34s1r_both_all_frames, m34s1r_fs);
m34s1r_right = calculate_features_lr(m34s1r_ROI, m34s1r_mask_binary, m34s1r_right_measure, m34s1r_right_all_frames, m34s1r_stimons, m34s1r_fs);
m34s1r_left = calculate_features_lr(m34s1r_ROI, m34s1r_mask_binary, m34s1r_left_measure, m34s1r_left_all_frames, m34s1r_stimons,m34s1r_fs);
nn = size(X_new,1)+1;

for i = nn:nn+size(m34s1r_ROI,2)-1
    %assign X
    X_new(i,1) = m34s1r_ROI{i-nn+1}.distA;
    X_new(i,2) = m34s1r_ROI{i-nn+1}.distB;
    X_new(i,3) = m34s1r_ROI{i-nn+1}.angleN;
    X_new(i,4) = m34s1r_ROI{i-nn+1}.angleA;
    X_new(i,5) = m34s1r_ROI{i-nn+1}.angleB;
    X_new(i,6) = m34s1r_right{i-nn+1}.mean_AUC; 
    X_new(i,7) = m34s1r_left{i-nn+1}.mean_AUC; 
    X_new(i,8) = m34s1r_ROI{i-nn+1}.prestim_range; 
    X_new(i,9) = m34r_distance_between_electrodes;
    X_new(i,10) = m34s1r_right_stim_intensity;
    X_new(i,11) = m34s1r_left_stim_instensity;
    X_new(i,12) = EFcell{4}(i-nn+1);

    mouse_ids(i) = "Mouse2";

    Y_new(i,1) = m34s1r_ROI{i-nn+1}.peak_df_f;
    Y_new(i,2) = m34s1r_ROI{i-nn+1}.mean_AUC;

    brl_all{i}.both = m34s1r_ROI{i-nn+1}.mean_gray_df_f;
    brl_all{i}.right = m34s1r_right{i-nn+1}.mean_gray_df_f;
    brl_all{i}.left = m34s1r_left{i-nn+1}.mean_gray_df_f;
end
X_N34_R = X_new(nn:nn+size(m34s1r_ROI,2)-1,:);
Y_N34_R = Y_new(nn:nn+size(m34s1r_ROI,2)-1,:);



%% m34-left
m34s1l_ROI = ReadImageJROI("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M34\02_left_elect_loca\13uA\Both_RoiSet.zip");
m34s1l_both_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M34\02_left_elect_loca\13uA\both measure.csv");
m34s1l_right_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M34\02_left_elect_loca\13uA\right measure.csv");
m34s1l_left_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M34\02_left_elect_loca\13uA\left measure.csv");
m34s1l_right_stim_intensity = 12;
m34s1l_left_stim_instensity = 13;
m34s1l_mask = imread("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M34\02_left_elect_loca\13uA\Mask.tif");
m34s1l_mask_binary = m34s1l_mask < max(max(m34s1l_mask))/2;
m34s1l_mask_binary = m34s1l_mask_binary(:,:,1);
m34s1l_both_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M34\02_left_elect_loca\13uA\left 13 right 12, 500ms_mcor.tif - C=0.tif"); % import tif file
m34s1l_right_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M34\02_left_elect_loca\13uA\right 12uA, 500ms_mcor.tif - C=0.tif");
m34s1l_left_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M34\02_left_elect_loca\13uA\left 13uA, 500ms 0001_mcor.tif - C=0.tif");
m34s1l_fs = 180/88.635;
m34s1l_stimons = [20 42 63 84 106];

m34s1l_elect_wf = readtable("C:\Users\User1\Documents\Victor\AAA okay data\34_MicroElect_04252023_thy1gcamp6_twoelectrodes_2e\Electrodes_coords_wf.csv"); % load electrode positions in widefield
m34s1l_elect_2p = readtable("C:\Users\User1\Documents\Victor\AAA okay data\34_MicroElect_04252023_thy1gcamp6_twoelectrodes_2e\Electrode left 2p measure.csv"); % load fov electrode position in 2p
% split electrodes
m34s1l_electA = [m34s1l_elect_wf.X(2),m34s1l_elect_wf.Y(2)]; %electrode in field of view widefield
m34s1l_electA_2p = [m34s1l_elect_2p.X,m34s1l_elect_2p.Y]; %electrode in field of view 2p
m34l_electA_origin = [0 0];
m34l_electB = [m34s1l_elect_wf.X(1),m34s1l_elect_wf.Y(1)]; %other electrode
m34l_electB_shifted = shift_coordinates(m34s1l_electA, m34l_electB); %first electrode is the electrode in FOV

m34s1l_ROI = calculate_features_both(m34s1l_ROI, m34s1l_both_measure, m34s1l_stimons, m34s1l_electA_2p, m34l_electA_origin, m34l_electB_shifted, m34s1l_mask_binary, m34s1l_both_all_frames, m34s1l_fs);
m34s1l_right = calculate_features_lr(m34s1l_ROI, m34s1l_mask_binary, m34s1l_right_measure, m34s1l_right_all_frames, m34s1l_stimons, m34s1l_fs); %here right is actually left and left is right (bc electrode in FOV)
m34s1l_left = calculate_features_lr(m34s1l_ROI, m34s1l_mask_binary, m34s1l_left_measure, m34s1l_left_all_frames, m34s1l_stimons,m34s1l_fs);
nn = size(X_new,1)+1;


for i = nn:nn+size(m34s1l_ROI,2)-1
    %assign X
    X_new(i,1) = m34s1l_ROI{i-nn+1}.distA;
    X_new(i,2) = m34s1l_ROI{i-nn+1}.distB;
    X_new(i,3) = m34s1l_ROI{i-nn+1}.angleN;
    X_new(i,4) = m34s1l_ROI{i-nn+1}.angleA;
    X_new(i,5) = m34s1l_ROI{i-nn+1}.angleB;
    X_new(i,6) = m34s1l_right{i-nn+1}.mean_AUC; 
    X_new(i,7) = m34s1l_left{i-nn+1}.mean_AUC; 
    X_new(i,8) = m34s1l_ROI{i-nn+1}.prestim_range; 
    X_new(i,9) = m34r_distance_between_electrodes;
    X_new(i,10) = m34s1l_right_stim_intensity;
    X_new(i,11) = m34s1l_left_stim_instensity;
    X_new(i,12) = EFcell{3}(i-nn+1);

    mouse_ids(i) = "Mouse2";

    Y_new(i,1) = m34s1l_ROI{i-nn+1}.peak_df_f;
    Y_new(i,2) = m34s1l_ROI{i-nn+1}.mean_AUC;

    brl_all{i}.both = m34s1l_ROI{i-nn+1}.mean_gray_df_f;
    brl_all{i}.right = m34s1l_right{i-nn+1}.mean_gray_df_f;
    brl_all{i}.left = m34s1l_left{i-nn+1}.mean_gray_df_f;
end
X_N34_L = X_new(nn:nn+size(m34s1l_ROI,2)-1,:);
Y_N34_L = Y_new(nn:nn+size(m34s1l_ROI,2)-1,:);


%% m76-s4
m76s4_ROI = ReadImageJROI("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M76\12uA\Right_RoiSet.zip"); %%%%
m76s4_both_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M76\12uA\both measure.csv");
m76s4_right_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M76\12uA\right measure.csv");
m76s4_left_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M76\12uA\left measure.csv");
m76s4_right_stim_intensity = 12;
m76s4_left_stim_instensity = 12;
m76s4_mask = imread("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M76\12uA\Mask.tif");
m76s4_mask_binary = m76s4_mask < max(max(m76s4_mask))/2;
m76s4_mask_binary = m76s4_mask_binary(:,:,1);
m76s4_both_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\76_MicroElect_06102024_thy1gcamp6_twoelect_2e\2p\01_all_elect_loca\stimparam4 yes\10_Both 12uA 500ms 10trial mcorr rigid.tif"); % import tif file
m76s4_right_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\76_MicroElect_06102024_thy1gcamp6_twoelect_2e\2p\01_all_elect_loca\stimparam4 yes\12_rightA 12uA 500ms 10trial mcorr rigid.tif");
m76s4_left_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\76_MicroElect_06102024_thy1gcamp6_twoelect_2e\2p\01_all_elect_loca\stimparam4 yes\11_leftB 12uA 500ms 10trial mcorr rigid.tif");
m76s4_fs = 300/123.102;
m76s4_stimons = [24 49 76 101 127 153 178 204 230 256];

m76s6_elect_wf = readtable("C:\Users\User1\Documents\Victor\AAA okay data\76_MicroElect_06102024_thy1gcamp6_twoelect_2e\electrodes widefield.csv"); % load electrode positions in widefield
m76s6_elect_2p = readtable("C:\Users\User1\Documents\Victor\AAA okay data\76_MicroElect_06102024_thy1gcamp6_twoelect_2e\electrode 2p.csv"); % load fov electrode position in 2p
% split electrodes
m76s6_electA = [m76s6_elect_wf.X(1),m76s6_elect_wf.Y(1)]; %electrode in field of view widefield
m76s6_electA_2p = [m76s6_elect_2p.X,m76s6_elect_2p.Y]; %electrode in field of view 2p
m76s6_electA_origin = [0 0];
m76s6_electB = [m76s6_elect_wf.X(2),m76s6_elect_wf.Y(2)]; %other electrode
m76s6_electB_shifted = shift_coordinates(m76s6_electA, m76s6_electB); %first electrode is the electrode in FOV
m76s6_distance_between_electrodes = elect_distance(m76s6_electA, m76s6_electB);

m76s4_ROI = calculate_features_both(m76s4_ROI, m76s4_both_measure, m76s4_stimons, m76s6_electA_2p, m76s6_electA_origin, m76s6_electB_shifted, m76s4_mask_binary, m76s4_both_all_frames, m76s4_fs);
m76s4_right = calculate_features_lr(m76s4_ROI, m76s4_mask_binary, m76s4_right_measure, m76s4_right_all_frames, m76s4_stimons, m76s4_fs); %here right is actually left and left is right (bc electrode in FOV)
m76s4_left = calculate_features_lr(m76s4_ROI, m76s4_mask_binary, m76s4_left_measure, m76s4_left_all_frames,m76s4_stimons,m76s4_fs);
nn = size(X_new,1)+1;




for i = nn:nn+size(m76s4_ROI,2)-1
    %assign X
    X_new(i,1) = m76s4_ROI{i-nn+1}.distA;
    X_new(i,2) = m76s4_ROI{i-nn+1}.distB;
    X_new(i,3) = m76s4_ROI{i-nn+1}.angleN;
    X_new(i,4) = m76s4_ROI{i-nn+1}.angleA;
    X_new(i,5) = m76s4_ROI{i-nn+1}.angleB;
    X_new(i,6) = m76s4_right{i-nn+1}.mean_AUC; 
    X_new(i,7) = m76s4_left{i-nn+1}.mean_AUC; 
    X_new(i,8) = m76s4_ROI{i-nn+1}.prestim_range; 
    X_new(i,9) = m76s6_distance_between_electrodes;
    X_new(i,10) = m76s4_right_stim_intensity;
    X_new(i,11) = m76s4_left_stim_instensity;
    X_new(i,12) = EFcell{9}(i-nn+1);

    mouse_ids(i) = "Mouse3";

    Y_new(i,1) = m76s4_ROI{i-nn+1}.peak_df_f;
    Y_new(i,2) = m76s4_ROI{i-nn+1}.mean_AUC;

    brl_all{i}.both = m76s4_ROI{i-nn+1}.mean_gray_df_f;
    brl_all{i}.right = m76s4_right{i-nn+1}.mean_gray_df_f;
    brl_all{i}.left = m76s4_left{i-nn+1}.mean_gray_df_f;
end

X_N76_S4 = X_new(nn:nn+size(m76s4_ROI,2)-1,:);
Y_N76_S4 = Y_new(nn:nn+size(m76s4_ROI,2)-1,:);




%% m76-s6
m76s6_ROI = ReadImageJROI("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M76\18uA\Both_RoiSet.zip"); %%%%
m76s6_both_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M76\18uA\both measure.csv");
m76s6_right_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M76\18uA\right measure.csv");
m76s6_left_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M76\18uA\left measure.csv");
m76s6_right_stim_intensity = 18;
m76s6_left_stim_instensity = 18;
m76s6_mask = imread("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M76\18uA\Mask.tif");
m76s6_mask_binary = m76s6_mask < max(max(m76s6_mask))/2;
m76s6_mask_binary = m76s6_mask_binary(:,:,1);
m76s6_both_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M76\18uA\16_Both 18uA 500ms 10trial_mcor.tif - C=0.tif"); % import tif file
m76s6_right_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M76\18uA\18_rightA 18uA 500ms 10trial_mcor.tif - C=0.tif");
m76s6_left_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M76\18uA\17_left 18uA 500ms 10trial_mcor.tif - C=0.tif");
m76s6_fs = 300/123.102;
m76s6_stimons = [24 50 76 101 127 153 178 204 230 256];

m76s6_ROI = calculate_features_both(m76s6_ROI, m76s6_both_measure, m76s6_stimons, m76s6_electA_2p, m76s6_electA_origin, m76s6_electB_shifted, m76s6_mask_binary, m76s6_both_all_frames, m76s6_fs);
m76s6_right = calculate_features_lr(m76s6_ROI, m76s6_mask_binary, m76s6_right_measure, m76s6_right_all_frames, m76s6_stimons, m76s6_fs); %here right is actually left and left is right (bc electrode in FOV)
m76s6_left = calculate_features_lr(m76s6_ROI, m76s6_mask_binary, m76s6_left_measure, m76s6_left_all_frames,m76s6_stimons,m76s6_fs);
nn = size(X_new,1)+1;


for i = nn:nn+size(m76s6_ROI,2)-1
    %assign X
    X_new(i,1) = m76s6_ROI{i-nn+1}.distA;
    X_new(i,2) = m76s6_ROI{i-nn+1}.distB;
    X_new(i,3) = m76s6_ROI{i-nn+1}.angleN;
    X_new(i,4) = m76s6_ROI{i-nn+1}.angleA;
    X_new(i,5) = m76s6_ROI{i-nn+1}.angleB;
    X_new(i,6) = m76s6_right{i-nn+1}.mean_AUC; 
    X_new(i,7) = m76s6_left{i-nn+1}.mean_AUC; 
    X_new(i,8) = m76s6_ROI{i-nn+1}.prestim_range;
    X_new(i,9) = m76s6_distance_between_electrodes;
    X_new(i,10) = m76s6_right_stim_intensity;
    X_new(i,11) = m76s6_left_stim_instensity;
    X_new(i,12) = EFcell{10}(i-nn+1);

    mouse_ids(i) = "Mouse3";


    Y_new(i,1) = m76s6_ROI{i-nn+1}.peak_df_f;
    Y_new(i,2) = m76s6_ROI{i-nn+1}.mean_AUC;

    brl_all{i}.both = m76s6_ROI{i-nn+1}.mean_gray_df_f;
    brl_all{i}.right = m76s6_right{i-nn+1}.mean_gray_df_f;
    brl_all{i}.left = m76s6_left{i-nn+1}.mean_gray_df_f;
end
X_N76_S6 = X_new(nn:nn+size(m76s6_ROI,2)-1,:);
Y_N76_S6 = Y_new(nn:nn+size(m76s6_ROI,2)-1,:);


%% m74-12uA
m74_12uA_ROI = ReadImageJROI("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M74\12uA\Both_RoiSet.zip"); %%%%
m74_12uA_both_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M74\12uA\both measure.csv");
m74_12uA_right_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M74\12uA\right measure.csv");
m74_12uA_left_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M74\12uA\left measure.csv");
m74_12uA_right_stim_intensity = 12;
m74_12uA_left_stim_instensity = 12;
m74_12uA_mask = imread("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M74\12uA\Mask.tif");
m74_12uA_mask_binary = m74_12uA_mask < max(max(m74_12uA_mask))/2;
m74_12uA_mask_binary = m74_12uA_mask_binary(:,:,1);
m74_12uA_both_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M74\12uA\9_both 12uA 500ms 10 trials_mcor.tif - C=0.tif"); % import tif file
m74_12uA_right_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M74\12uA\10_rightA 12uA 500ms 10 trials_mcor.tif - C=0.tif");
m74_12uA_left_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M74\12uA\11_leftB 12uA 500ms 10 trials_mcor.tif - C=0.tif");
m74_12uA_fs = 240/122.534;
m74_12uA_stimons = [19 40 61 81 102 123 143 164 185 205];

m74_12uA_elect_wf = readtable("C:\Users\User1\Documents\Victor\AAA okay data\74_MicroElect_05232024_thy1gcamp6_twoelect_2e\electrodes wf1.csv"); % load electrode positions in widefield
m74_12uA_elect_2p = readtable("C:\Users\User1\Documents\Victor\AAA okay data\74_MicroElect_05232024_thy1gcamp6_twoelect_2e\reference 2p.csv"); % load fov electrode position in 2p
% split electrodes
m74_12uA_electA = [m74_12uA_elect_wf.X(2),m74_12uA_elect_wf.Y(2)]; %electrode in field of view widefield
% m74_12uA_electA_2p = [m74_12uA_elect_2p.X,m74_12uA_elect_2p.Y]; %electrode in field of view 2p
m74_12uA_vessel_wf = [m74_12uA_elect_wf.X(1),m74_12uA_elect_wf.Y(1)];
m74_12uA_vessel_2p = [m74_12uA_elect_2p.X,m74_12uA_elect_2p.Y];
m74_12uA_A_origin = [0 0];
m74_12uA_electB = [m74_12uA_elect_wf.X(3),m74_12uA_elect_wf.Y(3)]; %other electrode
m74_12uA_electA_shift1 = shift_coordinates(m74_12uA_vessel_wf, m74_12uA_electA); %shift coordinates of A with respect to vessel in wf
m74_12uA_electA_shift2 = m74_12uA_vessel_2p + m74_12uA_electA_shift1; %find coordinates of A with respect to vessel in 2p
m74_12uA_electB_shifted = shift_coordinates(m74_12uA_electA, m74_12uA_electB); %shift coordinates of B with respect to electrode A in wf
m74_12uA_distance_between_electrodes = elect_distance(m74_12uA_electA, m74_12uA_electB);

m74_12uA_ROI = calculate_features_both(m74_12uA_ROI, m74_12uA_both_measure, m74_12uA_stimons, m74_12uA_electA_shift2, m74_12uA_A_origin, m74_12uA_electB_shifted, m74_12uA_mask_binary, m74_12uA_both_all_frames, m74_12uA_fs);
m74_12uA_right = calculate_features_lr(m74_12uA_ROI, m74_12uA_mask_binary, m74_12uA_right_measure, m74_12uA_right_all_frames, m74_12uA_stimons, m74_12uA_fs); %here right is actually left and left is right (bc electrode in FOV)
m74_12uA_left = calculate_features_lr(m74_12uA_ROI, m74_12uA_mask_binary, m74_12uA_left_measure, m74_12uA_left_all_frames,m74_12uA_stimons,m74_12uA_fs);
nn = size(X_new,1)+1;


for i = nn:nn+size(m74_12uA_ROI,2)-1
    %assign X
    X_new(i,1) = m74_12uA_ROI{i-nn+1}.distA;
    X_new(i,2) = m74_12uA_ROI{i-nn+1}.distB;
    X_new(i,3) = m74_12uA_ROI{i-nn+1}.angleN;
    X_new(i,4) = m74_12uA_ROI{i-nn+1}.angleA;
    X_new(i,5) = m74_12uA_ROI{i-nn+1}.angleB;
    X_new(i,6) = m74_12uA_right{i-nn+1}.mean_AUC; 
    X_new(i,7) = m74_12uA_left{i-nn+1}.mean_AUC; 
    X_new(i,8) = m74_12uA_ROI{i-nn+1}.prestim_range; 
    X_new(i,9) = m74_12uA_distance_between_electrodes;
    X_new(i,10) = m74_12uA_right_stim_intensity;
    X_new(i,11) = m74_12uA_left_stim_instensity;
    X_new(i,12) = EFcell{5}(i-nn+1);

    mouse_ids(i) = "Mouse4";

    Y_new(i,1) = m74_12uA_ROI{i-nn+1}.peak_df_f;
    Y_new(i,2) = m74_12uA_ROI{i-nn+1}.mean_AUC;

    brl_all{i}.both = m74_12uA_ROI{i-nn+1}.mean_gray_df_f;
    brl_all{i}.right = m74_12uA_right{i-nn+1}.mean_gray_df_f;
    brl_all{i}.left = m74_12uA_left{i-nn+1}.mean_gray_df_f;
end
X_N74_12uA = X_new(nn:nn+size(m74_12uA_ROI,2)-1,:);
Y_N74_12uA = Y_new(nn:nn+size(m74_12uA_ROI,2)-1,:);



%% m74-15uA
m74_15uA_ROI = ReadImageJROI("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M74\15uA\Both_RoiSet.zip"); %%%%
m74_15uA_both_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M74\15uA\both measure.csv");
m74_15uA_right_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M74\15uA\right measure.csv");
m74_15uA_left_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M74\15uA\left measure.csv");
m74_15uA_right_stim_intensity = 15;
m74_15uA_left_stim_instensity = 15;
m74_15uA_mask = imread("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M74\15uA\Mask.tif");
m74_15uA_mask_binary = m74_15uA_mask < max(max(m74_15uA_mask))/2;
m74_15uA_mask_binary = m74_15uA_mask_binary(:,:,1);
m74_15uA_both_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M74\15uA\13_Both 15uA 500ms 10 trials_mcor.tif"); % import tif file
m74_15uA_right_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M74\15uA\14_rightA 15uA 500ms 10 trials_0001_mcor.tif");
m74_15uA_left_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M74\15uA\12_leftB 15uA 500ms 10 trials_mcor.tif");
m74_15uA_fs = 240/122.534;
m74_15uA_stimons = [17 40 61 81 102 123 143 164 185 205];

m74_15uA_ROI = calculate_features_both(m74_15uA_ROI, m74_15uA_both_measure, m74_15uA_stimons, m74_12uA_electA_shift2, m74_12uA_A_origin, m74_12uA_electB_shifted, m74_15uA_mask_binary, m74_15uA_both_all_frames, m74_15uA_fs);
m74_15uA_right = calculate_features_lr(m74_15uA_ROI, m74_15uA_mask_binary, m74_15uA_right_measure, m74_15uA_right_all_frames, m74_15uA_stimons, m74_15uA_fs); %here right is actually left and left is right (bc electrode in FOV)
m74_15uA_left = calculate_features_lr(m74_15uA_ROI, m74_15uA_mask_binary, m74_15uA_left_measure, m74_15uA_left_all_frames,m74_15uA_stimons,m74_15uA_fs);
nn = size(X_new,1)+1;

for i = nn:nn+size(m74_15uA_ROI,2)-1
    %assign X
    X_new(i,1) = m74_15uA_ROI{i-nn+1}.distA;
    X_new(i,2) = m74_15uA_ROI{i-nn+1}.distB;
    X_new(i,3) = m74_15uA_ROI{i-nn+1}.angleN;
    X_new(i,4) = m74_15uA_ROI{i-nn+1}.angleA;
    X_new(i,5) = m74_15uA_ROI{i-nn+1}.angleB;
    X_new(i,6) = m74_15uA_right{i-nn+1}.mean_AUC; 
    X_new(i,7) = m74_15uA_left{i-nn+1}.mean_AUC; 
    X_new(i,8) = m74_15uA_ROI{i-nn+1}.prestim_range; 
    X_new(i,9) = m74_12uA_distance_between_electrodes;
    X_new(i,10) = m74_15uA_right_stim_intensity;
    X_new(i,11) = m74_15uA_left_stim_instensity;
    X_new(i,12) = EFcell{6}(i-nn+1);

    mouse_ids(i) = "Mouse4";

    Y_new(i,1) = m74_15uA_ROI{i-nn+1}.peak_df_f;
    Y_new(i,2) = m74_15uA_ROI{i-nn+1}.mean_AUC;

    brl_all{i}.both = m74_15uA_ROI{i-nn+1}.mean_gray_df_f;
    brl_all{i}.right = m74_15uA_right{i-nn+1}.mean_gray_df_f;
    brl_all{i}.left = m74_15uA_left{i-nn+1}.mean_gray_df_f;
end
X_N74_15uA = X_new(nn:nn+size(m74_15uA_ROI,2)-1,:);
Y_N74_15uA = Y_new(nn:nn+size(m74_15uA_ROI,2)-1,:);

% forBingdong(m74_15uA_ROI, "m74-15uA");

% %% m32s1
% m32s1_ROI = ReadImageJROI("C:\Users\User1\Documents\Victor\AAA okay data\32_MicroElect_04172023_thy1gcamp6_twoelectrodes_2e\2p\01_right_elect_loca\stimparam1\All ROI.zip"); %%%%
% m32s1_both_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\32_MicroElect_04172023_thy1gcamp6_twoelectrodes_2e\2p\01_right_elect_loca\stimparam1\left 8, right 8, 600ms, right elect loc measure.csv");
% m32s1_right_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\32_MicroElect_04172023_thy1gcamp6_twoelectrodes_2e\2p\01_right_elect_loca\stimparam1\right 8, 600ms, right elect_0001 measure.csv");
% m32s1_left_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\32_MicroElect_04172023_thy1gcamp6_twoelectrodes_2e\2p\01_right_elect_loca\stimparam1\left 8, 600ms right loc mcorr rigid measure.csv");
% m32s1_right_stim_intensity = 8;
% m32s1_left_stim_instensity = 8;
% m32s1_mask = imread("C:\Users\User1\Documents\Victor\AAA okay data\32_MicroElect_04172023_thy1gcamp6_twoelectrodes_2e\2p\01_right_elect_loca\stimparam1\mask.jpg");
% m32s1_mask_binary = m32s1_mask < max(max(m32s1_mask))/2;
% m32s1_mask_binary = m32s1_mask_binary(:,:,1);
% m32s1_both_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\32_MicroElect_04172023_thy1gcamp6_twoelectrodes_2e\2p\01_right_elect_loca\stimparam1\left 8, right 8, 600ms, right elect loc mcorr rigid.tif"); % import tif file
% m32s1_right_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\32_MicroElect_04172023_thy1gcamp6_twoelectrodes_2e\2p\01_right_elect_loca\stimparam1\right 8, 600ms, right elect_0001 mcorr rigid.tif");
% m32s1_left_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\32_MicroElect_04172023_thy1gcamp6_twoelectrodes_2e\2p\01_right_elect_loca\stimparam1\left 8, 600ms right loc mcorr rigid.tif");
% m32s1_fs = 140/77.191;
% m32s1_stimons = [18 28 57 76 95 115];
% 
m32s1_elect_wf = readtable("C:\Users\User1\Documents\Victor\AAA okay data\32_MicroElect_04172023_thy1gcamp6_twoelectrodes_2e\Elect coords wf.csv"); % load electrode positions in widefield
m32s1_elect_2p = readtable("C:\Users\User1\Documents\Victor\AAA okay data\32_MicroElect_04172023_thy1gcamp6_twoelectrodes_2e\Elect coords 2p.csv"); % load fov electrode position in 2p
% split electrodes
m32s1_electA = [m32s1_elect_wf.X(1),m32s1_elect_wf.Y(1)]; %electrode in field of view widefield
m32s1_electA_2p = [m32s1_elect_2p.X,m32s1_elect_2p.Y]; %electrode in field of view 2p
m32s1_electA_origin = [0 0];
m32s1_electB = [m32s1_elect_wf.X(2),m32s1_elect_wf.Y(2)]; %other electrode
m32s1_electB_shifted = shift_coordinates(m32s1_electA, m32s1_electB); %first electrode is the electrode in FOV
m32s1_distance_between_electrodes = elect_distance(m32s1_electA, m32s1_electB);

% m32s1_ROI = calculate_features_both(m32s1_ROI, m32s1_both_measure, m32s1_stimons, m32s1_electA_2p, m32s1_electA_origin, m32s1_electB_shifted, m32s1_mask_binary, m32s1_both_all_frames, m32s1_fs);
% m32s1_right = calculate_features_lr(m32s1_ROI, m32s1_mask_binary, m32s1_right_measure, m32s1_right_all_frames, m32s1_stimons, m32s1_fs); %here right is actually left and left is right (bc electrode in FOV)
% m32s1_left = calculate_features_lr(m32s1_ROI, m32s1_mask_binary, m32s1_left_measure, m32s1_left_all_frames, m32s1_stimons, m32s1_fs);
% nn = size(X,1)+1;
% 
% 
% for i = nn:nn+size(m32s1_ROI,2)-1
%     %assign X
%     X(i,1) = m32s1_ROI{i-nn+1}.distA;
%     X(i,2) = m32s1_ROI{i-nn+1}.distB;
%     X(i,3) = m32s1_ROI{i-nn+1}.angleN;
%     X(i,4) = m32s1_ROI{i-nn+1}.angleA;
%     X(i,5) = m32s1_ROI{i-nn+1}.angleB;
%     X(i,6) = m32s1_right{i-nn+1}.mean_AUC; 
%     X(i,7) = m32s1_left{i-nn+1}.mean_AUC; 
%     X(i,8) = m32s1_ROI{i-nn+1}.prestim_range; 
%     X(i,9) = m32s1_distance_between_electrodes;
%     X(i,10) = m32s1_right_stim_intensity;
%     X(i,11) = m32s1_left_stim_instensity;
%     X(i,12) = EFcell{1}(i-nn+1);
% 
%     mouse_ids(i) = "Mouse5";
% 
%     Y(i,1) = m32s1_ROI{i-nn+1}.peak_df_f;
%     Y(i,2) = m32s1_ROI{i-nn+1}.mean_AUC;
% 
%     brl_all{i}.both = m32s1_ROI{i-nn+1}.mean_gray_df_f;
%     brl_all{i}.right = m32s1_right{i-nn+1}.mean_gray_df_f;
%     brl_all{i}.left = m32s1_left{i-nn+1}.mean_gray_df_f;
% end
% X_N32_S1 = X(nn:nn+size(m32s1_ROI,2)-1,:);
% Y_N32_S1 = Y(nn:nn+size(m32s1_ROI,2)-1,:);
% 
%

%% m32s2
m32s2_ROI = ReadImageJROI("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M32\15uA\Both_RoiSet.zip"); %%%%
m32s2_both_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M32\15uA\both measure.csv");
m32s2_right_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M32\15uA\right measure.csv");
m32s2_left_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M32\15uA\left measure.csv");
m32s2_right_stim_intensity = 15;
m32s2_left_stim_instensity = 15;
m32s2_mask = imread("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M32\15uA\Mask.tif");
m32s2_mask_binary = m32s2_mask < max(max(m32s2_mask))/2;
m32s2_mask_binary = m32s2_mask_binary(:,:,1);
m32s2_both_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M32\15uA\both 15, 600ms, right loca_mcor.tif - C=0.tif"); % import tif file
m32s2_right_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M32\15uA\right 15, 600ms, right loca_mcor.tif - C=0.tif");
m32s2_left_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M32\15uA\left 15, 600ms, right location_mcor.tif - C=0.tif");
m32s2_fs = 140/77.191;
m32s2_stimons = [18 37 57 76 95 114];

m32s2_ROI = calculate_features_both(m32s2_ROI, m32s2_both_measure, m32s2_stimons, m32s1_electA_2p, m32s1_electA_origin, m32s1_electB_shifted, m32s2_mask_binary, m32s2_both_all_frames, m32s2_fs);
m32s2_right = calculate_features_lr(m32s2_ROI, m32s2_mask_binary, m32s2_right_measure, m32s2_right_all_frames, m32s2_stimons, m32s2_fs); %here right is actually left and left is right (bc electrode in FOV)
m32s2_left = calculate_features_lr(m32s2_ROI, m32s2_mask_binary, m32s2_left_measure, m32s2_left_all_frames,m32s2_stimons,m32s2_fs);
nn = size(X_new,1)+1;


for i = nn:nn+size(m32s2_ROI,2)-1
    %assign X
    X_new(i,1) = m32s2_ROI{i-nn+1}.distA;
    X_new(i,2) = m32s2_ROI{i-nn+1}.distB;
    X_new(i,3) = m32s2_ROI{i-nn+1}.angleN;
    X_new(i,4) = m32s2_ROI{i-nn+1}.angleA;
    X_new(i,5) = m32s2_ROI{i-nn+1}.angleB;
    X_new(i,6) = m32s2_right{i-nn+1}.mean_AUC; 
    X_new(i,7) = m32s2_left{i-nn+1}.mean_AUC; 
    X_new(i,8) = m32s2_ROI{i-nn+1}.prestim_range; 
    X_new(i,9) = m32s1_distance_between_electrodes;
    X_new(i,10) = m32s2_right_stim_intensity;
    X_new(i,11) = m32s2_left_stim_instensity;
    X_new(i,12) = EFcell{1}(i-nn+1);

    mouse_ids(i) = "Mouse5";

    Y_new(i,1) = m32s2_ROI{i-nn+1}.peak_df_f;
    Y_new(i,2) = m32s2_ROI{i-nn+1}.mean_AUC;

    brl_all{i}.both = m32s2_ROI{i-nn+1}.mean_gray_df_f;
    brl_all{i}.right = m32s2_right{i-nn+1}.mean_gray_df_f;
    brl_all{i}.left = m32s2_left{i-nn+1}.mean_gray_df_f;
end
X_N32_S2 = X_new(nn:nn+size(m32s2_ROI,2)-1,:);
Y_N32_S2 = Y_new(nn:nn+size(m32s2_ROI,2)-1,:);



%% m32s3
m32s3_ROI = ReadImageJROI("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M32\18uA\Both_RoiSet.zip"); %%%%
m32s3_both_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M32\18uA\both measure.csv");
m32s3_right_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M32\18uA\right measure.csv");
m32s3_left_measure = readtable("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M32\18uA\left measure.csv");
m32s3_right_stim_intensity = 18;
m32s3_left_stim_instensity = 18;
m32s3_mask = imread("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M32\18uA\Mask.tif");
m32s3_mask_binary = m32s3_mask < max(max(m32s3_mask))/2;
m32s3_mask_binary = m32s3_mask_binary(:,:,1);
m32s3_both_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M32\18uA\left 18 right 18, 600ms right loc_mcor.tif - C=0.tif"); % import tif file
m32s3_right_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M32\18uA\right 18, 600ms, right loca_mcor.tif - C=0.tif");
m32s3_left_all_frames = tiffreadVolume("C:\Users\User1\Documents\Victor\AAA okay data\Data_twoelect\M32\18uA\left 18, 600ms right loc_mcor.tif - C=0.tif");
m32s3_fs = 140/77.191;
m32s3_stimons = [18 37 57 76 95 114];

m32s3_ROI = calculate_features_both(m32s3_ROI, m32s3_both_measure, m32s3_stimons, m32s1_electA_2p, m32s1_electA_origin, m32s1_electB_shifted, m32s3_mask_binary, m32s3_both_all_frames, m32s3_fs);
m32s3_right = calculate_features_lr(m32s3_ROI, m32s3_mask_binary, m32s3_right_measure, m32s3_right_all_frames, m32s3_stimons, m32s3_fs); %here right is actually left and left is right (bc electrode in FOV)
m32s3_left = calculate_features_lr(m32s3_ROI, m32s3_mask_binary, m32s3_left_measure, m32s3_left_all_frames,m32s3_stimons,m32s3_fs);
nn = size(X_new,1)+1;


for i = nn:nn+size(m32s3_ROI,2)-1
    %assign X
    X_new(i,1) = m32s3_ROI{i-nn+1}.distA;
    X_new(i,2) = m32s3_ROI{i-nn+1}.distB;
    X_new(i,3) = m32s3_ROI{i-nn+1}.angleN;
    X_new(i,4) = m32s3_ROI{i-nn+1}.angleA;
    X_new(i,5) = m32s3_ROI{i-nn+1}.angleB;
    X_new(i,6) = m32s3_right{i-nn+1}.mean_AUC; 
    X_new(i,7) = m32s3_left{i-nn+1}.mean_AUC; 
    X_new(i,8) = m32s3_ROI{i-nn+1}.prestim_range; 
    X_new(i,9) = m32s1_distance_between_electrodes;
    X_new(i,10) = m32s3_right_stim_intensity;
    X_new(i,11) = m32s3_left_stim_instensity;
    X_new(i,12) = EFcell{2}(i-nn+1);

    mouse_ids(i) = "Mouse5";

    Y_new(i,1) = m32s3_ROI{i-nn+1}.peak_df_f;
    Y_new(i,2) = m32s3_ROI{i-nn+1}.mean_AUC;

    brl_all{i}.both = m32s3_ROI{i-nn+1}.mean_gray_df_f;
    brl_all{i}.right = m32s3_right{i-nn+1}.mean_gray_df_f;
    brl_all{i}.left = m32s3_left{i-nn+1}.mean_gray_df_f;
end
X_N32_S3 = X_new(nn:nn+size(m32s3_ROI,2)-1,:);
Y_N32_S3 = Y_new(nn:nn+size(m32s3_ROI,2)-1,:);


%% function to calculate angle between A-neuron-B %to account for orientation selectivity 
function angle = angle(coord_N, coord_A, coord_B)
    vector_AN = coord_A - coord_N;
    vector_BN = coord_B - coord_N;

    dot_product = dot(vector_AN, vector_BN);

    % Calculate the magnitudes of AN and BN
    magnitude_AN = norm(vector_AN);
    magnitude_BN = norm(vector_BN);
    
    % Calculate the angle between the points
    angle = acosd(dot_product / (magnitude_AN * magnitude_BN));
    
    % % Check if point N is below the line formed by A and B
    % if (coord_N(2) < (coord_B(2) - coord_A(2)) / (coord_B(1) - coord_A(1)) * (coord_N(1) - coord_A(1)) + coord_A(2))
    %     angle = -angle; % Assign negative sign if below the line
    % end
end

%% function to calculate distance from electrode
function dist = elect_distance(ROI_centroid, electrode_coordinates)
    dist = sqrt(sum((ROI_centroid - electrode_coordinates).^2));
end

%% function to shift coordinates
% use this function to calculate the coordinates in microns of each point, shifting the center of the axis to the tip of the electrode, to then calculate the distance from 
% the electrode outside the field of view
function new_coord = shift_coordinates(coord_electrode_in_fov, centroid)
    new_coord = centroid - coord_electrode_in_fov; %coordinates in microns with respect to field of view
end

%% function to plot all ROIs response over time
function plot_ROI1(all_ROI, stimons) %cond2
    % Number of plots
    n = size(all_ROI, 2);

    % Number of rows needed for 7 plots per row
    numRows = ceil(n / 7);

    % Create a uifigure
    fig = uifigure('Name', 'Scrollable Subplots', 'Position', [100, 100, 1600, 800]);

    fig.PaperPositionMode = 'auto';
    % Determine panel size to accommodate all subplots
    panelHeight = numRows * 300;
    panelWidth = 2100; % Adjust as needed

    % Create a scrollable panel
    scrollPanel = uipanel(fig, 'Position', [0, 0, 1600, 800], 'Scrollable', 'on');

    % Create an inner panel to hold the subplots
    innerPanel = uipanel(scrollPanel, 'Position', [0, 0, panelWidth, panelHeight]);

    % Initialize the x and y limits
    x_limits = [Inf, -Inf];
    y_limits = [Inf, -Inf];

    % First pass to determine the common x and y limits
    for f = 1:n
        y_data = all_ROI{f}.mean_gray_df_f;
        x_limits(1) = min(x_limits(1), 1);
        x_limits(2) = max(x_limits(2), length(y_data));
        y_limits(1) = min(y_limits(1), min(y_data)-0.2*min(y_data));
        y_limits(2) = max(y_limits(2), max(y_data)+0.2*max(y_data));
    end

    % Create subplots inside the inner panel
    for f = 1:n
        % Calculate the row and column for each subplot
        row = ceil(f / 7);
        col = mod(f - 1, 7) + 1;

        % Calculate position for each subplot
        left = (col - 1) * 300;
        bottom = panelHeight - row * 300;

        % Create subplot axes in the calculated position
        ax = axes(innerPanel, 'Units', 'pixels', 'Position', [left, bottom, 280, 260]);

        hold(ax, 'on');
        plot(ax, all_ROI{f}.mean_gray_df_f, 'DisplayName', 'both df_f', 'Color', 'red');
        % plot(ax, cond2{f}.mean_gray_df_f, 'DisplayName', 'right df_f', 'Color', 'blue')

        % Plot the red line y = n
        % line(ax, [min(x_limits), max(x_limits)], [all_ROI{f}.bs, baseline(f)], 'Color', 'red');
        % line(ax, [min(x_limits), max(x_limits)], [mean(f), mean(f)], 'Color', 'green'); 

        % Plot vertical lines for each value in stimons
        for i = 1:length(stimons)
            xline(ax, stimons(i), 'b--', 'LineWidth', 1.5, 'Color', 'yellow'); % Draw a blue dashed vertical line
        end
        hold (ax, 'off');

        % Set the x and y limits
        xlim(ax, x_limits);
        ylim(ax, y_limits);

        % Add a title (optional)
        title(ax, sprintf('Plot %d', f));

        % Set aspect ratio to approximately 3:2
        pbaspect(ax, [3 2 1]);
    end
end

%% function to calculate stimulation onset
function stimons = calc_stim(fs, baseline, duration, n_trials, first_stimons)
    stimons = zeros(1,n_trials);
    stimons(1) = first_stimons;

    for itrial = 2:n_trials
        stimons(itrial) = stimons(itrial-1) + (baseline + duration)*fs;
    end

    stimons = ceil(stimons);
end

%% function to calculate baseline
function bs = calc_baseline(stimons, mean_gray, fs)
    % take n frames before and after stimulation
    % average the frames
    % assign baseline value to array
    n = round(4.92414*fs);
    bs = [];
    index_to_remove = false(size(mean_gray));
    for l = 1:length(stimons)
        index_to_remove(stimons(l):min(stimons(l)+n, numel(mean_gray))) = true;
    end

    % Create array Z by selecting elements not marked for removal
    bs = mean(mean_gray(~index_to_remove)); 
    
end

function [gray_val_df_f, df_ff, avg_peak, peaks] = df_f(mean_gray_value, stimons, baseline, fs) 
    g = round(2.052*fs);
    peaks = zeros(size(stimons));
    df_f_peaks = zeros(size(stimons));
    for d = 1:size(stimons,2)
        peaks(d) = max(mean_gray_value(stimons(d):stimons(d)+g));
        df_f_peaks(d) = (peaks(d)-baseline)/baseline;
    end
    gray_val_df_f = (mean_gray_value - baseline)/baseline;
    peaks_sorted = sort(peaks);
    avg_peak = mean(peaks_sorted(2:end-1));
    df_f_peaks_sorted = sort(df_f_peaks);
    df_ff = mean(df_f_peaks_sorted(2:end-1)); %average of middle 6
end

%% function to obtain electrode B

function electB_deshifted = electDeShift(electB, electA2p, umpx, imgSize)
    electB_deshifted = zeros(2,1);
    electB_deshifted(1) = (electB(1) + electA2p(1))/umpx;
    electB_deshifted(2) = imgSize - ((electB(2) + electA2p(2))/umpx);
end

%% Function to get coordinates for electric field simulation

function coords = get_coordinates(ROI)
    coords = zeros(size(ROI,2),3);
    for i = 1:size(ROI,2)
        coords(i,1:2) = ROI{i}.centroid_shifted;
    end
end

%% function to calculate pre-stimulus activity (as a std)
function prestim = prestim(mean_gray_value, stimons)
    prestim = std(mean_gray_value(1:stimons(1)-1));
    %calculate standard deviation instead
end

%% function to calculate slope of prestim activity vs. response
function slope = calc_slope(mean_gray, stimons)
    X_prestim = [];
    Y_response = [];
    for d=1:size(stimons,2)
        X_prestim(d) = max(mean_gray(stimons(d):stimons(d)+4));
        Y_response(d) = mean(mean_gray((stimons(d)-10:stimons(d))));
    end
    % figure;
    % scatter(X_prestim, Y_response);
    mdl_prestim = fitlm(X_prestim,Y_response);
    coefficients = mdl_prestim.Coefficients.Estimate;
    slope = coefficients(2);
end

%% function to get neuropil ring mask
function binaryMask = get_neuropil_ring_mask(mask, roi)
    area = polyarea(roi.mnCoordinates(:,1),roi.mnCoordinates(:,2));
    radius = sqrt(area/pi) * 1.5;

    % Define the size of the mask
    maskSize = size(mask); % [rows, columns]
    
    % Define the circle parameters
    centroid = mean([roi.mnCoordinates(:,1),roi.mnCoordinates(:,2)]);
    
    % Create coordinate grid
    [x, y] = meshgrid(1:maskSize(2), 1:maskSize(1));
    
    % Calculate the distance from the center for each point in the grid
    distanceFromCenter = sqrt((x - centroid(1)).^2 + (y - centroid(2)).^2);
    
    % Create the binary mask
    binaryMask = (distanceFromCenter <= radius).*mask;
end

%% function for neuropil subtraction
function [neuropil_gray_val, mean_neuropil_subtracted] = neuropil_subtraction(all_frames, neuropil_mask, mean_gray_val)
    weight = 0.4;
    neuropil_gray_val = zeros(size(all_frames,3),1);
    mean_neuropil_subtracted = zeros(size(all_frames,3),1);
    for o = 1:size(all_frames,3)
        result = double(all_frames(:,:,o)) .* neuropil_mask;
        non_zero_values = result(result ~= 0);
        neuropil_gray_val(o) = mean(non_zero_values);
        mean_neuropil_subtracted(o) = mean_gray_val(o) - (neuropil_gray_val(o)*weight);
    end
end

%% function to plot all ROIs with electrodes
function plotROIsElectrodes(both, right, N75_electA_origin, N75_electB_shifted)
    % Initialize data arrays for the scatter plot
    x_coords = [];
    y_coords = [];
    colors = [];

    % Iterate through the ROIs and select the ones that meet the condition
    for i = 1:length(both)
        x_coords = [x_coords; both{i}.centroid_shifted(1)];
        y_coords = [y_coords; both{i}.centroid_shifted(2)];
        colors = [colors; both{i}.mean_AUC - right{i}.mean_AUC];
    end

    % Create the scatter plot
    % figure;
    % 

    % Add electrodes
    hold on;
    scatter(x_coords, y_coords, 100, colors, 'filled');
    scatter(N75_electA_origin(1), N75_electA_origin(2), 100, 'k', 's', 'filled'); % Electrode A 
    scatter(N75_electB_shifted(1), N75_electB_shifted(2), 100, 'k', 'd', 'filled'); % Electrode B

    % Set color map and color bar
    colormap(hot); % Red to yellow/white color map
    colorbar;
    

    % Set axis properties
    axis equal;
    xlabel('X');
    ylabel('Y');
    title('Intensity change between conditions');
    hold off;
end


%% function to plot ROIs when they're suppressed compared to only right
function plotROIsAndElectrodes(both, right, N75_electA_origin, N75_electB_shifted)
    % Initialize data arrays for the scatter plot
    x_coords = [];
    y_coords = [];
    colors = [];

    % Iterate through the ROIs and select the ones that meet the condition
    for i = 1:length(both)
        if both{i}.mean_AUC < right{i}.mean_AUC
            x_coords = [x_coords; both{i}.centroid_shifted(1)];
            y_coords = [y_coords; both{i}.centroid_shifted(2)];
            colors = [colors; both{i}.mean_AUC - right{i}.mean_AUC];
        end
    end

    % Create the scatter plot
    figure;
    scatter(x_coords, y_coords, 100, colors, 'filled');

    % Add electrodes
    hold on;
    scatter(N75_electA_origin(1), N75_electA_origin(2), 100, 'k', 's', 'filled'); % Electrode A
    scatter(N75_electB_shifted(1), N75_electB_shifted(2), 100, 'k', 'd', 'filled'); % Electrode B

    % Set color map and color bar
    colormap(hot); % Red to yellow/white color map
    colorbar;

    % Set axis properties
    axis equal;
    xlabel('X Coordinate');
    ylabel('Y Coordinate');
    title('Scatter Plot of ROIs and Electrodes');



    hold off;
end

%% function to plot response compared to right, binary whether it's higher or lower
function plot_ROI_response(N75_ROI_16_both_15uA, N75_15_right_avg_response, N75_electA_origin, N75_electB_shifted)
    % Define the number of ROIs
    numROIs = length(N75_ROI_16_both_15uA);

    % Initialize arrays to hold centroid positions and average peak responses
    centroid_shifted = zeros(numROIs, 2);
    avg_peak_minus_bs = zeros(numROIs, 1);
    right_avg_response = N75_15_right_avg_response.';

    % Extract centroid positions and average peak responses from the input cell array
    for i = 1:numROIs
        centroid_shifted(i, :) = N75_ROI_16_both_15uA{i}.centroid_shifted;
        avg_peak_minus_bs(i) = N75_ROI_16_both_15uA{i}.avg_peak_minus_bs;
    end

    % Define the conditions for coloring the ROIs
    condition_positive = avg_peak_minus_bs - right_avg_response > 100;
    condition_negative = avg_peak_minus_bs - right_avg_response < -100;

    % Filter the coordinates based on the conditions
    centroid_shifted_positive = centroid_shifted(condition_positive, :);
    centroid_shifted_negative = centroid_shifted(condition_negative, :);

    % Create a scatter plot of the ROIs with different colors based on the conditions
    figure;
    hold on;

    % Plot ROIs that meet the positive condition in red
    scatter(centroid_shifted_positive(:, 1), centroid_shifted_positive(:, 2), 100, 'r', 'filled');
    axis equal;

    % Plot ROIs that meet the negative condition in blue
    scatter(centroid_shifted_negative(:, 1), centroid_shifted_negative(:, 2), 100, 'b', 'filled');

    % Plot the electrodes
    plot(N75_electA_origin(1), N75_electA_origin(2), 'ks', 'MarkerSize', 10, 'MarkerFaceColor', 'k'); % Electrode A as a square
    plot(N75_electB_shifted(1), N75_electB_shifted(2), 'kd', 'MarkerSize', 10, 'MarkerFaceColor', 'k'); % Electrode B as a diamond

    % Add legend
    legend('Response increases', 'Response decreases', 'Electrode A', 'Electrode B', 'Location', 'Best');

    % Title and labels
    title('ROI Response Intensities');
    xlabel('X Coordinate');
    ylabel('Y Coordinate');

    hold off;
end

%% function to plot variation between ROIs peaks
function plot_normalized_data(N75_ROI_16_both_15uA)
    % Create a figure and hold it for multiple plots
    figure;
    hold on;

    % Loop through each dataset and plot the normalized data
    for i = 1:size(N75_ROI_16_both_15uA, 2)
        % Normalize the data so that all lines start at the same y-value
        normalized_data = (N75_ROI_16_both_15uA{i}.peaks - N75_ROI_16_both_15uA{i}.avg_baseline)/N75_ROI_16_both_15uA{i}.avg_baseline;
        normalized_data = normalized_data - normalized_data(1);

        % Plot the normalized data
        plot(1:10, normalized_data, '-o');  % '-o' creates a line plot with circles at the data points
    end

    % Release the hold on the current figure
    hold off;

    % Add labels and title
    xlabel('Trial');
    ylabel('Response');
    title('Recordings of Samples Across Time');

    % Set x-axis limits
    xlim([0, 11]);

    % Enhance the plot appearance
    grid on;
end

function plot_with_std_lines(y)
    % Calculate mean and standard deviation
    mean_y = mean(y);  % Calculate mean
    std_y = std(y);    % Calculate standard deviation

    % Plot the values of y
    plot(y, 'b', 'LineWidth', 1.5);
    hold on;

    % Plot upper and lower bounds of one standard deviation
    upper_bound = mean_y + std_y;
    lower_bound = mean_y - std_y;
    line([1, length(y)], [upper_bound, upper_bound], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1);
    line([1, length(y)], [lower_bound, lower_bound], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1);

    % Add labels and title
    xlabel('Index');
    ylabel('Value');
    title('Plot with Standard Deviation Lines');

    % Show grid
    grid on;

    % Release the hold
    hold off;
end

function prestim_range = get_range(mean_gray_val, stimons)
    prestim = sort(mean_gray_val(1:stimons(1)-1));
    min_gray = mean(prestim(1:3));
    max_gray = mean(prestim(end-3:end));
    prestim_range = abs(max_gray - min_gray);
end

%% function to calculate area under curve
function mean_AUC = area_under_curve(mean_gray, stimons, fs)
    %trial-by-trial AUC
    range = round(3.5*fs);
    AUC = zeros(size(stimons));
    for i=1:length(stimons) %calculate AUC using trapezoidal rule where delta x is 1/fs (the time interval)
        AUC(i) = trapz(mean_gray(stimons(i):stimons(i)+range))/fs; %previously stimons(i)+18
    end
    %average
    sorted_AUC = sort(AUC);
    mean_AUC = mean(sorted_AUC(2:end-1));
end

%calculate features of "both"
function all_ROI = calculate_features_both(all_ROI, table, stimons, electA, electA_origin, electB_shifted, mask, all_frames,fs)
    for i=1:size(all_ROI,2)
        all_ROI{i}.centroid = [table{1, sprintf('X%d', i)} table{1, sprintf('Y%d', i)}]; %assign field for centroid coordinates
        all_ROI{i}.centroid_shifted = shift_coordinates(electA, all_ROI{i}.centroid); %shift centroid coordinates with origin in electrode A
        all_ROI{i}.distA = elect_distance(all_ROI{i}.centroid_shifted, electA_origin); %calculate distance
        all_ROI{i}.distB = elect_distance(all_ROI{i}.centroid_shifted, electB_shifted); %calculate distance
        all_ROI{i}.angleN = angle(all_ROI{i}.centroid_shifted, electA_origin, electB_shifted);
        all_ROI{i}.angleA = angle(electA_origin, all_ROI{i}.centroid_shifted, electB_shifted);
        all_ROI{i}.angleB = angle(electB_shifted, all_ROI{i}.centroid_shifted, electA_origin);
        all_ROI{i}.mean_gray_val = table{:, sprintf('Mean%d', i)};
    
        all_ROI{i}.binaryMask = get_neuropil_ring_mask(mask, all_ROI{i});
        [neuropil_gray_val, mean_neuropil_subtracted] = neuropil_subtraction(all_frames, all_ROI{i}.binaryMask, all_ROI{i}.mean_gray_val);
        all_ROI{i}.neuropil_gray_val = neuropil_gray_val;
        all_ROI{i}.mean_neuropil_subtracted = mean_neuropil_subtracted;
        
        %calculate average peaks (avg of max 5)
        bs = calc_baseline(stimons, all_ROI{i}.mean_gray_val, fs);
        
        all_ROI{i}.avg_baseline = bs;
        [mean_gray_df_f, df_ff, avg_peak, peaks] = df_f(all_ROI{i}.mean_gray_val, stimons, bs, fs);
        all_ROI{i}.peak_df_f = df_ff;
        all_ROI{i}.mean_gray_df_f = mean_gray_df_f;
        all_ROI{i}.avg_peak = avg_peak;
        all_ROI{i}.avg_peak_minus_bs = avg_peak - bs;
        all_ROI{i}.peaks = peaks;
        all_ROI{i}.avg_baseline_ns = calc_baseline(stimons, all_ROI{i}.mean_neuropil_subtracted,fs);
        [mean_gray_df_f_ns, df_ff_ns, avg_peak_ns, peaks_ns] = df_f(all_ROI{i}.mean_neuropil_subtracted, stimons, all_ROI{i}.avg_baseline_ns, fs);
        all_ROI{i}.peak_df_f_ns = df_ff_ns;
        all_ROI{i}.avg_peak_ns = avg_peak_ns;
        all_ROI{i}.mean_gray_df_f_ns = mean_gray_df_f_ns;
        all_ROI{i}.avg_peak_minus_bs_ns = avg_peak_ns - all_ROI{i}.avg_baseline_ns;
        all_ROI{i}.peaks_ns = peaks_ns;
        all_ROI{i}.prestim = prestim(all_ROI{i}.mean_gray_df_f, stimons);
        all_ROI{i}.prestim_range = get_range(all_ROI{i}.mean_gray_df_f, stimons);
        all_ROI{i}.prestim_neuropil_subtracted = prestim(all_ROI{i}.mean_neuropil_subtracted, stimons);
        all_ROI{i}.prestim_baseline = mean(all_ROI{i}.mean_gray_df_f(1:stimons(1)-1));
        all_ROI{i}.mean_AUC = area_under_curve(all_ROI{i}.mean_gray_df_f, stimons,fs);

        bs_np = calc_baseline(stimons, all_ROI{i}.neuropil_gray_val, fs);
        all_ROI{i}.neuropil_bss = all_ROI{i}.neuropil_gray_val-bs_np;
        all_ROI{i}.raw_bss = all_ROI{i}.mean_gray_val-all_ROI{i}.avg_baseline;
        all_ROI{i}.ns_bss = all_ROI{i}.mean_neuropil_subtracted-all_ROI{i}.avg_baseline_ns;
        
    end
end

function support_ROI = calculate_features_lr(all_ROI, mask, measure, all_frames, stimons,fs)
    support_ROI = cell(size(all_ROI));

    for i=1:size(all_ROI,2)
        support_ROI{i}.binaryMask = get_neuropil_ring_mask(mask, all_ROI{i});
        support_ROI{i}.mean_gray_val = measure{:, sprintf('Mean%d', i)}; %extract average gray value of each ROI over time
        [support_ROI{i}.neuropil_gray_val, support_ROI{i}.mean_neuropil_subtracted] = neuropil_subtraction(all_frames, support_ROI{i}.binaryMask, support_ROI{i}.mean_gray_val);
        support_ROI{i}.avg_baseline = calc_baseline(stimons, support_ROI{i}.mean_gray_val,fs);
        support_ROI{i}.avg_baseline_ns = calc_baseline(stimons, support_ROI{i}.mean_neuropil_subtracted,fs);
        [support_ROI{i}.mean_gray_df_f, support_ROI{i}.df_ff, support_ROI{i}.avg_peak,support_ROI{i}.peaks] = df_f(support_ROI{i}.mean_gray_val, stimons, support_ROI{i}.avg_baseline, fs);
        [support_ROI{i}.mean_gray_df_f_ns, support_ROI{i}.df_ff_ns, support_ROI{i}.avg_peak_ns, support_ROI{i}.peaks_ns] = df_f(support_ROI{i}.mean_neuropil_subtracted, stimons, support_ROI{i}.avg_baseline_ns,fs);
        support_ROI{i}.avg_peak_minus_bs = support_ROI{i}.avg_peak - support_ROI{i}.avg_baseline;
        support_ROI{i}.avg_peak_minus_bs_ns = support_ROI{i}.avg_peak_ns - support_ROI{i}.avg_baseline_ns;
        support_ROI{i}.mean_AUC = area_under_curve(support_ROI{i}.mean_gray_df_f, stimons, fs);

        
    end
end

function sorted_change_plot(cond1, cond2)
    % Calculate sorted differences
    sorted_diff = sort(cond1 - cond2);
    
    % Create figure
    figure;
    
    % Plot sorted differences
    plot(sorted_diff, 'LineWidth', 2);  % Increase line width for better visibility
    grid on;  % Turn on grid lines
    xlabel('Neuron index sorted by change');  % X-axis label
    ylabel('Change between conditions (df/f0)');  % Y-axis label
    title('Sorted Change in Neuronal Response between Conditions');  % Figure title
    
    % Customize plot appearance
    ax = gca;  % Get current axis handle
    ax.FontSize = 12;  % Adjust font size
    ax.FontWeight = 'bold';  % Make axis labels bold
    
    % Add horizontal line at y=0 for reference
    hold on;
    plot(xlim, [0 0], 'k--', 'LineWidth', 1);  % Black dashed line at y=0
    
    % Add legend if needed
    % legend('Sorted Change');
    
    hold off;
end

%% function to calculate electric field
function E_field_ROIs = calculate_electric_field(ROIs, electrode1, electrode2)
    % Number of ROIs
    n_ROIs = size(ROIs, 1);
    
    % Initialize the vector to store electric field magnitudes
    E_field_magnitudes = zeros(n_ROIs, 1);
    
    % Function to calculate electric field contribution from one electrode
    function E_magnitude = calcEFieldMagnitude(elect, ROI)
        r = sqrt(sum((ROI - elect(1:3)).^2, 2));  % Distance from electrode to ROI
        E_vector = (elect(4) ./ (2 * pi * r.^3)) .* (ROI - elect(1:3));  % Electric field vector
        E_magnitude = norm(E_vector);  % Magnitude of the electric field
    end
    
    % Loop over each ROI
    for i = 1:n_ROIs
        % Calculate electric field magnitude from electrode 1
        E1_magnitude = calcEFieldMagnitude(electrode1, ROIs(i, :));

        % Calculate electric field magnitude from electrode 2
        E2_magnitude = calcEFieldMagnitude(electrode2, ROIs(i, :));

        % Sum the magnitudes of the electric fields
        E_field_magnitudes(i) = E1_magnitude + E2_magnitude;
    end
end

%% function to extract shifted coordinates for Bingdong
function forBingdong (ROIs, string_name)
    for_bingdong = zeros(size(ROIs, 2),3);
    for_bingdong(:,1) = cellfun(@(c) c.centroid_shifted(1), ROIs);
    for_bingdong(:,2) = cellfun(@(c) c.centroid_shifted(2), ROIs);
    writematrix(for_bingdong, sprintf("%s.txt", string_name));
end

function E = electricField(q, electrode_pos, point, epsilon_0)
    % Calculate the vector from the charge to the observation point
    r_vec = point - electrode_pos;
    
    % Calculate the distance between the electrode and the observation point
    r_magnitude = norm(r_vec);
    
    if r_magnitude == 0
        % If the observation point is exactly at the charge, the electric field is undefined
        E = [0, 0, 0];
        return;
    end
    
    % Calculate the unit vector in the direction of r_vec
    r_unit = r_vec / r_magnitude;
    
    % Calculate the electric field using Coulomb's law
    E = (1 / (4 * pi * epsilon_0)) * (q / r_magnitude^2) * r_unit;
end

%% plot of ROIs with respect to electrodes, colored according to the modulation
%% in response between two-electrode and one-electrode stimulation

function plotROIsElectrodes(both, right, N75_electA_origin, N75_electB_shifted)
    % Initialize data arrays for the scatter plot
    x_coords = [];
    y_coords = [];
    colors = [];

    % Iterate through the ROIs and select the ones that meet the condition
    for i = 1:length(both)
        x_coords = [x_coords; both{i}.centroid_shifted(1)];
        y_coords = [y_coords; both{i}.centroid_shifted(2)];
        colors = [colors; both{i}.mean_AUC - right{i}.mean_AUC];
    end

    % Create the scatter plot
    % figure;
    % 

    % Add electrodes
    hold on;
    scatter(x_coords, y_coords, 100, colors, 'filled');
    scatter(N75_electA_origin(1), N75_electA_origin(2), 100, 'k', 's', 'filled'); % Electrode A 
    scatter(N75_electB_shifted(1), N75_electB_shifted(2), 100, 'k', 'd', 'filled'); % Electrode B

    % Set color map and color bar
    colormap(hot); % Red to yellow/white color map
    colorbar;
    

    % Set axis properties
    axis equal;
    xlabel('X');
    ylabel('Y');
    title('Intensity change between conditions');
    hold off;
end

%% Modulation difference expressed as R(both) - (R(single) + R(single away)

% Load your data
X_plot = load("X_final_final.mat").X_new;
Y_plot = load("Y_final_final.mat").Y_new;

% Calculate Cumulative Distance and Response Difference
Cumulative_distance = X_plot(:,1) + X_plot(:,2);
Response_diff = Y_plot(:,2) - (X_plot(:,6) + X_plot(:,7));

% Create the scatter plot with improvements
figure;
scatter(Cumulative_distance, Response_diff, 50, 'filled', 'MarkerFaceColor', [0.2 0.6 0.8], 'MarkerEdgeColor', [0.1 0.3 0.5], 'MarkerFaceAlpha', 0.7, 'MarkerEdgeAlpha', 0.7);

% Add grid for better visual separation
grid on;

% Add a horizontal line at Y = 0 to highlight the center
hold on;
yline(0, '--k', 'LineWidth', 1.5);
hold off;

% Customize the axis limits if needed
xlim([min(Cumulative_distance) - 1, max(Cumulative_distance) + 1]);
ylim([min(Response_diff) - 1, max(Response_diff) + 1]);

% Add labels and title
xlabel('Cumulative Distance from Electrodes (um)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Modulation Difference (AUC)', 'FontSize', 12, 'FontWeight', 'bold');
title('Elegant Scatter Plot of Response Difference vs Cumulative Distance', 'FontSize', 14, 'FontWeight', 'bold');

% Improve figure aesthetics
set(gca, 'FontSize', 12);  % Set font size for better readability
set(gca, 'LineWidth', 1.5); % Thicker axis lines
set(gcf, 'Color', 'w');  % Set background color to white
box on; % Keep box around the plot



%% PLOT TO SHOW RESPONSIVE CELLS AS DISTANCE INCREASES
X_all = load("X_final_final.mat").X_new;
Y_all = load("Y_final_final.mat").Y_new;

% Define categories based on sample groups in X_all(:,12)
categories = unique(X_all(:,12));
num_categories = length(categories);

% Preallocate arrays for each category
pooled_data_by_category = cell(num_categories, 1);
centers_by_category = cell(num_categories, 1);

% Bin edges
num_bins = 20;
bin_edges = linspace(min(X_all(:,1)), max(X_all(:,1)), num_bins+1);

% Process each category
for k = 1:num_categories
    category_indices = X_all(:,12) == categories(k);
    category_data = [X_all(category_indices, :), Y_all(category_indices, 2)];
    
    % Calculate pooled data for the current category
    [centers_by_category{k}, pooled_data_by_category{k}] = pooled_data(category_data, bin_edges);
end

% Plot the pooled response intensities for each category
figure;
hold on;
colors = lines(num_categories); % Generate distinct colors for each category

for k = 1:num_categories
    plot(centers_by_category{k}, pooled_data_by_category{k}, '-o', ...
        'Color', colors(k, :), 'DisplayName', sprintf('Mouse %d', k));
end


% Customize the plot
xlabel('Distance from Electrode (um)');
ylabel('Response Intensity (AUC, df/f0 normalised)');
legend('show');
grid on;
hold off;

% Create a function to calculate pooled response intensity
function [bin_centers, pooled_response] = pooled_data(data, bin_edges)
    bin_centers = (bin_edges(1:end-1) + bin_edges(2:end)) / 2;
    pooled_response = zeros(1, numel(bin_centers));
    
    for j = 1:numel(bin_centers)
        in_bin = data(:,1) >= bin_edges(j) & data(:,1) < bin_edges(j+1);
        if sum(in_bin) > 0
            pooled_response(j) = mean(data(in_bin, 14)); % Or use median instead of mean if desired
        else
            pooled_response(j) = NaN; % Set to NaN if no data in the bin
        end
    end
end


%% Plot with Gaussian fit

X_plot1 = load("X_final_final.mat").X_new;
Y_plot1 = load("Y_final_final.mat").Y_new;

diff_both_right = Y_plot1(:,2)-X_plot1(:,6);


figure('Color', 'w');
histogram(diff_both_right, 'FaceColor', [0.3, 0.75, 0.93], 'NumBins', 50);

mu = mean(diff_both_right);  % Mean of the differences
sigma = std(diff_both_right);  % Standard deviation of the differences

% Overlay the Gaussian curve
x_values = linspace(min(diff_both_right), max(diff_both_right), 100);
y_values = normpdf(x_values, mu, sigma);
hold on;
% plot(x_values, y_values, 'r-', 'LineWidth', 2);
line([mu - 2*sigma, mu - 2*sigma], ylim, 'Color', [0.1, 0.6, 0.2], 'LineStyle', '--', 'LineWidth', 2);
line([mu + 2*sigma, mu + 2*sigma], ylim, 'Color', [0.1, 0.6, 0.2], 'LineStyle', '--', 'LineWidth', 2);
grid on;
set(gca, 'GridColor', [0.8, 0.8, 0.8], 'GridAlpha', 0.7);
legend({'Data', '±2σ'}, 'Location', 'northeast', 'FontSize', 10, 'Box', 'off');
hold off;


% Add labels and title
xlabel('Difference (Both - Single Away)');
ylabel('Probability Density');
title('Gaussian Fit of Differences Between Conditions');
% legend('Data', 'Gaussian Fit');
