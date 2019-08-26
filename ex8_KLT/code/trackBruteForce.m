function [dx, ssds] = trackBruteForce(I_R, I, x_T, r_T, r_D)
% I_R: reference image, I: image to track point in, x_T: point to track,
% expressed as [x y]=[col row], r_T: radius of patch to track, r_D: radius
% of patch to search dx within; dx: translation that best explains where
% x_T is in image I, ssds: SSDs for all values of dx within the patch
% defined by center x_T and radius r_D.
ssds = zeros(r_D+1);
p5 = -r_D:r_D;
p6 = -r_D:r_D;
template = getWarpedPatch(I_R, getSimWarp(0,0,0,1), x_T, r_T);
for i = 1:length(p5)
    for j = 1:length(p6)
        W = [1,0,p5(i); 0, 1, p6(j)];
        patch = getWarpedPatch(I, W, x_T, r_T);
%         ssd = pdist2(template(:)',patch(:)','squaredeuclidean');
        ssd = sum((template(:)'-patch(:)').^2);
        ssds(i,j) = ssd;
    end
end
[~,I] = min(ssds(:));
[I_row, I_col] = ind2sub(size(ssds),I);
dx = [p5(I_row),p6(I_col)];
end