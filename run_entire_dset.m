clear all
data_dir = 'all_cases';
csv_dir = 'case_roi_data.xlsx';
type = '.bmp';

subfolder_data = dir(data_dir);
num_subfolders = length(subfolder_data)-2;    %number of subfolders in "all_cases"


%all_figs = figure; 
for i = 4:1:num_subfolders+2
    
    key_name = subfolder_data(i).name; %find name of subfolder
    disp(strcat(key_name, ' started'))
    
    path = strcat(data_dir,'/',key_name,'/seq00',type);
    rel_path = strcat(data_dir,'/',key_name);
    checker_image = imread(path);
    [rows, cols] = size(checker_image);  %check dims of first image in sequence 
    check_num = dir(fullfile(rel_path, '*.bmp'));
    num_images = size(check_num,1);      %find number of images in subfolder
    %disp(num_images);
    
    
    %%% h: image height
    %%% w: image width
    %%% x_roi: x (horiz) location of top left corner of ROI
    %%% y_roi: y (vert) location of top left corner of ROI
    %%% roi_w: width of ROI
    %%% roi_h: height of ROI
    
    [~,~,x_roi,y_roi,roi_w,roi_h] = find_csv_params(csv_dir,key_name); %get ROI params for seq 
    
    
    rel_path = strcat(rel_path,'/','seq');
    %%%%%%%Demons main script function here with all params %%%%%
    %main(type, rel_path,num_images,key_name,rows,cols,x_roi,y_roi,roi_w,roi_h)
    %%%%%%%%%%%%%%%%%%%%
    
    %%%visualize
    p = strcat('h',string(i));
    h = visualize(type, rel_path,num_images,key_name,rows,cols,x_roi,y_roi,roi_w,roi_h);
  
 
    disp(strcat(key_name,' done!'))
end



%find params
function [h,w,x_roi,y_roi,roi_w,roi_h] = find_csv_params(csv_dir,name)
    [~,~,r] = xlsread(csv_dir);
    %disp(r)
    %key_name = 'HAM07_RCS';
    [index_r, index_c] = find(strcmp(r, name));
    %disp(index_r)
    %disp(index_c)
    h = r{index_r,index_c + 1};
    w = r{index_r,index_c + 2};
    x_roi = r{index_r,index_c + 3};
    y_roi = r{index_r,index_c + 4};
    roi_w = r{index_r,index_c + 5};
    roi_h = r{index_r,index_c + 6};
end 