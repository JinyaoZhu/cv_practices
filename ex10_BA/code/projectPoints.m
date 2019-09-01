% K: camera matrix
% D: distortion coefficients
% T: transformation from world to camera
% pts_3d: 3D points in world
% pts_2d: 2D points on image
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