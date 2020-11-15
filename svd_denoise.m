%{
Denoises image with SVD
%}
function out = svd_denoise(M)
[U,S,V] = svd(M);
s = diag(S);
m = sqrt(mean(s.^2, 'all'));
k = length(s(s>m));
S(k+1:end,k+1:end) = 0;
out = U*S*V';
end