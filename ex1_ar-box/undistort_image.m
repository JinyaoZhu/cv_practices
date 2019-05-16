function dst = undistort_image(K, D, src)
[rows, cols] = size(src);
dst = zeros(rows, cols, 'uint8');
K_inv = K^-1;
for u = 1:cols
    for v = 1:rows
        pt_un = K_inv*[u; v; 1];
        r = norm(pt_un(1:2));
        pt_dis = K*[(1 + D(1)*r^2 + D(2)*r^4)*pt_un(1:2);1];
        u_ = pt_dis(1);
        v_ = pt_dis(2);
        u1_ = floor(u_);
        u2_ = ceil(u_);
        v1_ = floor(v_);
        v2_ = ceil(v_);
        if u1_ >= 0 && v1_>= 0 && u2_ <= cols && v2_ <= rows
            I11 = src(v1_, u1_);
            I12 = src(v2_, u1_);
            I21 = src(v1_, u2_);
            I22 = src(v2_, u2_);
            II = double([I11,I12;I21,I22]);
            I = [u2_- u_, u_ - u1_]*II*[v2_- v_,v_ - v1_]'/((u2_ - u1_)*(v2_ - v1_));
            dst(v, u) = I;
        end
    end
end
end