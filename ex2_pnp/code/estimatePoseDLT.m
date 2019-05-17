 function M = estimatePoseDLT(p, P, K)
 % p: 2D points on undistorted image
 % P: 3D point in world
 % K: camera matrix
 assert(size(p,2) == size(P,2));
 assert(size(p,2) >= 6);
 n_point = size(p,2);
 p_nromalized = K\[p; ones(1, size(p,2))];
 Q = zeros(n_point*2,12);
 
 row_idx = 1;
 for i = 1:n_point
     pt_3d = P(:,i);
     pt_2d = p_nromalized(:,i);
     tmp1 = [pt_3d', 1, zeros(1,4), -pt_2d(1)*[pt_3d', 1]];
     tmp2 = [zeros(1,4), pt_3d', 1, -pt_2d(2)*[pt_3d', 1]];
     Q(row_idx:row_idx+1, :) = [tmp1; tmp2];
     row_idx= row_idx + 2;
 end
 
[~,~,V] = svd(Q);
M = V(:,end);
M = reshape(M, [4,3])';
if M(3,4) < 0
    M = -M;
end
% up to scale M
R = M(1:3, 1:3);
t = M(1:3,4);
% recover rotation mat
[U,~,V] = svd(R);
R_est = U*V';
% recover scale
alpha = norm(R_est)/norm(R);
% recover translation
t_est = alpha*t;
 
M = [R_est, t_est];

end