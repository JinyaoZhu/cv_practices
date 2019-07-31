function [R,u3] = decomposeEssentialMatrix(E)
% Given an essential matrix, compute the camera motion, i.e.,  R and T such
% that E ~ T_x R
% 
% Input:
%   - E(3,3) : Essential matrix
%
% Output:
%   - R(3,3,2) : the two possible rotations
%   - u3(3,1)   : a vector with the translation information
R = zeros(3,3,2);
W = [0, -1, 0; 1,0,0; 0,0,1];
[U,S,V] = svd(E);
R1 = U*W*V';
R2 = U*W'*V';

if det(R1) < 0
    R1 = -R1;
end

if det(R2) < 0
    R2 = -R2;
end
R(:,:,1) = R1;
R(:,:,2) = R2;
u3 = U(:,end);
end
