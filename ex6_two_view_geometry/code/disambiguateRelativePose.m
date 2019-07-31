function [R,T] = disambiguateRelativePose(Rots,u3,points0_h,points1_h,K1,K2)
% DISAMBIGUATERELATIVEPOSE- finds the correct relative camera pose (among
% four possible configurations) by returning the one that yields points
% lying in front of the image plane (with positive depth).
%
% Arguments:
%   Rots -  3x3x2: the two possible rotations returned by decomposeEssentialMatrix
%   u3   -  a 3x1 vector with the translation information returned by decomposeEssentialMatrix
%   p1   -  3xN homogeneous coordinates of point correspondences in image 1
%   p2   -  3xN homogeneous coordinates of point correspondences in image 2
%   K1   -  3x3 calibration matrix for camera 1
%   K2   -  3x3 calibration matrix for camera 2
%
% Returns:
%   R -  3x3 the correct rotation matrix
%   T -  3x1 the correct translation vector
%
%   where [R|t] = T_C1_C0 = T_C1_W is a transformation that maps points
%   from the world coordinate system (identical to the coordinate system of camera 0)
%   to camera 1.
%
R1 = Rots(:,:,1);
R2 = Rots(:,:,2);
t1 = u3;
t2 = -u3;

M1 = K1*eye(3,4);
M2_1_4 = {[R1,t2],[R2,t2],[R1,t1],[R2,t1]};
M2_1_4 = cellfun(@(x) K2*x, M2_1_4, 'un', 0);

% test triangulate
P1_1_4 = cellfun(@(x) linearTriangulation(points0_h,points1_h,M1,x),...
            M2_1_4,'un',0);
P2_1_4 = cellfun(@(x,y) x*y, M2_1_4, P1_1_4, 'un', 0);

% cost num of 3d points with positive depth
num_pos_1_4 = cellfun(@(x,y) nnz([x(3,:)>0, y(3,:)>0]), ...
                    P1_1_4, P2_1_4, 'un', 1);
                
[~, idx] = max(num_pos_1_4);

M = K2\M2_1_4{idx};
[R,T] = deal(M(:,1:3),M(:,4));

end
