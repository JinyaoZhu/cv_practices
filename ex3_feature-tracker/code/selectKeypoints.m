function keypoints = selectKeypoints(scores, num, r)
% Selects the num best scores as keypoints and performs non-maximum 
% supression of a (2r + 1)*(2r + 1) box around the current maximum.
[ROWS, COLS] = size(scores);
keypoints = zeros(2, num);

for i = 1:num
    [val,idx] = max(scores(:));
    if val > 0
        [row, col] = ind2sub(size(scores),idx);
        keypoints(:, i) = [row, col];
        row_start = max(1, row - r);
        row_end = min(ROWS, row + r);
        col_start = max(1, col - r);
        col_end = min(COLS, col+r);
        box = zeros(row_end - row_start + 1, col_end - col_start + 1);
        scores(row_start:row_end, col_start:col_end) = box;
    end
end

end