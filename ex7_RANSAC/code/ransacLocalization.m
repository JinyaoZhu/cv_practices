function [R_C_W, t_C_W, query_keypoints, all_matches, best_inlier_mask, ...
    max_num_inliers_history] = ransacLocalization(...
    query_image, database_image, database_keypoints, p_W_landmarks, K)
% query_keypoints should be 2x1000
% all_matches should be 1x1000 and correspond to the output from the
%   matchDescriptors() function from exercise 3.
% best_inlier_mask should be 1xnum_matched (!!!) and contain, only for the
%   matched keypoints (!!!), 0 if the match is an outlier, 1 otherwise.

num_iters = 2000; % numbers of ietration in RANSAC

harris_patch_size = 9;
harris_kappa = 0.08;
num_keypoints = 1000;
nonmaximum_supression_radius = 8;
descriptor_radius = 9;
match_lambda = 6;
inlier_th_pix = 10;

harris_scores_query = harris(query_image, harris_patch_size, harris_kappa);

query_keypoints = selectKeypoints(harris_scores_query, ...
num_keypoints, nonmaximum_supression_radius);
keypoints_database = database_keypoints;

descriptors_1 = describeKeypoints(query_image, query_keypoints, descriptor_radius);
descriptors_2 = describeKeypoints(database_image, keypoints_database, descriptor_radius);

all_matches = matchDescriptors(descriptors_1, descriptors_2, match_lambda);

% converte [row;col] to [u;v]
matched_query_keypoints = flipud(query_keypoints(:, all_matches>0));
matched_landmarks = p_W_landmarks(:, all_matches(all_matches>0));

num_matched = size(matched_query_keypoints,2);
best_inlier_mask = zeros(1, num_matched);
max_num_inlier = 0;
max_num_inliers_history = zeros(1,num_iters);


for i = 1:num_iters
    [sampled_keypoints, idx] = ...
        datasample(matched_query_keypoints, 6, 2, 'Replace', false);
    sampled_landmarks = matched_landmarks(:,idx);

    guess = estimatePoseDLT(sampled_keypoints, sampled_landmarks, K);
    guess_R = guess(1:3, 1:3);
    guess_t = guess(1:3, 4);
    
    keypoint2d_pre = projectPoints(K, zeros(1,2), [guess_R,guess_t], matched_landmarks);
    error = matched_query_keypoints - keypoint2d_pre;
    error_dist = sqrt(sum(error.^2, 1));
 
    num_inliers = nnz(error_dist < inlier_th_pix);
  
    if (max_num_inlier < num_inliers) && (num_inliers >= 6)
        max_num_inlier = num_inliers;
        best_inlier_mask = double(error_dist < inlier_th_pix);
    end
    
    max_num_inliers_history(i) = max_num_inlier;
end

inliers_keypoints = matched_query_keypoints(:,best_inlier_mask>0);
inliers_landmarks = matched_landmarks(:,best_inlier_mask>0);
best_guess = estimatePoseDLT(inliers_keypoints, inliers_landmarks, K);
R_C_W = best_guess(1:3, 1:3);
t_C_W = best_guess(1:3,4);
end
