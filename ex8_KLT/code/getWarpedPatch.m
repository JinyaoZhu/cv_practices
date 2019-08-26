function patch = getWarpedPatch(I, W, x_T, r_T)
% x_T is 1x2 and contains [x_T y_T] as defined in the statement. patch is
% (2*r_T+1)x(2*r_T+1) and arranged consistently with the input image I.
patch_size = 2*r_T+1;
patch = zeros(patch_size);
[d_U,d_V] = meshgrid(-r_T:r_T,-r_T:r_T);
d_coords_patch = [d_U(:),d_V(:)]';
d_coords_warpped = W*[d_coords_patch; ones(1,size(d_coords_patch,2))];
% d_coords_warpped = round(d_coords_warpped);

coords_patch = d_coords_patch +  ...
    repmat([r_T+1;r_T+1],[1,size(d_coords_patch,2)]);
coords_warpped = d_coords_warpped + ...
    repmat(x_T',[1,size(d_coords_warpped,2)]);

max_coords = fliplr(size(I));
for i = 1:size(coords_patch,2)
    u = coords_warpped(1,i);
    v = coords_warpped(2,i);
    if all([u,v] < max_coords & [u,v] > [1 1])
        u_floor = floor(u);
        v_floor = floor(v);
        weights = [u;v] - [u_floor;v_floor];
        a = weights(1); b = weights(2);
        intensity = (1-b) * (...
            (1-a) * I(v_floor, u_floor) +...
            a * I(v_floor, u_floor+1))...
            + b * (...
            (1-a) * I(v_floor+1, u_floor) +...
            a * I(v_floor+1, u_floor+1));
        patch(coords_patch(2,i),coords_patch(1,i)) = intensity;
    end
end

end