function h = visualize(type, rel_path,num_images,key_name,rows,cols,x_roi,y_roi,roi_w,roi_h) 



    TIK = 0:1:20;

    multiplier = 1;
    strain_multiplier = 1;
    if strcmp(key_name,'HAM07_LLS3')
        %key_name_t = 'Patient 1: Sample Number 6';
        key_name_t = 'Subsection 6';
        strain_multiplier = 3;
    end
    if strcmp(key_name,'HAM07_RCS3')
        num_images = 13;
        %key_name_t = 'Patient 1: Sample Number 1';
        key_name_t = 'Subsection 1';
        strain_multiplier = 3;
        TIK = 0:5:30;
    end
    if strcmp(key_name,'HAM07_RCS')
        num_images = 15;
        %key_name_t = 'Patient 1: Sample Number 2';
        key_name_t = 'Subsection 2';
        strain_multiplier = 3;
        TIK = 0:5:35;
    end
    if strcmp(key_name,'HAM07_LCS2')
        num_images = 11;
        %key_name_t = 'Patient 1: Sample Number 3';
        key_name_t = 'Subsection 3';
        strain_multiplier = 3;
        TIK = 0:5:25;
    end
    if strcmp(key_name,'HAM06_RLS2')
        num_images = 15;
        %key_name_t = 'Patient 1: Sample Number 4';
        key_name_t = 'Subsection 4';
        strain_multiplier = 3;
        TIK = 0:5:35;
    end
    if strcmp(key_name,'HAM06_RCS2')
        num_images = 20;
        %key_name_t = 'Patient 1: Sample Number 5';
        key_name_t = 'Subsection 5';
        strain_multiplier = 3;
    end
    if strcmp(key_name,'BAR13_LLS')
        num_images = 9;
        multiplier = 10;
        strain_multiplier = 1/300;
        key_name_t = 'Patient 2: Sample Number 1';
    end
    if strcmp(key_name,'BAR13_LCS3')
        num_images = 7;
        multiplier = 10;
        strain_multiplier = 1/300;
        key_name_t = 'Patient 2: Sample Number 2';
    end
    %if strcmp(key_name,'BAR13_LCS3')
    %    num_images = 7;
    %    strain_multiplier = 1/300;
    %    key_name_t = 'Patient 2: Sample Number 3';
    %end
    if strcmp(key_name,'BAR13_LCS')
        num_images = 10;
        strain_multiplier = 1/300;
        key_name_t = 'Patient 2: Sample Number 3';
    end
    
    
    
    
    
    
    load_array = zeros(num_images - 1,1);
    cs_array = zeros(num_images -  1,1);
    l_0 = 3e-2;
    csv_dir = "csv_files/";
    path = rel_path;
    digits = 2;
    end_num = num_images-1;
    image_size = [rows cols]; % in [row col] form
    extension = type;
    trial_id = key_name;

    load(strcat('disp_mats/','displacements_tensile_test_',trial_id,'.mat'));
    %disp(total_displacements)
    end_num = num_images-1;
    % Calculate Strain Fields from total_displacement field
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
        Exx(strain_level,:,:) = squeeze(squeeze(E(:,:,1,1)));
        Exy(strain_level,:,:) = squeeze(squeeze(1/2*(E(:,:,1,2)+E(:,:,2,1))));
        Eyy(strain_level,:,:) = squeeze(squeeze(E(:,:,2,2)));
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

    %save(strcat('strain_mats/','Exx_',trial_id,'.mat'),'Exx');
    %save(strcat('strain_mats/','Exy_',trial_id,'.mat'),'Exy');
    %save(strcat('strain_mats/','Eyy_',trial_id,'.mat'),'Eyy');


    % View Strain Fields
    
    
    %get csv files for load and strain 
    M = xlsread(strcat(csv_dir,key_name,".xlsx"));
    for i = 1:1:(num_images - 1)
        load_array(i) = M(10 + 1000*(i-1),2);
        cs_array(i) = (M(10 + 1000*(i-1),3) - M(10,3))/l_0;
    end
    
    disp(cs_array)

    
    
    
    xx_holder = zeros(num_images-1,1);
    yy_holder = zeros(num_images-1,1);
    xy_holder = zeros(num_images-1,1);
    
    boxvals_xx = zeros((roi_w+1)*(roi_h+1),num_images-1);
    boxvals_yy = zeros((roi_w+1)*(roi_h+1),num_images-1);
    boxvals_xy = zeros((roi_w+1)*(roi_h+1),num_images-1);
    
    for i = 1:1:(num_images-1)
        xx_tmp = Exx(i,:,:);
        yy_tmp = Eyy(i,:,:);
        xy_tmp = Exy(i,:,:);
        
        mean_xx = mean(xx_tmp(:));
        mean_yy = mean(yy_tmp(:));
        mean_xy = mean(xy_tmp(:));
        
        xx_holder(i) = mean_xx;
        yy_holder(i) = mean_yy;
        xy_holder(i) = mean_xy; 
        
        boxvals_xx(:,i) = xx_tmp(:);
        boxvals_yy(:,i) = yy_tmp(:);
        boxvals_xy(:,i) = xy_tmp(:);

    end
    
    
    Strain_clamp = cs_array*81*strain_multiplier;
    Strain_label = round(Strain_clamp);

    strain_plot_y = yy_holder*100*multiplier;
    strain_plot_x = xx_holder*100;
    strain_plot_shear = xy_holder*100;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h = figure;
    subplot(3,1,2)
    plot(Strain_clamp,strain_plot_x,'linew',1.8)
    hold on
    boxplot(boxvals_xx(:,1:num_images-1)*50,'positions', Strain_clamp,'labels',Strain_label,'symbol','','Whisker',0.7) 
    set(findobj(gca,'type','line'),'linew',1.8)
    xlabel('Clamp Strain (%)','FontSize',14,'FontWeight','bold')
    ylabel('Demons X Strain','FontSize',14,'FontWeight','bold')
    ylim([-40 40])
    set(gca,'XTick',TIK, 'XTickLabel',TIK)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold off
  
    subplot(3,1,1)
    yyaxis left
    plot(Strain_clamp,strain_plot_y,'linew',1.8)
    hold on
    boxplot(boxvals_yy(:,1:num_images-1)*100*multiplier,'positions', Strain_clamp,'labels',Strain_label,'symbol','','Whisker',0.7) 
    set(findobj(gca,'type','line'),'linew',1.8)
    xlabel('Clamp Strain (%)','FontSize',14,'FontWeight','bold')
    ylabel('Demons Y Strain','FontSize',14,'FontWeight','bold')
    ylim([0 100])
    hold on 
    yyaxis right
    plot(Strain_clamp, load_array,'linew',2.5)
    hold off
    yyaxis right
    ylabel('Load (N)','FontSize',14,'FontWeight','bold')
    set(gca,'XTick',TIK, 'XTickLabel',TIK)
    %%%%%%%%%%%%%


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    
    subplot(3,1,3)
    plot(Strain_clamp,strain_plot_shear,'linew',1.8)
    hold on
    boxplot(boxvals_xy(:,1:num_images-1)*50,'positions', Strain_clamp,'labels',Strain_label,'symbol','','Whisker',0.7) 
    set(findobj(gca,'type','line'),'linew',1.8)
    xlabel('Clamp Strain (%)','FontSize',14,'FontWeight','bold')
    ylabel('Demons Shear Strain','FontSize',14,'FontWeight','bold')
    ylim([-40 40])
    hold off
    set(gca,'XTick',TIK, 'XTickLabel',TIK)

    sgtitle(key_name_t,'FontSize',18,'FontWeight','bold','Interpreter','none')
    set(findobj(gcf,'type','axes'),'FontSize',12,'FontWeight','Bold');

    
    
    
    
%     figure;
%     plot(xx_holder/5,'linew',1.3)
%     hold on 
%     plot(yy_holder,'linew',1.3)
%     hold on
%     plot(xy_holder/5,'linew',1.3) 
%     hold on
%     plot(load_array/5,'linew',1.3)
%     title(key_name,'FontSize',14,'FontWeight','bold','Interpreter','none')
%     xlabel('strain','FontSize',12,'FontWeight','bold')
%     ylabel('demons strain','FontSize',12,'FontWeight','bold')
%     legend('XX','YY','XY','LOAD')
%     
end   
    