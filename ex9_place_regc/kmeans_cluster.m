function [idx, C] = kmeans_cluster(X, k)
%KMEANS_CLUSTER kmeans clustering algorithm, using euclidean distance
%   For N p-dimensional data
%   Input:
%       X: Nxp matrix.
%       k: how many clusters is desired.
%   Output:
%       idx: Nx1, each value stands for the cluster label.
%       C: kxp, the ith row of the matrix is the center of the kth cluster.
[N, p]= size(X);
centers = datasample(X,k,1,'Replace',false); % kxp
delta_p = 1e10;
d = zeros(1,k); % distance
idx = zeros(N,1);

while delta_p > 1e-3
    centers_new = zeros(k,p+1); % last column as counter
    for i=1:N
        for j = 1:k
            d(j) = norm(centers(j,:) - X(i,:),2);
        end
        [~,idx(i)] = min(d);
        centers_new(idx(i),1:p) = centers_new(idx(i),1:p) + X(i,:);
        centers_new(idx(i),end) = centers_new(idx(i),end) + 1;
    end
    for j = 1:k
        centers_new(j,1:p) = centers_new(j,1:p)/centers_new(j,end);
    end
    
    delta_p = norm(centers_new(:,1:p) - centers, 2);
    centers = centers_new(:,1:p);
end
C = centers;
end

