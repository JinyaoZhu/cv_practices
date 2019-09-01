function p_G_C = alignEstimateToGroundTruth(...
    pp_G_C, p_V_C)
% Returns the points of the estimated trajectory p_V_C transformed into the
% ground truth frame G. The similarity transform Sim_G_V is to be chosen
% such that it results in the lowest error between the aligned trajectory
% points p_G_C and the points of the ground truth trajectory pp_G_C. All
% matrices are 3xN.

error_function = @(x) alignmentError(x, pp_G_C, p_V_C);
options = optimoptions('lsqnonlin', ...
    'Algorithm','trust-region-reflective','Display','iter');
x0 = [HomogMatrix2twist(eye(4));1];
x = lsqnonlin(error_function,x0,[],[],options);
S_G_V = twist2HomogMatrix(x);
S_G_V(1:3,1:3) = x(7)*S_G_V(1:3, 1:3);
p_G_C = S_G_V * [p_V_C;ones(1,size(p_V_C,2))];
end