function [W, p_hist] = trackKLT(I_R, I, x_T, r_T, num_iters)
% I_R: reference image, I: image to track point in, x_T: point to track,
% expressed as [x y]=[col row], r_T: radius of patch to track, num_iters:
% amount of iterations to run; W(2x3): final W estimate, p_hist 
% (6x(num_iters+1)): history of p estimates, including the initial
% (identity) estimate
W = getSimWarp(0, 0, 0, 1);
template = getWarpedPatch(I_R, W, x_T, r_T);
i_R = template(:);
 
xs = -r_T:r_T;
ys = -r_T:r_T;
n = numel(xs);
xy1 = [kron(xs, ones([1 n]))' kron(ones([1 n]), ys)' ones([n*n 1])];
dwdx = kron(xy1, eye(2));
dwdx = reshape(dwdx',[6,2,n*n]);
dwdx = permute(dwdx,[2 1 3]);

p_hist = zeros(6, num_iters+1);
p_hist(:,1) = W(:);

for i=1:num_iters
    
    patch_big = getWarpedPatch(I, W, x_T, r_T+1);
    patch = patch_big(2:end-1, 2:end-1);
    ix = conv2(1, [1 0 -1], patch_big(2:end-1, :), 'valid');
    iy = conv2([1 0 -1], 1, patch_big(:, 2:end-1), 'valid');
    didw = reshape([ix(:) iy(:)]',[2,1,n*n]);
    didw = permute(didw,[2 1 3]);
    didp = zeros(n*n,6);
    for j = 1:n*n
        didp(j, :) = didw(1,1:2,j)*dwdx(1:2,1:6,j);
    end
    
    i_P = patch(:);
    H = didp'*didp;
    
    delta_p = H^(-1)*didp'*(i_R - i_P);
    
    W(:) = W(:) + delta_p;
    p_hist(:,i+1) = W(:);
    
    if norm(delta_p) < 1e-3
        break;
    end
end

end
