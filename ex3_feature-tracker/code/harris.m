function scores = harris(img, patch_size, kappa)
img = double(img);
s = [1 2 1; 0 0 0; -1 -2 -1];
Iy = conv2(img, s, 'valid');
s = s';
Ix = conv2(img, s, 'valid');

Ix2 = Ix.^2;
Iy2 = Iy.^2;
Ixy = Ix.* Iy;

patch = ones(patch_size, patch_size);
sIx2 = conv2(Ix2, patch, 'valid');
sIy2 = conv2(Iy2, patch, 'valid');
sIxy = conv2(Ixy, patch, 'valid');

R = (sIx2.*sIy2 - sIxy.^2) - kappa * (sIx2 + sIy2).^2;

R(R<0) = 0;

patch_radius = floor(patch_size/2);
scores = padarray(R, [1+patch_radius 1+patch_radius]);

end