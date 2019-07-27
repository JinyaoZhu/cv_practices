function disp_img = getDisparity(...
    left_img, right_img, patch_radius, min_disp, max_disp)
% left_img and right_img are both H x W and you should return a H x W
% matrix containing the disparity d for each pixel of left_img. Set
% disp_img to 0 for pixels where the SSD and/or d is not defined, and for d
% estimates rejected in Part 2. patch_radius specifies the SSD patch and
% each valid d should satisfy min_disp <= d <= max_disp.

rows = size(left_img, 1);
cols = size(left_img, 2);

disp_img = zeros(size(left_img));

r = patch_radius;
patch_size = r*2+1;

parfor i = (1+r):(rows-r)
    for j = (1+r+max_disp):(cols-r)
        % extract patch from left image
        left_patch = left_img(i-r : i+r, j-r : j+r);
        % extract strip from right image according to
        % max and min disparity
        right_strip = right_img(i-r : i+r, j-max_disp-r : j-min_disp+r);
        % converte image patch into a vector
        left_patch_vect = single(left_patch(:));
        disp_range = max_disp-min_disp+1;
        right_strip_vect = single(zeros(patch_size^2 , disp_range));
        % converte right image strip into a matrix for pdist2()
        % ---> column size = max_disp-min_disp+1
        % | | |     |
        % | | | ... |  row size = patch_size^2 = image patch (column major oder)
        % | | |     |
        % V V V     V
        for k = 1:patch_size
            right_strip_vect((k-1)*patch_size+1:k * patch_size, :) ...
                = right_strip(:, k:disp_range+k-1);
        end
        % calculate SSD for left image patch with
        % all patchs in the right image strip
        ssds = pdist2(left_patch_vect', right_strip_vect', 'squaredeuclidean');
        
        if false
            close all;
            figure;
            subplot(3,1,1);
            imagesc(left_patch);
            axis equal;
            axis off;
            subplot(3,1,2);
            imagesc(right_strip);
            axis equal;
            axis off;
            subplot(3,1,3);
            plot(max_disp-(1:disp_range),ssds, '-x');
            xlabel('disparity');
            ylabel('SSD');
        end
        
        % find the closest distance and its corresponding disparity
        [min_dist, d_tmp] = min(ssds);
        
        % the higher c the stricter criterion 
        % for outler rejection
        c = 1.5;
        num_candidates = nnz(ssds<= c*min_dist);
                
        if (num_candidates<3) && (d_tmp ~= 1) && (d_tmp ~= length(ssds))
            % ssd = p(1)x^2 + p(2)x + p(3)
        	p = polyfit(d_tmp-1:1:d_tmp+1, ssds(d_tmp-1:d_tmp+1), 2);
            disp_img(i,j) =  max_disp - (-p(2)/(2*p(1)));
        else
            disp_img(i,j) = 0;
        end
    end
end

end
