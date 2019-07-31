function [newpts, T] = normalise2dpts(pts)
% NORMALISE2DPTS - normalises 2D homogeneous points
%
% Function translates and normalises a set of 2D homogeneous points
% so that their centroid is at the origin and their mean distance from
% the origin is sqrt(2).
%
% Usage:   [newpts, T] = normalise2dpts(pts)
%
% Argument:
%   pts -  3xN array of 2D homogeneous coordinates
%
% Returns:
%   newpts -  3xN array of transformed 2D homogeneous coordinates.
%   T      -  The 3x3 transformation matrix, newpts = T*pts
%
pts = pts./repmat(pts(3,:),[3,1]);
N = size(pts,2);
mu = sum(pts(1:2,:),2)/N;
sigma = sqrt(sum(sum((pts(1:2,:) - repmat(mu,[1,N])).^2))/N);
s = sqrt(2)/sigma;
T = [s, 0, -s*mu(1);
        0   , s, -s*mu(2);
        0   ,   0 ,    1];
    
newpts = T*pts;
end
