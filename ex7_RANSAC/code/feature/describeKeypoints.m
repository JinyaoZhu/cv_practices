function descriptors = describeKeypoints(img, keypoints, r)
% Returns a (2r+1)^2xN matrix of image patch vectors based on image
% img and a 2xN matrix containing the keypoint coordinates.
% r is the patch "radius".
N = size(keypoints, 2);
descriptors = zeros((2*r+1)^2, N);
img = padarray(img, [r, r]);
for i = 1:N
    key_pts = keypoints(:, i) + [r;r];
    patch = img((key_pts(1)-r):(key_pts(1)+r) , (key_pts(2)-r):(key_pts(2)+r));
    descriptors(:, i) = patch(:);
end
end
