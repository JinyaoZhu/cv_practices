function hidden_state = runBA(hidden_state, observations, K)
% Update the hidden state, encoded as explained in the problem statement,
% with 20 bundle adjustment iterations.
n_frames = observations(1);
n_errors = 2*(length(observations) - 2 - n_frames)/3;
n_states = length(hidden_state);
pattern = spalloc(n_errors, n_states, 9*n_errors); % n_erros X n_states
O_i_idx_start = 3; % point to the i th observation vector
idx_error = 1;
disp('Building Jacobian pattern ...');
for i = 1:n_frames
    disp(strcat('frame ',num2str(i),'/',num2str(n_frames),':'));
    tic;
    % camera pose
    indices_poses = 6*i-5:6*i;
    % numbers of observations in i th frame
    k_i = observations(O_i_idx_start); 
    O_i_idx_end = O_i_idx_start + 2*k_i + k_i;
    % O_i = [p_i_1; ... p_i_k; l_i_1; ...; l_i_k]
    O_i = observations(O_i_idx_start + 1 : O_i_idx_end); 
    O_i_idx_start = O_i_idx_end + 1; % update index
    
    pattern(idx_error:idx_error+2*k_i-1, indices_poses) = 1;
    
    % go through all observation in current frame
    for k = 1:k_i
        l_i_k = O_i(2*k_i + k);
        indices_landmarks = 6*n_frames + l_i_k*3 - 2 : 6*n_frames + l_i_k*3;
        pattern(idx_error:idx_error+1, indices_landmarks) = 1;
        idx_error = idx_error+2;
    end    
    toc
end
figure;
spy(pattern);

error_function = @(x) reprojectionError(x, observations, K);
options = optimoptions('lsqnonlin', ...
    'Algorithm','trust-region-reflective', ...
    'Display','iter', 'MaxIterations',50);
options.JacobPattern = pattern;
options.UseParallel = true;
x0 = hidden_state;
disp('Start BA ...');
hidden_state = lsqnonlin(error_function,x0,[],[],options);
end
