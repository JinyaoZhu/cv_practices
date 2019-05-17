close all;
clear;

SHOW_IMG = true;

K = load('../data/K.txt', '-ascii');
p_W_corners = load('../data/p_W_corners.txt', '-ascii')/100; % meter
detected_corners = load('../data/detected_corners.txt', '-ascii');

videoFilename = '../video.mp4';
vidObj = VideoWriter(videoFilename,'MPEG-4'); % Prepare video file
vidObj.FrameRate = 30;
open(vidObj);

N_images = size(detected_corners, 1);

T = zeros(3, N_images);
Q = zeros(4, N_images);
P_w = p_W_corners';

for img_idx = 1:N_images
    if SHOW_IMG
        img = rgb2gray(imread(['../data/images_undistorted/',sprintf('img_%04d.jpg',img_idx)]));
        imshow(img);
    end
    
    p = reshape(detected_corners(img_idx,:), [2,12]);
    M = estimatePoseDLT(p, P_w, K);
    if SHOW_IMG
        % reprojection
        reproject_corners = M*[P_w; ones(1,size(P_w,2))];
        reproject_corners = reproject_corners./...
            [reproject_corners(3,:);reproject_corners(3,:);reproject_corners(3,:)];
        reproject_corners = K*reproject_corners;
        
        hold on;
        scatter(p(1,:),p(2,:),'go');
        scatter(reproject_corners(1,:),reproject_corners(2,:),'r+');
        legend('corner', 'reprojection');
        hold off;
        
        drawnow;
        frame = getframe;
        writeVideo(vidObj, frame.cdata);
    end
    
    T(:, img_idx) =  -M(1:3,1:3)'*M(1:3,4); % t_wc
    Q(:, img_idx) = rotMatrix2Quat( M(1:3,1:3)'); % q_wc
end

close(vidObj);

plotTrajectory3D(30, T, Q, P_w);

close all;
