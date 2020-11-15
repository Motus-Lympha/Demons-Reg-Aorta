% Find update between two images
function [ux,uy] = findupdate(F,M,vx,vy, alpha)
    % Get Transformation
    [sx,sy] = expfield(vx,vy);
    % Interpolate updated image
    M_prime = imwarp(M, cat(3,sy,sx));   
    
    % image difference
    diff = F - M_prime;
    
    % moving image gradient
    [gy,gx] = gradient(M_prime);   % image gradient
    
    ux = alpha.*(diff.*gx);
    uy = alpha.*(diff.*gy);

    % Zero non overlapping areas
    ux(F==0)       = 0; uy(F==0)       = 0;
    ux(M_prime==0) = 0; uy(M_prime==0) = 0;
end
