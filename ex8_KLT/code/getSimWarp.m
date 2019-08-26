function W = getSimWarp(dx, dy, alpha_deg, lambda)
% alpha given in degrees, as indicated
W = lambda*[cosd(alpha_deg), -sind(alpha_deg), dx;
            sind(alpha_deg), cosd(alpha_deg), dy];
end
