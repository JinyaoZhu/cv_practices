% K: camera matrix 3x3
% D: distortion coefficients 1x2
% T: transformation from world to camera 3x4
% pts_3d: 3D points in world 3xN
% pts_2d: 2D points on image 2xN
function pts_2d = projectPoints(K, D, T, pts_3d)
% project to camera coordinate
pts_2d = T*[pts_3d;ones(1,size(pts_3d,2))];
% on normalized image plane
pts_2d = pts_2d(1:3,:)./[pts_2d(3,:);pts_2d(3,:);pts_2d(3,:)];
% len distortion
r = vecnorm(pts_2d(1:2,:));
d = (1 + D(1)*r.^2 + D(2)*r.^4);
pts_2d(1:2,:) = [d;d].*pts_2d(1:2,:);
% on image
pts_2d = K*pts_2d;
pts_2d = pts_2d(1:2,:);
end

function n = vecnorm(x, dim)
% VECNORM(x, dim)
% Norm of a vector
% If x is matrix, gets norm of every row or column
    if nargin < 2
        dim = 1;
    end
    n = sqrt(sum(x.^2, dim));
end