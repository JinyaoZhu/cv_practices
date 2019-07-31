function P = linearTriangulation(p1,p2,M1,M2)
% LINEARTRIANGULATION  Linear Triangulation
%
% Input:
%  - p1(3,N): homogeneous coordinates of points in image 1
%  - p2(3,N): homogeneous coordinates of points in image 2
%  - M1(3,4): projection matrix corresponding to first image
%  - M2(3,4): projection matrix corresponding to second image
%
% Output:
%  - P(4,N): homogeneous coordinates of 3-D points
N = size(p1,2);
P = zeros(4,N);
A = zeros(6,4);
for i = 1:N
  pt1 = p1(:,i);
  pt2 = p2(:,i);
  A(1:3,:) = cross2Matrix(pt1)*M1;
  A(4:6,:) = cross2Matrix(pt2)*M2;
  [~,~,V] = svd(A);
  pt_3d = V(:,end);
  P(:,i) = pt_3d/pt_3d(end);
end

end