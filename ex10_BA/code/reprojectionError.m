function error = reprojectionError(x, observations, K)
% x: hidden_states [t_1; ...; t_n; P_1;...;P_m]
% observations: [n;m; O_1;...;O_n]
% K: camera matrix

x = x(:);
observations = observations(:);

n = observations(1); % number of frames / camera poses
m = observations(2); % number of landmarks
O_i_idx_start = 3; % point to the i th observation vector

error = zeros(2*(length(observations) - 2 - n)/3,1);
idx_error = 1;
for i = 1:n
    % camera pose
    T_W_C = twist2HomogMatrix(x(6*i-5:6*i));
    % compute the inverse homogenous matrix
    T_C_W = eye(4);
    T_C_W(1:3,1:3) = T_W_C(1:3,1:3)';
    T_C_W(1:3,4) = - T_W_C(1:3,1:3)'*T_W_C(1:3,4);
    % numbers of observations in i th frame
    k_i = observations(O_i_idx_start); 
    O_i_idx_end = O_i_idx_start + 2*k_i + k_i;
    % O_i = [p_i_1; ... p_i_k; l_i_1; ...; l_i_k]
    O_i = observations(O_i_idx_start + 1 : O_i_idx_end); 
    O_i_idx_start = O_i_idx_end + 1; % update index
    
    p_i = flipud(reshape(O_i(1: 2*k_i),[2,k_i]));
    l_i = O_i(2*k_i + 1 : 2*k_i + k_i);
    P_l_i = reshape(x(6*n + 1: end),[3,m]);
    P_l_i = P_l_i(:, l_i);
    p_i_predict = projectPoints(K, [0,0], T_C_W, P_l_i);
    error_pix = p_i_predict - p_i;
    error(idx_error:idx_error+2*k_i-1) = error_pix(:);
    idx_error = idx_error+2*k_i;
    
    if 0
        figure(3);
        plot(p_i_predict(1, :), p_i_predict(2, :), 'rx');
        hold on;
        plot(p_i(1, :), p_i(2, :), 'gx');
        hold off;
        axis equal;
    end
    
%     % go through all observation in current frame
%     for k = 1:k_i
%         % observation in pixel coordinate, [x;y]
%         p_i_k = flipud(O_i(2*k-1: 2*k));
%         % corresponding landmark label
%         l_i_k = O_i(2*k_i + k);
%         % corresponding 3D landmarks
%         P_l_i_k = x(6*n + l_i_k*3 - 2 : 6*n + l_i_k*3);
%         % reprojection
%         p_i_k_predict = projectPoints(K, [0,0], T_C_W, P_l_i_k);
%         % reprojection error
%         error_pix = p_i_k_predict - p_i_k;
%         % add to the error vector
%         error(idx_error:idx_error+1) = error_pix;
%         idx_error = idx_error+2;
%     end
end
end