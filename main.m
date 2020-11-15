function main(type, rel_path,num_images,key_name,rows,cols,x_roi,y_roi,roi_w,roi_h)
    %% Input Variables
    path = rel_path;
    digits = 2;
    end_num = num_images-1;
    image_size = [rows cols]; % in [row col] form
    extension = type;
    trial_id = key_name;

    %% Read in Image Data

    data = read_images(end_num, digits, image_size, path, extension);

    %% Compute Pairwise Displacments using Parallelized SGDR Diffeomorphic Demons
    [pairwise_displacements, ~] = compute_pairwise_displacement(end_num, data, image_size);
    % disp(energy);
    pairwise_displacements = flip(pairwise_displacements, 4); % Change from(i,j) to (x,y)
    % 
    % % Find Total Displacments via iterative forward mapping
    total_displacements = zeros(end_num, image_size(1), image_size(2), 2);
    % 
    total_displacements(1,:,:,:) = imwarp(squeeze(pairwise_displacements(1,:,:,:)),squeeze(pairwise_displacements(1,:,:,:)),'bicubic');
    for i = 2:end_num
        total_displacements(i,:,:,:) = imwarp(squeeze(total_displacements(i-1,:,:,:)) + squeeze(pairwise_displacements(i,:,:,:)),squeeze(pairwise_displacements(i,:,:,:)),'bicubic'); 
    end

    save(strcat('disp_mats/','displacements_tensile_test_',trial_id,'.mat'),'total_displacements');

    %% Plot Displacement Fields
    % figure()
    % contourf(squeeze(total_displacements(5,:,:,1)))
    % title('5%')
    % colorbar()
    % figure()
    % contourf(squeeze(total_displacements(10,:,:,2)))
    % title('10%')
    % colorbar()
    % figure()
    % contourf(squeeze(total_displacements(13,:,:,2)))
    % title('15%')
    % colorbar()
    % figure()
    % contourf(squeeze(total_displacements(20,:,:,2)))
    % title('20%')
    % colorbar()

    %% Calculate Strain Fields from total_displacement field
    %load(strcat('displacements_tensile_test_',trial_id,'.mat'))
    %
    Exx = zeros(end_num,image_size(1), image_size(2));
    Exy = zeros(end_num,image_size(1), image_size(2));
    Eyy = zeros(end_num,image_size(1), image_size(2));
    % 
    for strain_level = 1:end_num
        K1 = svd_denoise(squeeze(total_displacements(strain_level,:,:,1)));
        K2 = svd_denoise(squeeze(total_displacements(strain_level,:,:,2)));
        %K1 = squeeze(total_displacements(strain_level,:,:,1));
        %K2 = squeeze(total_displacements(strain_level,:,:,2));
        E = strain(K1, K2);
        Exx(strain_level,:,:) = rot90(squeeze(squeeze(E(:,:,1,1))),2);
        Exy(strain_level,:,:) = rot90(squeeze(squeeze(1/2*(E(:,:,1,2)+E(:,:,2,1)))),2);
        Eyy(strain_level,:,:) = rot90(squeeze(squeeze(E(:,:,2,2))),2);
    end
    % 
    % 
    % % Restrict to ROI of image (Manually Selected)
    min_x = y_roi;
    min_y = x_roi;
    w = roi_h;
    h = roi_w;
    max_x = min_x + w;
    max_y = min_y + h;
    % 
    Exx = Exx(:,min_x:max_x,min_y:max_y);
    Eyy = Eyy(:,min_x:max_x,min_y:max_y);
    Exy = Exy(:,min_x:max_x,min_y:max_y);

    save(strcat('strain_mats/','Exx_',trial_id,'.mat'),'Exx');
    save(strcat('strain_mats/','Exy_',trial_id,'.mat'),'Exy');
    save(strcat('strain_mats/','Eyy_',trial_id,'.mat'),'Eyy');


    %% View Strain Fields
    
    xx_holder = zeros(num_images,1);
    yy_holder = zeros(num_images,1);
    xy_holder = zeros(num_images,1);
    for i = 1:1:num_images-1
        xx_tmp = Exx(i,:,:);
        yy_tmp = Eyy(i,:,:);
        xy_tmp = Exy(i,:,:);
        
        mean_xx = mean(xx_tmp(:));
        mean_yy = mean(yy_tmp(:));
        mean_xy = mean(xy_tmp(:));
        
        xx_holder(i) = mean_xx;
        yy_holder(i) = mean_yy;
        xy_holder(i) = mean_xy;    
    end
    
    
    figure
    plot(xx_holder)
    hold on 
    plot(yy_holder)
    hold on
    plot(xy_holder) 
    title(key_name)
    xlabel('strain')
    ylabel('demons_strain')
    legend('XX','YY','XY')
    
    
    
    % strain_level = 5;
    % E_roi_x = squeeze(Exx(strain_level,:,:));
    % E_roi_y = squeeze(Eyy(strain_level,:,:));
    % E_roi_xy = squeeze(Exy(strain_level,:,:));
    % 
    % 
    % 
    % figure()
    % contourf(E_roi_x);
    % title('50%')
    % colorbar()
    % title('X Strain')
    % 
    % figure()
    % contourf(E_roi_y);
    % title('50%')
    % colorbar()
    % title('Y Strain')
    % 
    % figure()
    % contourf(E_roi_xy);
    % title('50%')
    % colorbar()
    % title('Shear Strain')
    % 
    % disp('X Strain')
    % disp(mean(E_roi_x,'all'))
    % disp(std(E_roi_x,[],'all'));
    % disp('Y Strain')
    % disp(mean(E_roi_y,'all'))
    % disp(std(E_roi_y,[],'all'));
    % disp('XY Strain')
    % disp(mean(E_roi_xy,'all'))
    % disp(std(E_roi_xy,[],'all'));
end