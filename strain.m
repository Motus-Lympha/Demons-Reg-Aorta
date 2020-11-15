function E=strain(Ux,Uy)
% Calculate the Eulerian strain from displacement images
%
%  E = STRAIN(Ux,Uy)   or (3D)  E = STRAIN(Ux,Uy, Uz)
%
% inputs,
%   Ux,Uy: The displacement vector images in
%           x and y direction (same as registration variables Tx, Ty)
%   Uz: The displacement vector image in z direction.
%
% outputs,
%   E the 3-D Eulerian strain tensor images defined by Lai et al. 1993
%      with dimensions [SizeX SizeY 2 2] or in 3D [SizeX SizeY SizeZ 3 3]
%
% Source used:
%   Khaled Z et al. "Direct Three-Dimensional Myocardial Strain Tensor 
%   Quantification and Tracking using zHARP"
%
% Function is written by D.Kroon University of Twente (February 2009)
% Initialize output matrix

E=zeros([size(Ux) 2 2]);

% displacement images gradients
[Uxx,Uxy] = gradient(Ux);
[Uyx,Uyy] = gradient(Uy);

% average filtering
sigma = 21;
Uxx = imboxfilt(Uxx, sigma);
Uxy = imboxfilt(Uxy, sigma);
Uyx = imboxfilt(Uyx, sigma);
Uyy = imboxfilt(Uyy, sigma);

% Loop through all pixel locations
for i=1:size(Ux,1)
    for j=1:size(Ux,2)
        % The displacement gradient
        Ugrad=[Uxx(i,j) Uxy(i,j); Uyx(i,j) Uyy(i,j)];
        % the 3-D Eulerian strain tensor
         e = 1/2*(Ugrad + Ugrad' + Ugrad'*Ugrad); 
        % Store tensor in the output matrix
        E(i,j,:,:)=e;
    end
end
end