function transform = poseVector2TransformMat(pose_vects)
transform = eye(4);
angle = norm(pose_vects(1:3));
if(abs(angle) > 1e-16)
    axis = pose_vects(1:3)/angle;
    skew_sym = skew_symmetry(axis);
    transform(1:3,1:3) = eye(3) + sin(angle) * skew_sym + (1-cos(angle))*skew_sym*skew_sym;
else
    transform(1:3,1:3) = eye(3);
end
transform(1:3,4) = pose_vects(4:6);
end