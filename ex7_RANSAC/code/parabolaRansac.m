function [best_guess_history, max_num_inliers_history] = ...
    parabolaRansac(data, max_noise)
% data is 2xN with the data points given column-wise,
% best_guess_history is 3xnum_iterations with the polynome coefficients
%   from polyfit of the BEST GUESS SO FAR at each iteration columnwise and
% max_num_inliers_history is 1xnum_iterations, with the inlier count of the
%   BEST GUESS SO FAR at each iteration.

% rng(2);
num_sample_used = 7;

N = size(data,2);
assert(num_sample_used < N);
num_iters = ceil(log10(1 - 0.99) / log10(1 - (1 - 0.4)^num_sample_used));
fprintf('numbers of iters = %i\n', num_iters);
best_guess_history = zeros(3, num_iters);
max_num_inliers_history = zeros(1, num_iters);
best_guess_p = zeros(3,1);
max_num_inliers = 0;

for i = 1:num_iters
    samples = datasample(data,num_sample_used,2,'Replace',false);
    guess = polyfit(samples(1,:), samples(2,:),2);
    errors = abs(polyval(guess, data(1,:)) - data(2,:));
    inlier_masks = errors <= max_noise;
    num_inliers = nnz(inlier_masks);
    if num_inliers > max_num_inliers
        max_num_inliers = num_inliers;
        % fit model again with all inliers
        inliers = data(:, inlier_masks == 1);
        best_guess_p = polyfit(inliers(1,:), inliers(2,:), 2);
    end
    
    best_guess_history(:,i) = best_guess_p(:);
    max_num_inliers_history(i) = max_num_inliers;
end

end