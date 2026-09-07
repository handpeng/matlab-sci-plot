function accepted = mpReviewAccepted(review)
% Final export requires an accepted review with every governed dimension PASS.
accepted = isfield(review, 'verdict') && strcmp(char(string(review.verdict)), 'accept') && ...
    isfield(review, 'scientific_correctness') && strcmp(char(string(review.scientific_correctness)), 'PASS') && ...
    isfield(review, 'dimensions') && isstruct(review.dimensions);
if ~accepted, return; end
required = {'claim_support','statistical_transparency','perceptual_clarity','layout_hierarchy', ...
    'accessibility','style_consistency','final_size_legibility','reproducibility'};
for i = 1:numel(required)
    if ~isfield(review.dimensions, required{i}) || ...
            ~strcmp(char(string(review.dimensions.(required{i}))), 'PASS')
        accepted = false;
        return;
    end
end
end
