function error = alignmentError(x, p_W_GT, p_W_estimate)
% x: 7x1 [v;w;s], S_W_est
% p_W_GT: ground point expressed in {W}, 3xN
% p_W_estimate: estimated point expressed in {W}, 3xN
N = size(p_W_GT,2);
S_W_est = twist2HomogMatrix(x(1:6));
S_W_est(1:3,1:3) = x(7)*S_W_est(1:3,1:3);
% for i=1:N
% e = S_W_est*[p_W_estimate(:,i);1] - [p_W_GT(:,i);1];
% error(3*i-2 : 3*i) = e(1:3);
% end
tmp = ones(1,N);
error = S_W_est*[p_W_estimate;tmp] - [p_W_GT;tmp];
error = error(1:3,:);
error = error(:);
end