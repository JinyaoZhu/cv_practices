clear;
close all;

SAVE_VIDEO = true;

K = load('../data/K.txt','-ascii');
D = load('../data/D.txt','-ascii');
cam_poses = load('../data/poses.txt','-ascii'); % T_cw

if SAVE_VIDEO
    video = VideoWriter('../output.mp4','MPEG-4');
    video.FrameRate = 30;
    open(video);
end
% img_dist = rgb2gray(imread('data/images/img_0001.jpg'));
% img_undis = undistort_image(K, D, img_dist);
% figure;
% imshow(img_undis);

chess_board_size_x = 9;
chess_board_size_y = 6;
width = 0.04;

box_width = width*2;
box_start_x = width*2;
box_start_y = width*1;

[X,Y, Z] = meshgrid(0:chess_board_size_x-1, 0:chess_board_size_y-1, 0:0);
checkerboard_corners_w = width * [X(:) Y(:) Z(:)]';

[X,Y,Z] = meshgrid(0:1, 0:1, -1:0);
box_vertex = [box_start_x+X(:)*box_width, box_start_y+Y(:)*box_width, Z(:)*box_width]';

figure(1);
axis equal;
for pose_idx = 1:length(cam_poses)
    % load image
    img_dist = rgb2gray(imread(['../data/images/',sprintf('img_%04d.jpg',pose_idx)]));
    % load camera pose
    T = poseVector2TransformMat(cam_poses(pose_idx, 1:6));
    % project checker board from world onto image
    checkerboard_corners_img = projectPoints(K, D, T,checkerboard_corners_w);
    % project box vertex from world onto image
    box_corner_c = projectPoints(K, D, T, box_vertex);
    
    imshow(img_dist, 'border', 'tight');
    hold on;
    scatter(checkerboard_corners_img(1,:), checkerboard_corners_img(2,:), 'go', 'LineWidth', 1);
    scatter(box_corner_c(1,:), box_corner_c(2,:),'ro', 'filled');
    % top
    line([box_corner_c(1,1), box_corner_c(1,2)],[box_corner_c(2,1), box_corner_c(2,2)], 'color', 'r', 'linewidth', 2);
    line([box_corner_c(1,2), box_corner_c(1,4)],[box_corner_c(2,2), box_corner_c(2,4)], 'color', 'r', 'linewidth', 2);
    line([box_corner_c(1,4), box_corner_c(1,3)],[box_corner_c(2,4), box_corner_c(2,3)], 'color', 'r', 'linewidth', 2);
    line([box_corner_c(1,3), box_corner_c(1,1)],[box_corner_c(2,3), box_corner_c(2,1)], 'color', 'r', 'linewidth', 2);
    % bottom
    line([box_corner_c(1,5), box_corner_c(1,6)],[box_corner_c(2,5), box_corner_c(2,6)], 'color', 'r', 'linewidth', 2);
    line([box_corner_c(1,6), box_corner_c(1,8)],[box_corner_c(2,6), box_corner_c(2,8)], 'color', 'r', 'linewidth', 2);
    line([box_corner_c(1,8), box_corner_c(1,7)],[box_corner_c(2,8), box_corner_c(2,7)], 'color', 'r', 'linewidth', 2);
    line([box_corner_c(1,7), box_corner_c(1,5)],[box_corner_c(2,7), box_corner_c(2,5)], 'color', 'r', 'linewidth', 2);
    % side
    line([box_corner_c(1,1), box_corner_c(1,5)],[box_corner_c(2,1), box_corner_c(2,5)], 'color', 'r', 'linewidth', 2);
    line([box_corner_c(1,2), box_corner_c(1,6)],[box_corner_c(2,2), box_corner_c(2,6)], 'color', 'r', 'linewidth', 2);
    line([box_corner_c(1,3), box_corner_c(1,7)],[box_corner_c(2,3), box_corner_c(2,7)], 'color', 'r', 'linewidth', 2);
    line([box_corner_c(1,4), box_corner_c(1,8)],[box_corner_c(2,4), box_corner_c(2,8)], 'color', 'r', 'linewidth', 2);
    
    hold off;
    if SAVE_VIDEO
        frame = getframe;
        img = frame.cdata;
        writeVideo(video,img);
    else
        drawnow;
    end
end

if SAVE_VIDEO
    close(video);
    close all;
end

