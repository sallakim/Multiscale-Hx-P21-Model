clear; clc; 

addpath opt_pars\
addpath model\

nx_animal_ids = [11 12 51 52 54 55 56];
hx_animal_ids = [1 4 5 7 8 9 10 57 58 59 61 62]; 

green = [0.07,.77,0.44]; 
purple = [0.6,0.4,1.0]; 

for i = 1:length(nx_animal_ids)
    animal_id = nx_animal_ids(i);
    filename2 = sprintf('opt_pars_Nx%d.mat', animal_id); % get optimized parameters 
    table = readtable('MJC_P21_data_input.xlsx','PreserveVariableNames',true); % get data 
    load(filename2,'xopt')
    opt_pars = exp(xopt); 
    opt_pars_nx(i,:) = opt_pars; 

    loc = find(table.AnimalID == animal_id);
    t_current = table(loc,:);
    ESP_LV_nx(i) = t_current.LVESP;
    EDP_LV_nx(i) = t_current.LVEDP;
    
    ESP_RV_nx(i) = t_current.RVESP;
    EDP_RV_nx(i) = t_current.RVEDP;
    
    ESV_LV_nx(i) = t_current.LVESV;

    ESV_RV_nx(i) = t_current.RVESV;

    SV_LV_nx(i) = t_current.StrokeVolume;

end

for i = 1:length(hx_animal_ids)
    animal_id = hx_animal_ids(i);
    filename2 = sprintf('opt_pars_Hx%d.mat', animal_id); % get optimized parameters 
    table = readtable('MJC_P21_data_input.xlsx','PreserveVariableNames',true); % get data 
    load(filename2,'xopt')
    opt_pars = exp(xopt); 
    opt_pars_hx(i,:) = opt_pars; % each row is a separate animal 

    loc = find(table.AnimalID == animal_id);
    t_current = table(loc,:);
    ESP_LV_hx(i) = t_current.LVESP;
    EDP_LV_hx(i) = t_current.LVEDP;
    
    ESP_RV_hx(i) = t_current.RVESP;
    EDP_RV_hx(i) = t_current.RVEDP;
    
    ESV_LV_hx(i) = t_current.LVESV;

    ESV_RV_hx(i) = t_current.RVESV;

    SV_LV_hx(i) = t_current.StrokeVolume;

end

ESV_LV = [ESV_LV_nx,ESV_LV_hx]'; 
ESP_LV = [ESP_LV_nx,ESP_LV_hx]'; 
EDP_LV = [EDP_LV_nx,EDP_LV_hx]'; 

ESV_RV = [ESV_RV_nx,ESV_RV_hx]'; 
ESP_RV = [ESP_RV_nx,ESP_RV_hx]'; 
EDP_RV = [EDP_RV_nx,EDP_RV_hx]'; 

SV_LV = [SV_LV_nx,SV_LV_hx]'; 


X_data = [ESV_LV,ESP_LV,EDP_LV,ESV_RV,ESP_RV,EDP_RV,SV_LV];

X_model = [opt_pars_nx;opt_pars_hx];

X_data_model = [X_data,X_model];

% Normalize for PCA
X_data = X_data - mean(X_data);
X_data = X_data./std(X_data);

X_model = X_model - mean(X_model);
X_model = X_model./std(X_model);

[coeffs1, transformedData1, ~, ~, explained1] = pca(X_data);
enoughExplained1 = cumsum(explained1)/sum(explained1) >= 95/100;
numberOfComponentsToKeep1 = find(enoughExplained1, 1);
disp("The number of components needed to explain at least 95% of the variance is "+ num2str(numberOfComponentsToKeep1))

[coeffs2, transformedData2, ~, ~, explained2] = pca(X_model);
enoughExplained2 = cumsum(explained2)/sum(explained2) >= 95/100;
numberOfComponentsToKeep2 = find(enoughExplained2, 1);
disp("The number of components needed to explain at least 95% of the variance is "+ num2str(numberOfComponentsToKeep2))

[coeffs3, transformedData3, ~, ~, explained3] = pca(X_data_model);
enoughExplained3 = cumsum(explained3)/sum(explained3) >= 95/100;
numberOfComponentsToKeep3 = find(enoughExplained3, 1);
disp("The number of components needed to explain at least 95% of the variance is "+ num2str(numberOfComponentsToKeep3))

PCA_data = transformedData1(:,1:2); 
PCA_model = transformedData2(:,1:2);

PCA_data_1 = transformedData1(:,1); 
PCA_data_2 = transformedData1(:,2);

PCA_model_1 = transformedData2(:,1);
PCA_model_2 = transformedData2(:,2);

[idx1,C1]=kmeans(X_data,2);
[idx2,C2]=kmeans(X_model,2);
[idx3,C3]=kmeans(X_data_model,2);

