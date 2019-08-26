function I = warpImage(I_R, W)
% I_R: reference image
% W: warpping matrix, affine warp 2x3 matrix
% I: warpped image
[ROW, COL] = size(I_R);
I = uint8(zeros(ROW, COL));
[U,V] = meshgrid(1:COL, 1:ROW);
pix_I = [U(:), V(:)]';
pix_I_R = W*[pix_I;ones(1,ROW*COL)]; % [u;v]

% select pixels in border
idx = pix_I_R(1,:)>0.5 & pix_I_R(1,:)<COL+0.5 ...
    & pix_I_R(2,:)>0.5 & pix_I_R(2,:)<ROW+0.5;
pix_I = pix_I(:,idx);
pix_I_R = pix_I_R(:,idx);

% to integer
pix_I_R = round(pix_I_R);
% copy intensity
for i = 1:size(pix_I,2)
    I(pix_I(2,i), pix_I(1,i)) = I_R(pix_I_R(2,i), pix_I_R(1,i));
end
end
