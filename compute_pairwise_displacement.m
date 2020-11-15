%{
Reads in images and determines pairwise displacements for all images
%}

function [displacements, energy] = compute_pairwise_displacement(end_num, data, image_size)
displacements= zeros(end_num, image_size(1), image_size(2), 2);
energy = zeros(end_num, 1);

niter           = 10000;
sigma_fluid     = 1.0; % regularize update      field
sigma_diffusion = 1.0; % regularize deformation field
sigma_i         = 1.0; % weight on similarity term
sigma_x         = 0.5; % weight on spatial uncertainties (maximal step)
do_display      = 0;   % display iterations
do_plot_energy  = 0;   % display energy plot
stop_criterium  = 0.00001; % Minimum energy step
nlevel          = 35;

data = 256*(data - min(data,[],'all'))/range(data,'all');

for i = 1:end_num
    %disp(strcat('Starting Image ',num2str(i)))
    M = squeeze(data(i+1, :,:));
    F = squeeze(data(i,:,:));
    vx = zeros(size(squeeze(F))); % deformation field
    vy = zeros(size(squeeze(F)));
    for k = nlevel:-1:1
        %disp(['Register level: ' num2str(k) '...']);
         % downsample
        scale = (1.1)^-(k-1);
        F1 = imresize(F,scale);
        M1 = imresize(M,scale);
        vx1 = imresize(vx*scale,scale);
        vy1 = imresize(vy*scale,scale);
        opt = struct('niter',niter, 'sigma_fluid',sigma_fluid*scale, ...
        'sigma_diffusion',sigma_diffusion*scale, 'sigma_i',sigma_i*scale, ...
        'sigma_x',sigma_x*scale, 'do_display',do_display, ...
        'do_plotenergy',do_plot_energy, 'stop_criterium', stop_criterium, ...
        'vx',vx1, 'vy',vy1);
        [sx,sy,vx1,vy1,e_min] = register(F1,M1,opt, scale);
        vx = imresize(vx1/scale,size(M));
        vy = imresize(vy1/scale,size(M));
    end
    energy(i) = e_min;
    displacements(i,:,:,:) = squeeze(cat(3,sx,sy));
end
end