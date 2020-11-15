% Get energy
function e = energy(F,M,sx,sy)
    % Intensity difference
    Mp = imwarp(M, cat(3,sy,sx));
    diff2  = (F-Mp).^2;
    area   = size(M,1)*size(M,2);
    e  = sum(diff2(:)) / area;
end