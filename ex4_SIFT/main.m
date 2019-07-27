clear 
close all;
clc;

num_scales = 4; % Scales per octave.
num_octaves = 5; % Number of octaves.
sigma = 1.2;
contrast_threshold = 0.04;
image_file_1 = 'images/img_1.jpg';
image_file_2 = 'images/img_2.jpg';
rescale_factor = 0.2; % Rescaling of the original image for speed.

images = {getImage(image_file_1, rescale_factor),...
    getImage(image_file_2, rescale_factor)};

final_kpt_locations = cell(1, 2);
descriptors = cell(1, 2);

for img_idx = 1:2
    % 1)    image pyramid. Number of images in the pyarmid equals
    %       'num_octaves'.
    curr_image = images{img_idx};
    image_pyramid = cell(1,num_octaves);
    image_pyramid{1} = curr_image;
    for i = 2:num_octaves
        image_pyramid{i} = imresize(image_pyramid{i-1}, 0.5);
    end
    
    % 2)    blurred images for each octave. Each octave contains
    %       'num_scales + 3' blurred images.
    blurred_images = cell(1, num_octaves);
    imgs_per_oct = num_scales+3;
    for oct_idx = 1:num_octaves
        octave_stack = zeros([size(image_pyramid{oct_idx}) imgs_per_oct]);
        for stack_idx = 1:imgs_per_oct
            s = stack_idx - 2;
            octave_stack(:, :, stack_idx) = ...
                imgaussfilt(image_pyramid{oct_idx}, sigma * 2^(s / num_scales));
        end
        blurred_images{oct_idx} = octave_stack;
    end
    
    % 3)    'num_scales + 2' difference of Gaussians for each octave.
    DoGs = cell(1, num_octaves);
    for oct_idx = 1:num_octaves
        DoG =  zeros(size(blurred_images{oct_idx})-[0 0 1]);
        num_dogs_per_octave = size(DoG, 3);
        for dog_idx = 1:num_dogs_per_octave
           DoG(:, :, dog_idx) = abs(...
               blurred_images{oct_idx}(:, :, dog_idx + 1) - ...
               blurred_images{oct_idx}(:, :, dog_idx));
        end
        DoGs{oct_idx} = DoG;
    end
    
    % 4)    Compute the keypoints with non-maximum suppression and
    %       discard candidates with the contrast threshold.
    kpt_locations = cell(1, num_octaves);
    for oct_idx = 1:num_octaves
        DoG = DoGs{oct_idx};
        DoG_max = imdilate(DoG, true(3, 3, 3));
        is_kpt = (DoG == DoG_max)&(DoG >= contrast_threshold);
        is_kpt(:, :, 1) = false;
        is_kpt(:, :, end) = false;
        [x, y, s] = ind2sub(size(is_kpt), find(is_kpt));
        kpt_locations{oct_idx} = horzcat(x, y, s);
    end
    
    % 5)    Given the blurred images and keypoints, compute the
    %       descriptors. Discard keypoints/descriptors that are too close
    %       to the boundary of the image. Hence, you will most likely
    %       lose some keypoints that you have computed earlier.
    [descriptors{img_idx}, final_kpt_locations{img_idx}] = ...
    computeDescriptors(blurred_images, kpt_locations);
end

% Finally, match the descriptors using the function 'matchFeatures' and
% visualize the matches with the function 'showMatchedFeatures'.
% If you want, you can also implement the matching procedure yourself using
% 'knnsearch'.
indexPairs = matchFeatures(descriptors{1}, descriptors{2},...
    'MatchThreshold', 80, 'MaxRatio', 0.7, 'Unique', true);

matched_kpts_1 = fliplr(final_kpt_locations{1}(indexPairs(:,1),:));
matched_kpts_2 = fliplr(final_kpt_locations{2}(indexPairs(:,2),:));

figure; 
ax = axes;
showMatchedFeatures(images{1},images{2},matched_kpts_1,matched_kpts_2, ...
    'montage','Parent',ax);
legend('matched points 1','matched points 2');
