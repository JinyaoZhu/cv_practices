function matches = matchDescriptors(...
    query_descriptors, database_descriptors, lambda)
% Returns a 1xQ matrix where the i-th coefficient is the index of the
% database descriptor which matches to the i-th query descriptor.
% The descriptor vectors are MxQ and MxD where M is the descriptor
% dimension and Q and D the amount of query and database descriptors
% respectively. matches(i) will be zero if there is no database descriptor
% with an SSD < lambda * min(SSD). No two non-zero elements of matches will
% be equal.

[dists, matches] = pdist2(database_descriptors',query_descriptors',...
                'euclidean','Smallest',1);
min_non_zero_dist = min(dists(dists~=0));
matches(dists >= lambda*min_non_zero_dist) = 0;

unique_matches = zeros(1, length(matches));
[val, idx, ~] = unique(matches,'stable');
unique_matches(idx) = val;
matches = unique_matches;
end
