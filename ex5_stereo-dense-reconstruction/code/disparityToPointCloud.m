function [points, intensities] = disparityToPointCloud(...
    disp_img, K, baseline, left_img)
% points should be 3xN and intensities 1xN, where N is the amount of pixels
% which have a valid disparity. I.e., only return points and intensities
% for pixels of left_img which have a valid disparity estimate! The i-th
% intensity should correspond to the i-th point.

[X,Y] = meshgrid(1:1:size(left_img,2), 1:1:size(left_img,1));

px_left = [X(:) Y(:) ones(numel(left_img), 1)];
px_right = px_left;
px_right(:,1) = px_right(:,1) - disp_img(:);

px_left = px_left(disp_img(:)>0,:); % Nx3 (x, y, 1) (col, row, 1) (u, v, 1)
px_right = px_right(disp_img(:)>0,:); % Nx3

 % px_left' => 3xN (x;y;1)
bv_left = K \ px_left';
bv_right = K \ px_right';

% bv_left => 3xN (x;y;1)

points = zeros(3, size(bv_left,2));
b = [baseline;0;0];

for i = 1:size(bv_left, 2)
    A = [bv_left(:,i) , -bv_right(:,i)]; % 3x2
    lambda = (A'*A)\A'*b; % 2x1
    points(:,i) = lambda(1)*bv_left(:,i);
end

intensities = left_img(disp_img(:)' > 0);

end
