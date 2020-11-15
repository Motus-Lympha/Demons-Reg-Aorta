% Register two images
function [sx,sy,vx,vy, e_min] = register(F,M,opt, scale)
    if nargin<3;  opt = struct();  end
    if ~isfield(opt,'sigma_fluid');      opt.sigma_fluid     = 1.0;              end
    if ~isfield(opt,'sigma_diffusion');  opt.sigma_diffusion = 1.0;              end
    if ~isfield(opt,'sigma_i');          opt.sigma_i         = 1.0;              end
    if ~isfield(opt,'sigma_x');          opt.sigma_x         = 1.0;              end
    if ~isfield(opt,'niter');            opt.niter           = 250;              end
    if ~isfield(opt,'vx');               opt.vx              = zeros(size(M));   end
    if ~isfield(opt,'vy');               opt.vy              = zeros(size(M));   end
    if ~isfield(opt,'stop_criterium');   opt.stop_criterium  = 0.01;             end
    
    vx = opt.vx; vy = opt.vy;
    e  = zeros(1,opt.niter);
    e_min = 1e+100;      % Minimal energy
    
%     % Iterate update fields
    alpha0 = (1/scale)*1e-5;
    alpha = (1/scale)*1e-5;
    max_jumps = 10;
    jump_factor = 200;
    jump_num = 0;
    jump_iter = 0;
    for iter=1:opt.niter
        [ux,uy] = findupdate(F,M,vx,vy, alpha);
        % Regularize update
        ux    = imgaussfilt(ux,opt.sigma_fluid);
        uy    = imgaussfilt(uy,opt.sigma_fluid);
        % Compute step (e.g., max half a pixel)
        step  = opt.sigma_x;
        % Update velocities (demons) - composition
        [vx,vy] = compose(vx,vy,step*ux,step*uy);

        % Regularize velocities
        vx = imgaussfilt(vx,opt.sigma_diffusion);
        vy = imgaussfilt(vy,opt.sigma_diffusion);
        
        % Get Transformation
        [sx,sy] = expfield(vx,vy);  % deformation field
        % Compute energy
        e(iter) = energy(F,M,sx,sy);
        
%         disp(['Iteration: ' num2str(iter) ' - ' 'energy: ' num2str(e(iter))]);
        if e(iter)<e_min
            sx_min = sx; sy_min = sy; % update best fields
            vx_min = vx; vy_min = vy; % update best fields
            e_min  = e(iter);
        end
        
        % Stop criterium
        if iter>1 && (abs(e(iter) - e(max(1,iter-5))) < e(1)*opt.stop_criterium || ...
                e(iter)> min(e(1)+1000,5*e(1)))
            break;
        end
        
        if jump_num >= max_jumps
            break;
        end
        
        theta = 25;
        if iter > theta &&((e(iter) > e(iter-theta) && iter-jump_iter > 20)||...
                (abs(e(iter) - e(max(1,iter-5))) < e(1)*opt.stop_criterium*10)) 
%             disp('doubled Energy increasing/Static')
            alpha = jump_factor*alpha;
            jump_num = jump_num + 1;
            jump_iter = iter;
        else
            alpha = alpha0;
        end
        
    end
    
    % Get Best Transformation
    vx = vx_min;  vy = vy_min;
    sx = sx_min;  sy = sy_min;
    %disp(['Energy: ',num2str(e_min)])
end